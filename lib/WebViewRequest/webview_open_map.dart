import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../WebView/web_view_test_controls.dart';
import '../WebView/web_view_test_menu.dart';


class WebViewMapPage extends StatefulWidget {
  const WebViewMapPage({super.key});

  @override
  State<WebViewMapPage> createState() => _WebViewMapPageState();
}


class _WebViewMapPageState extends State<WebViewMapPage> {
  late final WebViewController controller;
  var loadingPercentage = 0;
  bool hideWebView = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController();
    controller..setNavigationDelegate(
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

            controller.runJavaScriptReturningResult("setTimeout(function() {SHOWWEBVIEWtoFlutter.postMessage('SHOW');}, 330);");

            if (mounted) {
              setState(() {
                loadingPercentage = 100;
              });
            }
          },
          onNavigationRequest: (navigation) {

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
    controller.loadRequest(Uri.parse('https://mm.mendelu.cz/mapwidget'));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            final messenger = ScaffoldMessenger.of(context);
            if (await controller.canGoBack()) {
              await controller.goBack();
            } else {
              messenger.showSnackBar(const SnackBar(content: Text('No back history item')));
            }
          }
        },
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const CloseButtonIcon()
              ),
              title: const Text('Map Mendelu'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              /*actions: [
                NavigationControls(controller: controller),
                //Menu(controller: controller),
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
        )
    );
  }
}
