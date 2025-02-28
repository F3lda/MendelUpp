import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


Future<void> launchInBrowser(BuildContext context, Uri url) async {
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $url')));
  }
}
