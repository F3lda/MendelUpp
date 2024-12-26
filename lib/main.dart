import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'Pages/my_home_page.dart';
import 'Common/change_notifiers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'FakeWebView/FakeWebView.dart';

//flutter packages get -> to get packages
//flutter pub add webview_flutter -> to install package

//flutter build apk --release
//flutter run --release --> install release app
//https://github.com/juliansteenbakker/flutter_secure_storage/issues/748

// icons
// pubspec.yml -> flutter_launcher_icons:
// flutter pub run flutter_launcher_icons (to generate new icons)


void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Counter>(create: (context) => Counter()),
      ChangeNotifierProvider<PageLevelCounter>(create: (context) => PageLevelCounter()),
      ChangeNotifierProvider<OffStageNotify>(create: (context) => OffStageNotify()),
      ChangeNotifierProvider<AppThemeChangeNotify>(create: (context) => AppThemeChangeNotify()),
    ],
    child: const MyApp(),
  ),);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //const MyApp({super.key});
  //ThemeMode _themeMode = ThemeMode.system;


  static void themeChange() {
    return;
  }
  /*void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }*/

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
      // Some android/ios specific code
      //https://www.reddit.com/r/FlutterDev/comments/1ciezf4/faking_a_webview_on_desktop_platforms_is_easier/
      //WebViewPlatform.instance = FakeWebViewPlatform();
    }
    return  Consumer<AppThemeChangeNotify>(
      builder: (context, change, child) => MaterialApp(
        title: 'MendelUpp',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7abf17)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: const Color(0xFF7abf17)),
          useMaterial3: true,
        ), // standard dark theme
        themeMode: change.themeMode, // device controls theme
        home: const MyHomePage(title: 'MendelUpp', callback: themeChange),
        debugShowCheckedModeBanner: false,
        )
      );

  }
}
