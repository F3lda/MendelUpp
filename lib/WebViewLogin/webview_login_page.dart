import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewLoginPage extends StatefulWidget {
  const WebViewLoginPage({super.key});

  @override
  State<WebViewLoginPage> createState() => _WebViewLoginPageState();
}

class _WebViewLoginPageState extends State<WebViewLoginPage> {
  late final WebViewController controller;
  var loadingPercentage = 0;
  bool hideWebView = true;

  String dataUsername = "";
  String dataPassword = "";
  String dataLoggedin = "";


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
            if (mounted) {
              setState(() {
                loadingPercentage = progress;
              });
            }
          },
          onPageFinished: (url) async {
            if (url.contains('https://is.mendelu.cz/system/login.pl')) {
              final result = (await controller.runJavaScriptReturningResult(



              "if (typeof SHOWWEBVIEWtoFlutter !== 'undefined' && typeof USERNAMEtoFlutter !== 'undefined' && typeof PASSWORDtoFlutter !== 'undefined'){"
                "window.onbeforeunload = function (e) {USERNAMEtoFlutter.postMessage(document.getElementById('credential_0').value); PASSWORDtoFlutter.postMessage(document.getElementById('credential_1').value);};"
                "setTimeout(function() {SHOWWEBVIEWtoFlutter.postMessage('SHOW');}, 330);"

                "try {"
                  "document.getElementById('hlavicka').style.display='none';"
                  "document.getElementById('horni-navigace').style.display='none';"
                      //"document.getElementById('titulek').style.display='none';"
                  "document.getElementsByClassName('mainpage')[0].getElementsByTagName('nav')[0].style.display='none';"
                  "document.getElementsByClassName('mainpage')[0].getElementsByClassName('small')[0].style.display='none'; "
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
                  "document.getElementsByTagName('table')[0].style.margin = 0;"

                  "document.querySelector('.loginform-section:last-of-type').style.display='none';"

                  "document.getElementsByClassName('mainpage')[0].querySelectorAll('form ~ div').forEach(element => {element.style.display='none';});"
//"document.getElementsByClassName('mainpage')[0].style.display='none';"
                  "document.getElementById('foot').style.display='none';"





                "true;} catch (error) {console.error(error); false;}"
              "} else {false;}"

              )).toString();
              print("RESULT form");
              print(result);
              if (result == "false") {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR when connecting to is.mendelu.cz, please try again.")));
                Navigator.of(context).pop();
              }
            }

            if(url.contains("https://is.mendelu.cz/auth/")) {
              // two redirects when logging in -> first can be undefined
              final result = (await controller.runJavaScriptReturningResult("if (typeof LOGGEDINtoFlutter !== 'undefined' && document.getElementById('prihlasen') != null) {LOGGEDINtoFlutter.postMessage(document.getElementById('prihlasen').firstChild.data.trim()); true;} else {false;}")).toString();
              print("RESULT");
              print(result);
              if (result == "false") {
/*                await Future<void>.delayed(const Duration(milliseconds: 300));
                final result2 = (await controller.runJavaScriptReturningResult("var loggedInterv = setInterval(function() {if (typeof LOGGEDINtoFlutter !== 'undefined' && document.getElementById('prihlasen') != null) {clearInterval(loggedInterv); LOGGEDINtoFlutter.postMessage(document.getElementById('prihlasen').firstChild.data.trim()); true;} else {false;}}, 300);")).toString();
                print("RESULT2");
                print(result2);
                await Future<void>.delayed(const Duration(milliseconds: 1000));
*/
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("ERROR when logging in to is.mendelu.cz, please try again.")));
                Navigator.of(context).pop();
              }
              /*String result = (await controller.runJavaScriptReturningResult("document.getElementById('prihlasen').firstChild.data.trim();")).toString();
              result = result.replaceAll('"', '');
              if (result != '') {
                dataLoggedin = result.split(":")[1].trim();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Prihlasen: $dataLoggedin")));
                Navigator.of(context).pop();
              }*/
            }
            if (mounted) {
              setState(() {
                loadingPercentage = 100;
              });
            }
          },
          onNavigationRequest: (navigation) {
            if (kDebugMode) {
              print("URL: ${navigation.url}");
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
      )
      ..addJavaScriptChannel(
        'USERNAMEtoFlutter',
        onMessageReceived: (message) {
          dataUsername = message.message;
        },
      )
      ..addJavaScriptChannel(
        'PASSWORDtoFlutter',
        onMessageReceived: (message) {
          dataPassword = message.message;
        },
      )
      ..addJavaScriptChannel(
        'LOGGEDINtoFlutter',
        onMessageReceived: (message) async {
          if (message.message != '') {
            dataLoggedin = message.message.split(":")[1].trim();

            // Create storage
            const storage = FlutterSecureStorage();
            await storage.write(key: "Mfullname", value: dataLoggedin);
            await storage.write(key: "Musername", value: dataUsername);
            await storage.write(key: "Mpassword", value: dataPassword);


            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Prihlasen: $dataLoggedin")));
            Navigator.of(context).pop();
          }
        },
      );
    controller.loadRequest(Uri.parse('https://is.mendelu.cz/system/login.pl'));
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
