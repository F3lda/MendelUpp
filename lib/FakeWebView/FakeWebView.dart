import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'package:flutter/services.dart';

class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(PlatformWebViewControllerCreationParams params) {
    return _FakeWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(PlatformWebViewWidgetCreationParams params) {
    return _FakeWebViewWidget(params);
  }
}

class _FakeWebViewController extends PlatformWebViewController {
  _FakeWebViewController(super.params) : super.implementation();

  final content = ValueNotifier('');

  @override
  Future<void> loadFlutterAsset(String key) async {
    content.value = await rootBundle.loadString(key);
  }
}

class _FakeWebViewWidget extends PlatformWebViewWidget {
  _FakeWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) {
    final content = (params.controller as _FakeWebViewController).content;
    return ColoredBox(
      color: Colors.red,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: ValueListenableBuilder(
          valueListenable: content,
          builder: (context, content, _) {
            return Text(
              content,
              style: const TextStyle(
                fontFamily: 'courier',
                fontSize: 10,
                color: Colors.yellow,
              ),
              softWrap: true,
            );
          },
        ),
      ),
    );
  }
}