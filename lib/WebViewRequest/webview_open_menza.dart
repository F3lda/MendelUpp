import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../WebView/web_view_test_controls.dart';
import '../WebView/web_view_test_menu.dart';


class WebViewMenzaPage extends StatefulWidget {
  const WebViewMenzaPage({super.key});

  @override
  State<WebViewMenzaPage> createState() => _WebViewMenzaPageState();
}

enum MENZA {HOME, LOGIN, KONTA, /*ORDERS_PAGE,*/ ERROR}

class _WebViewMenzaPageState extends State<WebViewMenzaPage> {
  late final WebViewController controller;
  var loadingPercentage = 0;
  bool hideWebView = true;

  String dataUsername = "";
  String dataPassword = "";
  String dataLoggedin = "";

  MENZA pageState = MENZA.HOME;

  @override
  void initState() {
    super.initState();


    //pageState = MENZA.MAIN_PAGE;

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

            if (pageState != MENZA.KONTA) {

              if (url.contains('https://webiskam.mendelu.cz/Konta') && (pageState == MENZA.LOGIN || pageState == MENZA.HOME)) { // KONTA PAGE -> DONE
                print("RESULT5");
                pageState = MENZA.KONTA;
                controller.runJavaScriptReturningResult("setTimeout(function() {SHOWWEBVIEWtoFlutter.postMessage('SHOW');}, 330);");
              } else if (url.contains('https://webiskam.mendelu.cz/ObjednavkyStravovani') && (pageState == MENZA.LOGIN || pageState == MENZA.HOME)) { // LOGGED IN -> show konta page
                controller.loadRequest(Uri.parse('https://webiskam.mendelu.cz/Konta'));
                print("RESULT4");
              } else if (url.contains('https://webiskam.mendelu.cz/Home/Index?ReturnUrl=%2FObjednavkyStravovani') && pageState == MENZA.HOME) { // NOT LOGGED IN -> show login form
                if ((await controller.runJavaScriptReturningResult(
                    'if (document.querySelector("form[action=\'/Prihlaseni/LogIn\'] input") != null) {true;} else {false;}'
                )).toString() == "true") {
                  print("LOGIN BUTTON");
                  final result = (await controller.runJavaScriptReturningResult(
                      'if (document.querySelector("form[action=\'/Prihlaseni/LogIn\'] input") != null) {document.querySelector("form[action=\'/Prihlaseni/LogIn\'] input").click(); true;} else {false;}'
                  )).toString();
                  print("RESULT1");
                  print(result);
                  if (result == "false") {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when connecting to https://webiskam.mendelu.cz, please try again.")));
                      Navigator.of(context).pop();
                    }
                    pageState = MENZA.ERROR;
                  } else {
                    pageState = MENZA.LOGIN;
                  }
                }
              }

              if (pageState == MENZA.LOGIN) { // LOGGING IN...
                if ((url.contains('https://alibaba.mendelu.cz/idp/profile/SAML2/Redirect/SSO;jsessionid=') || url.contains('https://alibaba.mendelu.cz/idp/profile/SAML2/Redirect/SSO?execution=')) && (await controller.runJavaScriptReturningResult(
                    'if (document.getElementById("username") != null && document.getElementById("password") != null && document.querySelector("button[type=\'submit\']") != null) {true;} else {false;}'
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
                    pageState = MENZA.ERROR;
                  }

                  final result = (await controller.runJavaScriptReturningResult( //'document.getElementById("username") != null'
                      'if (document.getElementById("username") != null && document.getElementById("password") != null && document.querySelector("button[type=\'submit\']") != null) {'
                          "document.getElementById('username').value = '$dataUsername';"
                          "document.getElementById('password').value = '$dataPassword';"
                          'document.querySelector("button[type=\'submit\']").click();'
                      'true;} else {false;}'
                  )).toString();
                  print("RESULT2");
                  print(result);
                  if (result == "false") {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when logging in to https://webiskam.mendelu.cz, please try again.")));
                      Navigator.of(context).pop();
                    }
                    pageState = MENZA.ERROR;
                  }
                } else if (url.contains('https://alibaba.mendelu.cz/idp/profile/SAML2/Redirect/SSO?execution=') && (await controller.runJavaScriptReturningResult(
                    'if (document.forms[0] != null && document.forms[0].querySelector(\'input[type=\"submit\"][value=\"Accept\"]\') != null) {true;} else {false;}'
                )).toString() == "true") { // SHOWING PERMISSIONS FORM
                  print("PERMISSIONS");


                  final result = (await controller.runJavaScriptReturningResult(
                      'if (document.forms[0] != null && document.forms[0].querySelector(\'input[type=\"submit\"][value=\"Accept\"]\') != null) {document.forms[0].querySelector(\'input[type="submit"][value="Accept"]\').click(); true;} else {false;}'
                  )).toString();
                  print("RESULT3");
                  print(result);
                  if (result == "false") {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when logging in to https://webiskam.mendelu.cz, please try again.")));
                      Navigator.of(context).pop();
                    }
                    pageState = MENZA.ERROR;
                  }
                } else {
                  print("unknown redirect");
                }
              }

            }


            if (mounted) {
              setState(() {
                loadingPercentage = 100;
              });
            }
          },
          onNavigationRequest: (navigation) {

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
    controller.loadRequest(Uri.parse('https://webiskam.mendelu.cz/ObjednavkyStravovani'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const CloseButtonIcon()
          ),
          title: const Text('Menza Mendelu'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          /*actions: [
            NavigationControls(controller: controller),
            Menu(controller: controller),
          ],*/
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
