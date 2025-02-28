import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewPopScope extends StatelessWidget {
  const WebViewPopScope({ super.key, required this.child, required this.controller });

  final Widget child;
  final WebViewController controller;

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
      child: child
    );
  }
}
