import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Common/utils.dart';
import '../WebView/webview_controls.dart';
import '../WebView/webview_popscope.dart';


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

  bool webviewError = false;

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
          onWebResourceError: (WebResourceError error) {
            webviewError = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              print("WidgetsBinding build");

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when connecting to https://is.mendelu.cz, probably no internet connection.")));
              Navigator.of(context).pop();
            });
          },
          onPageFinished: (url) async {
            if (kDebugMode) {
              print("URL: ${url}");
            }

            if (webviewError) {return;}

            if (webviewState != STUDENT.DONE) {

              if (url.toLowerCase().contains('https://is.mendelu.cz/system/login.pl'.toLowerCase()) && webviewState == STUDENT.LOGIN) {
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
                    webviewState = STUDENT.ERROR;
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when logging in to is.mendelu.cz, please try again.")));
                    Navigator.of(context).pop();
                  }
                  webviewState = STUDENT.ERROR;
                }
              }

              if (url.toLowerCase().contains("https://is.mendelu.cz/auth/".toLowerCase()) && webviewState != STUDENT.REDIRECT2) {
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

              if (url.toLowerCase().contains("https://is.mendelu.cz/auth/student/moje_studium.pl".toLowerCase()) && webviewState == STUDENT.REDIRECT2) {
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
              launchInBrowser(context, Uri.parse(navigation.url));

              return NavigationDecision.prevent;
            }

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

  @override
  Widget build(BuildContext context) {
    return WebViewPopScope(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const CloseButtonIcon()
          ),
          title: const Text('Student Portal Mendelu'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            if (!hideWebView) WebViewControls(controller: controller),
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
        ),
        bottomNavigationBar: (!hideWebView) ? BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: IconButton(tooltip: 'Rozvrh hodin', icon: Icon(Icons.schedule), onPressed: () {
                controller.loadRequest(Uri.parse('https://is.mendelu.cz/auth/katalog/rozvrhy_view.pl?rozvrh_student_obec=1'));
              },),),
              Expanded(child: IconButton(tooltip: 'Moje předměty', icon: Icon(Icons.view_list), onPressed: () {
                controller.loadRequest(Uri.parse('https://is.mendelu.cz/auth/student/list.pl'));
              },),),
              Expanded(child: IconButton(tooltip: 'Odevzdávárna', icon: Icon(Icons.drive_folder_upload), onPressed: () {
                controller.loadRequest(Uri.parse('https://is.mendelu.cz/auth/student/odevzdavarny.pl'));
              },),),
              Expanded(child: IconButton(tooltip: 'Přihlašování na zkoušky', icon: Icon(Icons.school), onPressed: () {
                controller.loadRequest(Uri.parse('https://is.mendelu.cz/auth/student/terminy_seznam.pl'));
              },),),
              Expanded(child: IconButton(tooltip: 'Registrace předmětů', icon: Icon(Icons.checklist), onPressed: () {
                controller.loadRequest(Uri.parse('https://is.mendelu.cz/auth/student/registrace.pl'));
              },),),
              Expanded(child: IconButton(tooltip: 'E-index', icon: Icon(Icons.explicit_outlined), onPressed: () {
                controller.loadRequest(Uri.parse('https://is.mendelu.cz/auth/student/pruchod_studiem.pl'));
              },),),
            ],
          ),
        ) : null,
      )
    );
  }
}
