import 'package:flutter/material.dart';
import 'Pages/home_page.dart';
import 'Common/change_notifiers.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';


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
      ChangeNotifierProvider<AppThemeChangeNotify>(create: (context) => AppThemeChangeNotify()),
    ],
    child: const MyApp(),
  ),);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return  Consumer<AppThemeChangeNotify>(
      builder: (context, change, child) => MaterialApp(
        title: 'PeasUpp',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7abf17)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: const Color(0xFF7abf17)),
          useMaterial3: true,
        ), // standard dark theme
        themeMode: change.themeMode, // app theme controls
        home: const HomePage(title: 'PeasUpp'),
        debugShowCheckedModeBanner: false,
      )
    );
  }
}
// TODO replace load request with JS window.location.replace('url');
