// AppConfigService - Handles assets and preferences
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../Libs/main_services_provider.dart';

class ConfigService extends AppStartupService {
  @override
  String get serviceName => 'ConfigService';

  Map<String, dynamic> _config = {};
  late SharedPreferencesAsync _prefsAsync;

  Map<String, dynamic> get config => Map.unmodifiable(_config);

  @override
  Future<void> initialize() async {
    _prefsAsync = SharedPreferencesAsync();
    //await resetPreferences();
    await _loadFromAssets();
    await _loadFromPreferences();
    //setPreference('theme_mode', 'dark');
  }

  Future<void> _loadFromAssets() async {
    try {
      // Load default config from assets/config.json
      String configString = await rootBundle.loadString('assets/config.json');
      Map<String, dynamic> assetConfig = json.decode(configString);
      _config.addAll(assetConfig);
    } catch (e) {
      print('No asset config found, using defaults: $e');
      // Fallback to default configuration
      _config.addAll({
        'app_version': '1.0.0',
        'api_base_url': 'https://api.example.com',
        'app_name': 'My Flutter App',
        'default_theme': 'light',
        'supported_languages': ['en', 'es', 'fr'],
        'max_cache_size': 50 * 1024 * 1024, // 50MB
      });
    }
  }

  Future<void> _loadFromPreferences() async {
    try {
      // Load all config from single JSON string
      String? configJson = await _prefsAsync.getString('app_config');
      if (configJson != null) {
        Map<String, dynamic> savedConfig = json.decode(configJson);
        _config.addAll(savedConfig);
        print('Loaded app config from preferences');
      } else {
        // Set default preferences if none exist
        _setDefaultPreferences();
      }
    } catch (e) {
      print('Failed to load preferences, using defaults: $e');
      _setDefaultPreferences();
    }
  }

  void _setDefaultPreferences() {
    // Default user preferences
    /*_config.addAll({
      'theme_mode': 'system',
      'notifications_enabled': true,
      'analytics_enabled': false,
      'language': 'en',
      'font_size': 14.0,
      'sound_enabled': true,
    });*/
  }

  Future<void> _saveAllPreferences() async {
    try {
      // Filter out asset-based config, only save user preferences
      /*final userSettings = [
        'theme_mode',
        'notifications_enabled',
        'analytics_enabled',
        'language',
        'font_size',
        'sound_enabled'
      ];

      Map<String, dynamic> preferencesToSave = {};
      for (String key in userSettings) {
        if (_config.containsKey(key)) {
          preferencesToSave[key] = _config[key];
        }
      }

      // Save as single JSON string
      String configJson = json.encode(preferencesToSave);
      await _prefsAsync.setString('app_config', configJson);
      print('Saved app config to preferences');*/
    } catch (e) {
      print('Failed to save preferences: $e');
    }
  }

  T get<T>(String key) {
    if (!_config.containsKey(key)) {
      throw ArgumentError('Configuration key "$key" not found');
    }

    final value = _config[key];
    if (value is! T) {
      throw StateError('Configuration key "$key" expected type $T but got ${value.runtimeType}');
    }

    return value as T;
  }

  Future<void> setPreference(String key, dynamic value) async {
    _config[key] = value;
    await _saveAllPreferences();
  }

  Future<void> setMultiplePreferences(Map<String, dynamic> preferences) async {
    _config.addAll(preferences);
    await _saveAllPreferences();
  }

  Future<void> resetPreferences() async {
    await _prefsAsync.remove('app_config');
    _setDefaultPreferences();
    await _saveAllPreferences();
  }
}

// Updated extension for accessing both services
extension MainServicesExtension on BuildContext {
  ConfigService get appConfigService => getService<ConfigService>();
}

/*
// Example usage class showing how to use both services
class ConfigExample {
  static void demonstrateUsage(BuildContext context) {
    final appConfig = context.appConfigService;
    final serverConfig = context.serverConfigService;

    // App configuration (assets + preferences) - no null checks needed
    String theme = appConfig.get<String>('theme_mode');
    bool notifications = appConfig.get<bool>('notifications_enabled');
    String appVersion = appConfig.get<String>('app_version');

    // Server configuration (network + local cache) - no null checks needed
    bool newUiEnabled = serverConfig.isFeatureEnabled('new_ui_enabled');
    bool isMaintenanceMode = serverConfig.isMaintenanceMode;
    int apiTimeout = serverConfig.get<int>('api_timeout');

    // Update single preference
    appConfig.setPreference('theme_mode', 'dark');

    // Update multiple preferences at once
    appConfig.setMultiplePreferences({
      'theme_mode': 'dark',
      'notifications_enabled': false,
      'language': 'es',
    });

    // Refresh server config
    serverConfig.refreshFromNetwork();

    // Error handling example
    try {
      String unknownKey = appConfig.get<String>('non_existent_key');
    } catch (e) {
      print('Configuration error: $e');
    }
  }
}
*/
