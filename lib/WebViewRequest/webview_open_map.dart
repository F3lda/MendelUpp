import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../WebView/webview_popscope.dart';


class WebViewMapPage extends StatefulWidget {
  const WebViewMapPage({super.key});

  @override
  State<WebViewMapPage> createState() => _WebViewMapPageState();
}

class _WebViewMapPageState extends State<WebViewMapPage> {
  late final WebViewController controller;
  var loadingPercentage = 0;
  bool hideWebView = true;

  bool webviewError = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController();
    controller..setNavigationDelegate(
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

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ERROR when connecting to https://mm.mendelu.cz/mapwidget, probably no internet connection.")));
              Navigator.of(context).pop();
            });
          },
          onPageFinished: (url) async {
            if (kDebugMode) {
              print("URL: ${url}");
            }

            if (webviewError) {return;}

            controller.runJavaScriptReturningResult("setTimeout(function() {SHOWWEBVIEWtoFlutter.postMessage('SHOW');}, 330);");

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
    controller.loadRequest(Uri.parse('https://mm.mendelu.cz/mapwidget'));
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
          title: const Text('Map Mendelu'),
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
      )
    );
  }
}
