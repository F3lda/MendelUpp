// User service
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Libs/main_services_provider.dart';

class ThemeService extends AppStartupService {
  @override
  String get serviceName => 'ThemeService';

  ThemeMode get themeMode => _themeMode;

  ThemeMode _themeMode = ThemeMode.system;
  Map<ThemeMode,String> themeModes = {ThemeMode.system : 'System', ThemeMode.light : 'Light', ThemeMode.dark : 'Dark'};

  @override
  Future<void> initialize() async {
    // load from SharedPreferences
    SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    ThemeMode savedThemeMode = ThemeMode.values[(await asyncPrefs.getInt("theme_mode")) ?? ThemeMode.system.index];
    bool savedThemeModeExists = await asyncPrefs.containsKey("theme_mode");
    if (savedThemeModeExists && savedThemeMode != _themeMode) {
      _themeMode = savedThemeMode;
    }
  }

  String getCurrentThemeName(BuildContext context) {
    if (themeMode == ThemeMode.system) {
      return (MediaQuery.of(context).platformBrightness == Brightness.light ? '${themeModes[ThemeMode.system]??''} (${themeModes[ThemeMode.light]??''})' : '${themeModes[ThemeMode.system]??''} (${themeModes[ThemeMode.dark]??''})');
    } else if (themeMode == ThemeMode.light) {
      return themeModes[ThemeMode.light] ?? '';
    } else if (themeMode == ThemeMode.dark)  {
      return themeModes[ThemeMode.dark] ?? '';
    }
    return '';
  }

  void toggleTheme(BuildContext context) {
    if (themeMode == ThemeMode.system) {
      _themeMode = ThemeMode.light;
    } else if (themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    // save to SharedPreferences
    SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    asyncPrefs.setInt('theme_mode', themeMode.index);

    // Trigger rebuild
    context.serviceChanged();
  }
}

// Main extension for accessing services and data
extension MainServicesExtension on BuildContext {
  // Service getters with intuitive names
  ThemeService get themeService => getService<ThemeService>();
}
