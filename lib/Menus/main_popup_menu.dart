import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mendelupp/Services/localization_service.dart';
import 'package:mendelupp/Services/theme_service.dart';

import '../WebViewLogin/webview_login_page.dart';


enum _MenuOptions {
  themeMode,
  languageSwitch,
  loginLogout,
}

class MainPopupMenu extends StatefulWidget {
  const MainPopupMenu({super.key, required this.onLoginStateChange, required this.loggedInUsername});

  final String loggedInUsername;
  final Future<void> Function() onLoginStateChange;

  @override
  State<MainPopupMenu> createState() => _MenuState2();
}

class _MenuState2 extends State<MainPopupMenu> {

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuOptions>(
      position: PopupMenuPosition.under,
      onSelected: (value) async {
        switch (value) {
          case _MenuOptions.themeMode:
            context.themeService.toggleTheme(context);
            break;

          case _MenuOptions.languageSwitch:
            // switch CZ and EN languages
            context.localizationService.saveLocale(context, (context.localizationService.currentLocale == const Locale('en')) ? const Locale('cs') : const Locale('en'));
            break;

          case _MenuOptions.loginLogout:
            if (widget.loggedInUsername == '') { // if not logged in -> login
              if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                // Some android/ios specific code
                Navigator.push(context, MaterialPageRoute(builder: (context) => const WebViewLoginPage())).then((value) async {
                  widget.onLoginStateChange();
                });
              }
            } else { // if already logged in -> logout
              const storage = FlutterSecureStorage();
              await storage.write(key: "Mfullname", value: "");
              await storage.write(key: "Musername", value: "");
              await storage.write(key: "Mpassword", value: "");
              widget.onLoginStateChange();
            }
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.themeMode,
          child: Text('${context.tr('dropdown_menu.toggle_theme', params : {'theme' : context.themeService.getCurrentThemeName(context)})} '), // space at the end because of right padding
        ),
        PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.languageSwitch,
          child: Text(context.tr('dropdown_menu.switch_language')),
        ),
        PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.loginLogout,
          child: (widget.loggedInUsername == '') ? Text(context.tr('dropdown_menu.login')) : Text(context.tr('dropdown_menu.logout')),
        ),
      ],
    );
  }
}
