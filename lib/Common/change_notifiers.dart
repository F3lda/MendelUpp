import 'package:flutter/material.dart';


class AppThemeChangeNotify with ChangeNotifier {
  //ThemeMode themeMode = ThemeMode.system;
  ThemeMode themeMode = ThemeMode.light;

  void toggleTheme(BuildContext context) {
    if (themeMode == ThemeMode.system) {
      themeMode = Theme.of(context).brightness == Brightness.light ? ThemeMode.light : ThemeMode.dark;
    }
    if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }
    notifyListeners();
    // TODO save to SharedPreferences
  }

  ThemeMode getCurrentTheme() {
    // TODO load from SharedPreferences
    return themeMode;
  }
}
