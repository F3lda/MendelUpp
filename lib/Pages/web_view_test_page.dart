import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../WebView/web_view_test_menu.dart';                               // ADD
import '../WebView/web_view_test_controls.dart';
import '../WebView/web_view_test_stack.dart';



class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()..loadRequest(Uri.parse('https://is.mendelu.cz/auth/'));
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
            messenger.showSnackBar(
                const SnackBar(content: Text('No back history item')));
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const CloseButtonIcon()
          ),
          title: const Text('WebView'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            NavigationControls(controller: controller),
            Menu(controller: controller),
          ],
        ),
        body: SafeArea(child: WebViewStack(controller: controller)),
      )
    );
  }
}