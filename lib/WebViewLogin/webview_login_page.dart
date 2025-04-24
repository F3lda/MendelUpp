import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Common/utils.dart';


class WebViewLoginPage extends StatefulWidget {
  const WebViewLoginPage({super.key});

  @override
  State<WebViewLoginPage> createState() => _WebViewLoginPageState();
}

enum LOGIN {PAGE, REDIRECT, REDIRECT2, DONE}

class _WebViewLoginPageState extends State<WebViewLoginPage> {
  late final WebViewController controller;
  var loadingPercentage = 0;
  bool hideWebView = true;

  String dataUsername = "";
  String dataPassword = "";
  String dataLoggedin = "";

  LOGIN webviewState = LOGIN.PAGE;

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
                hideWebView = true;
                loadingPercentage = 0;
              });
            }
          },
          onProgress: (progress) {
            if (mounted) {setState(() {loadingPercentage = progress;});}
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
              print("URL: $url");
            }

            if (webviewError) {return;}

            if (webviewState != LOGIN.DONE) {
              if (url.startsWith('data:text/html;'.toLowerCase()) && webviewState == LOGIN.PAGE) {
                final result = (await controller.runJavaScriptReturningResult(
                    "if (typeof SHOWWEBVIEWtoFlutter !== 'undefined' && typeof USERNAMEtoFlutter !== 'undefined' && typeof PASSWORDtoFlutter !== 'undefined'){"
                        "window.onbeforeunload = function (e) {USERNAMEtoFlutter.postMessage(document.getElementById('credential_0').value); PASSWORDtoFlutter.postMessage(document.getElementById('credential_1').value);};"
                        "setTimeout(function() {SHOWWEBVIEWtoFlutter.postMessage('SHOW');}, 330);"
                        "true;"
                    "} else {false;}"
                )).toString();
                print("RESULT form offline");
                print(result);
                if (result != "true") {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR form offline.")));
                    Navigator.of(context).pop();
                  }
                }
              } else if (url.toLowerCase().contains('https://is.mendelu.cz/system/login.pl'.toLowerCase()) && webviewState == LOGIN.PAGE) {
                final result = (await controller.runJavaScriptReturningResult(
                    "if (typeof SHOWWEBVIEWtoFlutter !== 'undefined' && typeof USERNAMEtoFlutter !== 'undefined' && typeof PASSWORDtoFlutter !== 'undefined'){"
                        "window.onbeforeunload = function (e) {USERNAMEtoFlutter.postMessage(document.getElementById('credential_0').value); PASSWORDtoFlutter.postMessage(document.getElementById('credential_1').value);};"
                        "setTimeout(function() {SHOWWEBVIEWtoFlutter.postMessage('SHOW');}, 330);"
                        "try {"
                        "document.getElementById('hlavicka').style.display='none';"
                        "document.getElementById('horni-navigace').style.display='none';"
                      //"document.getElementById('titulek').style.display='none';"
                        "document.querySelector('.mainpage nav').style.display='none';"
                        "document.querySelector('.mainpage .small').style.display='none';"
                        "document.querySelectorAll('br').forEach(element => {element.style.display='none';});"
                      //"[...parent.document.getElementsByTagName('br')].forEach(element => {element.style.display='none';});"
                        "document.querySelectorAll('.uis_msg.info').forEach(element => {element.style.display='none';});"
                        "var flutterViewPort=document.createElement('meta');"
                        "flutterViewPort.name = 'viewport';"
                        "flutterViewPort.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=1';"
                        "document.getElementsByTagName('head')[0].appendChild(flutterViewPort);"
                        "document.getElementById('loginform').style.margin = 0;"
                        "document.getElementById('loginform').style.padding = '5px';"
                        "document.getElementById('loginform').style.width = null;"
                        "document.getElementById('odhlasit1').style.display='none';"
                        "document.getElementsByTagName('table')[4].style.margin = 0;"
                        "document.querySelector('.loginform-section:last-of-type').style.display='none';"
                        "document.querySelectorAll('.mainpage form ~ div').forEach(element => {element.style.display='none';});"
                        "document.getElementById('foot').style.display='none';"
                        "document.getElementById('loginform').style.width = 'unset';"
                        "document.getElementById('loginform').style.display = 'inline-block';"
                        "document.querySelectorAll('input[type=\"text\"]').forEach(element => {element.style.width='200px';});"
                        "document.querySelectorAll('input[type=\"password\"]').forEach(element => {element.style.width='200px';});"
                        "true;} catch (error) {console.error(error); error.message;}"
                    "} else {false;}"
                )).toString();
                print("RESULT form");
                print(result);
                if (result != "true") {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when connecting to is.mendelu.cz, please try again.")));
                    Navigator.of(context).pop();
                  }
                }
              }

              if (url.toLowerCase().contains("https://is.mendelu.cz/auth/".toLowerCase()) && webviewState != LOGIN.DONE) {
                // two redirects when logging in -> first can be undefined
                if (webviewState == LOGIN.PAGE) { // redirect 1
                  webviewState = LOGIN.REDIRECT;
                } else if (webviewState == LOGIN.REDIRECT) { // redirect 2
                  webviewState = LOGIN.REDIRECT2;
                } else { // error
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR while logging in to is.mendelu.cz, please try again.")));
                    Navigator.of(context).pop();
                  }
                }

                final result = (await controller.runJavaScriptReturningResult(
                    "if (document.getElementById('prihlasen') != null) {document.getElementById('prihlasen').firstChild.data.trim();} else {false;}"
                )).toString().replaceAll('"', '');

                print("RESULTres");
                print(result);

                if (result != '' && result != 'false') {
                  print("PRIHLASEN");
                  webviewState = LOGIN.DONE;

                  dataLoggedin = result.split(":")[1].trim();

                  // Create storage
                  const storage = FlutterSecureStorage();
                  await storage.write(key: "Mfullname", value: dataLoggedin);
                  await storage.write(key: "Musername", value: dataUsername);
                  await storage.write(key: "Mpassword", value: dataPassword);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logged in as: $dataLoggedin")));
                    Navigator.of(context).pop();
                  }
                } else {
                  () async {
                    if (webviewState == LOGIN.REDIRECT) {await Future<void>.delayed(const Duration(milliseconds: 5000));}
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR while logging in to is.mendelu.cz, please try again.")));
                      Navigator.of(context).pop();
                    }
                  }();
                }
              }

            }

            if (mounted) {setState(() {loadingPercentage = 100;});}
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
      )
      ..addJavaScriptChannel(
        'USERNAMEtoFlutter',
        onMessageReceived: (message) async {
          dataUsername = message.message;
          await _checkGuestLogin();
        },
      )
      ..addJavaScriptChannel(
        'PASSWORDtoFlutter',
        onMessageReceived: (message) async {
          dataPassword = message.message;
          await _checkGuestLogin();
        },
      );
    //controller.loadRequest(Uri.parse('https://is.mendelu.cz/system/login.pl'));
    loadHtmlFromAssets('assets/webviews_guest/login.html', controller);
  }

  Future<void> _checkGuestLogin() async {
    if (dataUsername == 'GUEST' && dataPassword == 'GUEST') {
      webviewState = LOGIN.DONE;
      // Create storage
      const storage = FlutterSecureStorage();
      await storage.write(key: "Mfullname", value: dataUsername);
      await storage.write(key: "Musername", value: dataUsername);
      await storage.write(key: "Mpassword", value: dataPassword);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logged in as: $dataUsername")));
        Navigator.of(context).pop();
      }
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
        title: const Text('Login to Mendelu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
