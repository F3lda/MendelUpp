import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class AppThemeChangeNotify with ChangeNotifier {

  ThemeMode themeMode = ThemeMode.system;
  Map<ThemeMode,String> themeModes = {ThemeMode.system : 'System', ThemeMode.light : 'Light', ThemeMode.dark : 'Dark'};

  toggleTheme(BuildContext context) {
    if (themeMode == ThemeMode.system) {
      themeMode = ThemeMode.light;
    } else if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }
    notifyListeners();

    // save to SharedPreferences
    SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    asyncPrefs.setInt('theme_mode', themeMode.index);
  }

  Future<ThemeMode> loadCurrentTheme() async {
    // load from SharedPreferences
    SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    ThemeMode savedThemeMode = ThemeMode.values[(await asyncPrefs.getInt("theme_mode")) ?? ThemeMode.system.index];
    bool savedThemeModeExists = await asyncPrefs.containsKey("theme_mode");
    if (savedThemeModeExists && savedThemeMode != themeMode) {
      themeMode = savedThemeMode;
      notifyListeners();
    }

    return themeMode;
  }

  String getCurrentThemeName(BuildContext context) {
    if (themeMode == ThemeMode.system) {
      return (Theme.of(context).brightness == Brightness.light ? '${themeModes[ThemeMode.system]??''} (${themeModes[ThemeMode.light]??''})' : '${themeModes[ThemeMode.system]??''} (${themeModes[ThemeMode.dark]??''})');
    } else if (themeMode == ThemeMode.light) {
      return themeModes[ThemeMode.light] ?? '';
    } else if (themeMode == ThemeMode.dark)  {
      return themeModes[ThemeMode.dark] ?? '';
    }
    return '';
  }
}

// Main extension for accessing services and data
extension ChangeNotifiersExtension on BuildContext {
  // Service getters with intuitive names
  AppThemeChangeNotify get themeNotifier => read<AppThemeChangeNotify>(); //import 'package:provider/provider.dart'; // Add this import
  //context.read<AppThemeChangeNotify>().toggleTheme(context);
}
