import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';


Future<void> launchInBrowser(BuildContext context, Uri url) async {
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $url')));
  }
}

Future<void> loadHtmlFromAssets(String filename, WebViewController controller) async {
  String htmlText = await rootBundle.loadString(filename);
  controller.loadRequest(Uri.dataFromString(htmlText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')));
}