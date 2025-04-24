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


class WebViewGuestStudent extends StatefulWidget {
  const WebViewGuestStudent({super.key});

  @override
  State<WebViewGuestStudent> createState() => _WebViewGuestStudent();
}

class _WebViewGuestStudent extends State<WebViewGuestStudent> {
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

    loadHtmlFromAssets('assets/webviews_guest/rozvrh.html', controller);
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
              title: const Text('Student Portal Mendelu'),
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
            ),
            bottomNavigationBar: (!hideWebView) ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: IconButton(tooltip: 'Rozvrh hodin', icon: Icon(Icons.schedule), onPressed: () {
                    loadHtmlFromAssets('assets/webviews_guest/rozvrh.html', controller);
                  },),),
                  Expanded(child: IconButton(tooltip: 'Moje předměty', icon: Icon(Icons.view_list), onPressed: () {
                    loadHtmlFromAssets('assets/webviews_guest/predmety.html', controller);
                  },),),
                  Expanded(child: IconButton(tooltip: 'Odevzdávárna', icon: Icon(Icons.drive_folder_upload), onPressed: () {
                    loadHtmlFromAssets('assets/webviews_guest/odevzdavarna.html', controller);
                  },),),
                  Expanded(child: IconButton(tooltip: 'Přihlašování na zkoušky', icon: Icon(Icons.school), onPressed: () {
                    loadHtmlFromAssets('assets/webviews_guest/zkousky.html', controller);
                  },),),
                  Expanded(child: IconButton(tooltip: 'Registrace předmětů', icon: Icon(Icons.checklist), onPressed: () {
                    loadHtmlFromAssets('assets/webviews_guest/reg_predmetu.html', controller);
                  },),),
                  Expanded(child: IconButton(tooltip: 'E-index', icon: Icon(Icons.explicit_outlined), onPressed: () {
                    loadHtmlFromAssets('assets/webviews_guest/e-index.html', controller);
                  },),),
                ],
              ),
            ) : null,
        )
    );
  }
}
