
// ServerConfigService - Handles network config and local caching
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Libs/main_services_provider.dart';

class ServerConfigService extends AppStartupService {
  @override
  String get serviceName => 'server_config';

  Map<String, dynamic> _config = {};
  late SharedPreferencesAsync _prefsAsync;

  Map<String, dynamic> get config => Map.unmodifiable(_config);

  @override
  Future<void> initialize() async {
    _prefsAsync = SharedPreferencesAsync();
    await _loadFromPreferences();
    await _loadFromNetwork();
  }

  Future<void> _loadFromPreferences() async {
    try {
      String? configJson = await _prefsAsync.getString('server_config');
      if (configJson != null) {
        Map<String, dynamic> savedConfig = json.decode(configJson);
        _config.addAll(savedConfig);
        print('Loaded server config from preferences');
      } else {
        // Set fallback config if none exists
        await _loadFallbackConfig();
      }
    } catch (e) {
      print('Failed to load server config from preferences: $e');
      await _loadFallbackConfig();
    }
  }

  Future<void> _loadFromNetwork() async {
    try {
      // Replace with your actual server endpoint
      final response = await http.get(
        Uri.parse('https://api.example.com/config'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        Map<String, dynamic> networkConfig = json.decode(response.body);
        _config.addAll(networkConfig);
        await _saveToPreferences();
        print('Loaded server config from network');
      } else {
        print('Failed to load server config: ${response.statusCode}');
        if (_config.isEmpty) {
          await _loadFallbackConfig();
        }
      }
    } catch (e) {
      print('Network error loading server config: $e');
      if (_config.isEmpty) {
        await _loadFallbackConfig();
      }
    }
  }

  Future<void> _loadFallbackConfig() async {
    // Fallback configuration when network fails and no cached config exists
    _config.addAll({
      'feature_flags': {
        'new_ui_enabled': true,
        'experimental_features': false,
        'dark_mode_available': true,
        'premium_features': false,
      },
      'server_maintenance': false,
      'min_app_version': '1.0.0',
      'force_update': false,
      'api_timeout': 30,
      'retry_attempts': 3,
      'cache_duration': 3600, // 1 hour in seconds
    });
  }

  Future<void> _saveToPreferences() async {
    try {
      String configJson = json.encode(_config);
      await _prefsAsync.setString('server_config', configJson);
      print('Server config saved to preferences');
    } catch (e) {
      print('Failed to save server config to preferences: $e');
    }
  }

  Future<void> refreshFromNetwork() async {
    await _loadFromNetwork();
  }

  T get<T>(String key) {
    if (!_config.containsKey(key)) {
      throw ArgumentError('Server configuration key "$key" not found');
    }

    final value = _config[key];
    if (value is! T) {
      throw StateError('Server configuration key "$key" expected type $T but got ${value.runtimeType}');
    }

    return value as T;
  }

  bool get isMaintenanceMode => get<bool>('server_maintenance');

  Map<String, dynamic> get featureFlags =>
      get<Map<String, dynamic>>('feature_flags');

  bool isFeatureEnabled(String featureName) {
    return featureFlags[featureName] ?? false;
  }

  Future<void> clearServerConfig() async {
    try {
      await _prefsAsync.remove('server_config');
      _config.clear();
      print('Server config cleared from preferences');
    } catch (e) {
      print('Failed to clear server config: $e');
    }
  }
}

// Updated extension for accessing both services
extension MainServicesExtension on BuildContext {
  ServerConfigService get serverConfigService => getService<ServerConfigService>();
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
