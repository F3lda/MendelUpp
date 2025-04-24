import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path/path.dart' as p;

import '../Common/utils.dart';
import '../WebView/webview_popscope.dart';


class WebViewGuestMenza extends StatefulWidget {
  const WebViewGuestMenza({super.key});

  @override
  State<WebViewGuestMenza> createState() => _WebViewGuestMenza();
}

class _WebViewGuestMenza extends State<WebViewGuestMenza> {
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

    loadHtmlFromAssets('assets/webviews_guest/iskam-menza.html', controller);
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
