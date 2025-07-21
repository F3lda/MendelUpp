// Configuration service
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Libs/main_services_provider.dart';

class ConfigService extends AppStartupService {
  @override
  String get serviceName => 'config';

  Map<String, dynamic> _config = {};

  Map<String, dynamic> get config => Map.unmodifiable(_config);

  @override
  Future<void> initialize() async {
    // Load configuration from various sources
    await _loadFromPreferences();
    await _loadFromAssets();
    await _loadFromNetwork();
  }

  Future<void> _loadFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _config['theme_mode'] = prefs.getString('theme_mode') ?? 'system';
    _config['notifications_enabled'] = prefs.getBool('notifications_enabled') ?? true;
    _config['analytics_enabled'] = prefs.getBool('analytics_enabled') ?? false;
  }

  Future<void> _loadFromAssets() async {
    // Load default config from assets/config.json
    try {
      // String configString = await rootBundle.loadString('assets/config.json');
      // Map<String, dynamic> assetConfig = json.decode(configString);
      // _config.addAll(assetConfig);

      // Placeholder for asset-based config
      _config['app_version'] = '1.0.0';
      _config['api_base_url'] = 'https://api.example.com';
    } catch (e) {
      print('No asset config found: $e');
    }
  }

  Future<void> _loadFromNetwork() async {
    // Load remote configuration
    try {
      // Simulate network call
      await Future.delayed(Duration(milliseconds: 500));
      _config['feature_flags'] = {
        'new_ui_enabled': true,
        'experimental_features': false,
      };
    } catch (e) {
      print('Failed to load remote config: $e');
    }
  }

  T? get<T>(String key) {
    return _config[key] as T?;
  }

  Future<void> set(String key, dynamic value) async {
    _config[key] = value;

    // Save to preferences if it's a user setting
    if (['theme_mode', 'notifications_enabled', 'analytics_enabled'].contains(key)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      }
    }
  }
}

// Main extension for accessing services and data
extension MainServicesExtension on BuildContext {
  // Service getters with intuitive names
  ConfigService get configService => getService<ConfigService>();
}
