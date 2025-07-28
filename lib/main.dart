import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mendelupp/Services/config_service.dart';
import 'Libs/main_services_provider.dart';
import 'Pages/home_page.dart';
import 'ChangeNotifiers/app_theme_change_notify.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

import 'Services/localization_service.dart';
import 'Services/theme_service.dart';


//flutter packages get -> to get packages
//flutter pub add webview_flutter -> to install package

//flutter build apk --release
//flutter run --release --> install release app
//https://github.com/juliansteenbakker/flutter_secure_storage/issues/748

// icons
// pubspec.yml -> flutter_launcher_icons:
// flutter pub run flutter_launcher_icons (to generate new icons)


void main() {
  runApp(
    /*MultiProvider(
      providers: [
        //ChangeNotifierProvider<AppThemeChangeNotify>(create: (context) => AppThemeChangeNotify()),
      ],
      child: const MyApp(),
    )*/
    const MyApp()
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MainWidgetServicesProvider(
      services: [ // Register all your app startup services
        LocalizationService(),
        ThemeService(),
        ConfigService() // TODO use (colors, assets URIs, URLS, constants...)
      ],
      child: Builder(
        builder: (context) {
          // Wait for app initialization
          if (!context.isAppInitialized) {

            return MaterialApp(
              title: 'Loading...',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: Colors.grey),
                useMaterial3: true,
              ), // standard dark theme
              themeMode: ThemeMode.system, // app theme controls
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              debugShowCheckedModeBanner: false,
            );

          }

          Color appColor = Color(int.tryParse(context.appConfigService.get<String>('app_color')) ?? 0);
          return MaterialApp(
            //title: 'PeasUpp',
            title: context.localizationService.translate('app.title'),
            locale: context.localizationService.currentLocale,
            supportedLocales: context.localizationService.supportedLocales,
            localizationsDelegates: [ // flutter pub add flutter_localizations --sdk=flutter // assets folder must be added in pubspec.yml
              ServiceBasedAppLocalizationsDelegate(context.localizationService.isLocaleSupported, context.localizationService.changeLocale),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: appColor),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(brightness: Brightness.dark, seedColor: appColor),
              useMaterial3: true,
            ), // standard dark theme
            themeMode: context.themeService.themeMode, // app theme controls
            home: HomePage(),
            debugShowCheckedModeBanner: false,
          );

        },
      ),
    );
  }
}

// TODO replace load request with JS window.location.replace('url'); in webviews
