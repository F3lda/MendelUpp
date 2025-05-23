import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../WebView/webview_controls.dart';
import '../WebView/webview_popscope.dart';


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

  MENZA webviewState = MENZA.HOME;

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
          onWebResourceError: (WebResourceError error) {
            webviewError = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              print("WidgetsBinding build");

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when connecting to https://webiskam.mendelu.cz, probably no internet connection.")));
              Navigator.of(context).pop();
            });
          },
          onPageFinished: (url) async {
            if (kDebugMode) {
              print("URL: ${url}");
            }

            if (webviewError) {return;}

            if (webviewState != MENZA.KONTA) {
              if (url.toLowerCase().contains('https://webiskam.mendelu.cz/Konta'.toLowerCase()) && (webviewState == MENZA.LOGIN || webviewState == MENZA.HOME)) { // KONTA PAGE -> DONE
                print("RESULT5");
                webviewState = MENZA.KONTA;
                controller.runJavaScriptReturningResult("setTimeout(function() {SHOWWEBVIEWtoFlutter.postMessage('SHOW');}, 330);");
              } else if (url.toLowerCase().contains('https://webiskam.mendelu.cz/ObjednavkyStravovani'.toLowerCase()) && (webviewState == MENZA.LOGIN || webviewState == MENZA.HOME)) { // LOGGED IN -> show konta page
                controller.loadRequest(Uri.parse('https://webiskam.mendelu.cz/Konta'));
                print("RESULT4");
              } else if (url.toLowerCase().contains('https://webiskam.mendelu.cz/Home/Index?ReturnUrl=%2fObjednavkyStravovani'.toLowerCase()) && webviewState == MENZA.HOME) { // NOT LOGGED IN -> show login form
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
                    webviewState = MENZA.ERROR;
                  } else {
                    webviewState = MENZA.LOGIN;
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when connecting to https://webiskam.mendelu.cz, please try again.")));
                    Navigator.of(context).pop();
                  }
                  webviewState = MENZA.ERROR;
                }
              }

              if (webviewState == MENZA.LOGIN) { // LOGGING IN...
                if ((url.toLowerCase().contains('https://alibaba.mendelu.cz/idp/profile/SAML2/Redirect/SSO;jsessionid='.toLowerCase()) || url.toLowerCase().contains('https://alibaba.mendelu.cz/idp/profile/SAML2/Redirect/SSO?execution='.toLowerCase())) && (await controller.runJavaScriptReturningResult(
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
                    webviewState = MENZA.ERROR;
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
                    webviewState = MENZA.ERROR;
                  }
                } else if (url.toLowerCase().contains('https://alibaba.mendelu.cz/idp/profile/SAML2/Redirect/SSO?execution='.toLowerCase()) && (await controller.runJavaScriptReturningResult(
                    'if (document.forms[0] != null && document.forms[0].querySelector(\'input[type=\"submit\"][name=\"_eventId_proceed\"]\') != null) {true;} else {false;}'
                )).toString() == "true") { // SHOWING PERMISSIONS FORM
                  print("PERMISSIONS");


                  final result = (await controller.runJavaScriptReturningResult(
                      'if (document.forms[0] != null && document.forms[0].querySelector(\'input[type=\"submit\"][name=\"_eventId_proceed\"]\') != null) {document.forms[0].querySelector(\'input[type="submit"][name=\"_eventId_proceed\"]\').click(); true;} else {false;}'
                  )).toString();
                  print("RESULT3");
                  print(result);
                  if (result == "false") {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when logging in to https://webiskam.mendelu.cz, please try again.")));
                      Navigator.of(context).pop();
                    }
                    webviewState = MENZA.ERROR;
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
    return WebViewPopScope(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const CloseButtonIcon()
          ),
          title: const Text('Menza Mendelu'),
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
        )
      )
    );
  }
}
