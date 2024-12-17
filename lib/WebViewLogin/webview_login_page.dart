import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  String dataJS = "";


  @override
  void initState() {
    super.initState();
    controller = WebViewController()..loadRequest(Uri.parse('https://is.mendelu.cz/system/login.pl'));
    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            if (url.contains('https://is.mendelu.cz/system/login.pl')) {
              //Added delayed future method for wait for the website to load fully before calling javascript
              //Future.delayed(Duration(milliseconds: 900), () {
                controller.runJavaScriptReturningResult(
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
"flutterViewPort.content = 'width=100, initial-scale=1.0, maximum-scale=1.0, user-scalable=1';"
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

                        "window.onbeforeunload = function (e) {MSGtoFlutter.postMessage('Name: '+document.getElementById('credential_0').value+' Password: '+document.getElementById('credential_1').value);};"
                );
                setState(() {hideWebView = false;});
              //});
            }
            setState(() {
              loadingPercentage = 100;
            });
          },
          onNavigationRequest: (navigation) {
            if (kDebugMode) {
              print("URL: ${navigation.url}");
            }

            if(navigation.url.contains("https://is.mendelu.cz/auth/?lang=en")) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(dataJS)));
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'MSGtoFlutter',
        onMessageReceived: (message) {
          dataJS = message.message;
        },
      );
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
