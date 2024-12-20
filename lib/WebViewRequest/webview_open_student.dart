import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../WebView/web_view_test_controls.dart';
import '../WebView/web_view_test_menu.dart';


class WebViewStudentPage extends StatefulWidget {
  const WebViewStudentPage({super.key});

  @override
  State<WebViewStudentPage> createState() => _WebViewStudentPageState();
}

enum STUDENT {LOGIN, REDIRECT, REDIRECT2, DONE, ERROR}

class _WebViewStudentPageState extends State<WebViewStudentPage> {
  late final WebViewController controller;
  var loadingPercentage = 0;
  bool hideWebView = true;

  String dataUsername = "";
  String dataPassword = "";
  String dataLoggedin = "";

  STUDENT webviewState = STUDENT.LOGIN;

  @override
  void initState() {
    super.initState();
    controller = WebViewController();
    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                //hideWebView = true;
                loadingPercentage = 0;
              });
            }
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                loadingPercentage = progress;
              });
            }
          },
          onPageFinished: (url) async {
            if (kDebugMode) {
              print("URL: ${url}");
            }

            if (webviewState != STUDENT.DONE) {

              if (url.contains('https://is.mendelu.cz/system/login.pl') && webviewState == STUDENT.LOGIN) {
                if ((await controller.runJavaScriptReturningResult(
                    'if (document.getElementById("credential_0") != null && document.getElementById("credential_1") != null && document.querySelector("input[type=\'submit\']") != null) {true;} else {false;}'
                )).toString() == "true") { // SHOWING LOGIN FORM
                  print("LOGIN FORM");


                  const storage = FlutterSecureStorage();

                  print("START");
                  dataLoggedin = (await storage.read(key: "Mfullname")) ?? "";
                  dataUsername = (await storage.read(key: "Musername")) ?? "";
                  dataPassword = (await storage.read(key: "Mpassword")) ?? "";

                  if (dataUsername.isEmpty || dataPassword.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR you are not logged in to MENDELU!")));
                      Navigator.of(context).pop();
                    }
                    webviewState = STUDENT.ERROR;
                  }

                  final result = (await controller.runJavaScriptReturningResult( //'document.getElementById("username") != null'
                      'if (document.getElementById("credential_0") != null && document.getElementById("credential_1") != null && document.querySelector("input[type=\'submit\']") != null) {'
                          "document.getElementById('credential_0').value = '$dataUsername';"
                          "document.getElementById('credential_1').value = '$dataPassword';"
                          'document.querySelector("input[type=\'submit\']").click();'
                          'true;} else {false;}'
                  )).toString();
                  print("RESULT2");
                  print(result);
                  if (result == "false") {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when logging in to is.mendelu.cz, please try again.")));
                      Navigator.of(context).pop();
                    }
                    webviewState = STUDENT.REDIRECT;
                  }
                }
              }

              if (url.contains("https://is.mendelu.cz/auth/") && webviewState != STUDENT.REDIRECT2) {
                // two redirects when logging in -> first can be undefined
                if (webviewState == STUDENT.LOGIN) { // redirect 1
                  webviewState = STUDENT.REDIRECT;
                } else if (webviewState == STUDENT.REDIRECT) { // redirect 2
                  webviewState = STUDENT.REDIRECT2;
                } else { // error
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR while logging in to is.mendelu.cz, please try again.")));
                    Navigator.of(context).pop();
                  }
                }

                if (webviewState == STUDENT.REDIRECT2) { // LOGGED IN -> show konta page
                  controller.loadRequest(Uri.parse('https://is.mendelu.cz/auth/student/moje_studium.pl'));
                  print("goto StudentPortal");
                }
              }

              if (url.contains("https://is.mendelu.cz/auth/student/moje_studium.pl") && webviewState == STUDENT.REDIRECT2) {
                print("StudentPortal - DONE");
                webviewState = STUDENT.DONE;
                controller.runJavaScriptReturningResult("setTimeout(function() {SHOWWEBVIEWtoFlutter.postMessage('SHOW');}, 330);");
              }

            }

            if (mounted) {
              setState(() {
                loadingPercentage = 100;
              });
            }
          },
          onNavigationRequest: (navigation) {

            if(navigation.url.toUpperCase().contains('DOWNLOAD')) {
              _launchInBrowser(Uri.parse(navigation.url));

              return NavigationDecision.prevent;
            }

            //if(navigation.url.contains("https://is.mendelu.cz/auth/")) {
            //if (mounted) {setState(() {hideWebView = true;});}

            //return NavigationDecision.prevent;
            //}

            return NavigationDecision.navigate;
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'SHOWWEBVIEWtoFlutter',
        onMessageReceived: (message) {
          if (message.message == "SHOW") {
            if (mounted) {setState(() {hideWebView = false;});}
          }
        },
      );
    controller.loadRequest(Uri.parse('https://is.mendelu.cz/system/login.pl'));
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const CloseButtonIcon()
          ),
          title: const Text('Student Portal Mendelu'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            NavigationControls(controller: controller),
            //Menu(controller: controller),
          ],
        ),
        body: SafeArea(
            child: Stack(
              children: [
                const Center(child: CircularProgressIndicator()),
                Offstage(
                    offstage: hideWebView,
                    child: WebViewWidget(controller: controller)
                ),
                if (loadingPercentage < 100) LinearProgressIndicator(value: loadingPercentage / 100.0)
              ],
            )
        )
    );
  }
}
