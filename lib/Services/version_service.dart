// VersionService - Handles app version changes and migration tasks
/*import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mendelupp/Libs/main_services_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionService extends AppStartupService {
  @override
  String get serviceName => 'version';

  static const String _lastVersionKey = 'last_app_version';
  static const String _firstRunKey = 'first_run';
  static const String _installDateKey = 'install_date';

  late SharedPreferencesAsync _prefsAsync;
  late PackageInfo _packageInfo;

  String? _lastVersion;
  String? _currentVersion;
  bool _isFirstRun = false;
  bool _isVersionUpgrade = false;
  bool _isVersionDowngrade = false;

  // Getters
  String? get lastVersion => _lastVersion;
  String? get currentVersion => _currentVersion;
  bool get isFirstRun => _isFirstRun;
  bool get isVersionUpgrade => _isVersionUpgrade;
  bool get isVersionDowngrade => _isVersionDowngrade;
  bool get isVersionChanged => _isVersionUpgrade || _isVersionDowngrade;

  @override
  Future<void> initialize() async {
    _prefsAsync = SharedPreferencesAsync();
    await _loadPackageInfo();
    await _checkVersionStatus();
    await _performVersionMigrations();
    await _saveCurrentVersion();
  }

  Future<void> _loadPackageInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      _currentVersion = _packageInfo.version;
      print('Current app version: $_currentVersion');
    } catch (e) {
      print('Failed to load package info: $e');
      _currentVersion = '1.0.0'; // Fallback version
    }
  }

  Future<void> _checkVersionStatus() async {
    try {
      _lastVersion = await _prefsAsync.getString(_lastVersionKey);
      bool hasRunBefore = await _prefsAsync.getBool(_firstRunKey) ?? false;

      if (!hasRunBefore || _lastVersion == null) {
        _isFirstRun = true;
        await _prefsAsync.setBool(_firstRunKey, true);
        await _prefsAsync.setString(_installDateKey, DateTime.now().toIso8601String());
        print('First run detected');
      } else {
        _isFirstRun = false;
        _isVersionUpgrade = _isVersionNewer(_currentVersion!, _lastVersion!);
        _isVersionDowngrade = _isVersionNewer(_lastVersion!, _currentVersion!);

        if (_isVersionUpgrade) {
          print('Version upgrade detected: $_lastVersion -> $_currentVersion');
        } else if (_isVersionDowngrade) {
          print('Version downgrade detected: $_lastVersion -> $_currentVersion');
        } else {
          print('Same version: $_currentVersion');
        }
      }
    } catch (e) {
      print('Failed to check version status: $e');
      _isFirstRun = true;
    }
  }

  bool _isVersionNewer(String version1, String version2) {
    try {
      List<int> v1Parts = version1.split('.').map(int.parse).toList();
      List<int> v2Parts = version2.split('.').map(int.parse).toList();

      // Pad with zeros if needed
      while (v1Parts.length < 3) v1Parts.add(0);
      while (v2Parts.length < 3) v2Parts.add(0);

      for (int i = 0; i < 3; i++) {
        if (v1Parts[i] > v2Parts[i]) return true;
        if (v1Parts[i] < v2Parts[i]) return false;
      }
      return false; // Equal versions
    } catch (e) {
      print('Error comparing versions: $e');
      return false;
    }
  }

  Future<void> _performVersionMigrations() async {
    try {
      if (_isFirstRun) {
        await _handleFirstRun();
      } else if (_isVersionUpgrade) {
        await _handleVersionUpgrade();
      } else if (_isVersionDowngrade) {
        await _handleVersionDowngrade();
      }
    } catch (e) {
      print('Error performing version migrations: $e');
    }
  }

  Future<void> _handleFirstRun() async {
    print('Performing first run setup...');

    // Clear any existing data from previous installations
    await _clearAllPreferences();

    // Set up initial defaults
    await _setInitialDefaults();

    print('First run setup completed');
  }

  Future<void> _handleVersionUpgrade() async {
    print('Performing version upgrade from $_lastVersion to $_currentVersion...');

    // Define version-specific upgrade logic
    if (_shouldClearCacheOnUpgrade()) {
      await _clearApiCache();
    }

    if (_shouldResetUserPreferencesOnUpgrade()) {
      await _clearUserPreferences();
    }

    // Example: specific version migrations
    if (_lastVersion == '1.0.0' && _currentVersion == '1.1.0') {
      await _migrateFrom1_0_0To1_1_0();
    }

    if (_isVersionNewer(_currentVersion!, '2.0.0') && _isVersionNewer('2.0.0', _lastVersion!)) {
      await _migrateToVersion2_0_0();
    }

    print('Version upgrade completed');
  }

  Future<void> _handleVersionDowngrade() async {
    print('Performing version downgrade from $_lastVersion to $_currentVersion...');

    // Handle downgrade scenarios
    if (_shouldClearDataOnDowngrade()) {
      await _clearAllPreferences();
      await _setInitialDefaults();
    }

    print('Version downgrade completed');
  }

  // Helper methods for migration decisions
  bool _shouldClearCacheOnUpgrade() {
    // Clear cache for major version changes
    final lastMajor = int.tryParse(_lastVersion?.split('.').first ?? '0') ?? 0;
    final currentMajor = int.tryParse(_currentVersion?.split('.').first ?? '0') ?? 0;
    return currentMajor > lastMajor;
  }

  bool _shouldResetUserPreferencesOnUpgrade() {
    // Reset preferences for specific version jumps
    return _lastVersion == '1.0.0' || _lastVersion == '1.1.0';
  }

  bool _shouldClearDataOnDowngrade() {
    // Always clear data on downgrade to prevent compatibility issues
    return true;
  }

  // Migration methods
  Future<void> _clearAllPreferences() async {
    try {
      final allKeys = await _prefsAsync.getKeys();
      final keysToKeep = [_lastVersionKey, _firstRunKey, _installDateKey];

      for (final key in allKeys) {
        if (!keysToKeep.contains(key)) {
          await _prefsAsync.remove(key);
        }
      }
      print('Cleared all preferences except version tracking');
    } catch (e) {
      print('Failed to clear preferences: $e');
    }
  }

  Future<void> _clearApiCache() async {
    try {
      final allKeys = await _prefsAsync.getKeys();
      for (final key in allKeys) {
        if (key.startsWith('api_cache_')) {
          await _prefsAsync.remove(key);
        }
      }
      print('Cleared API cache');
    } catch (e) {
      print('Failed to clear API cache: $e');
    }
  }

  Future<void> _clearUserPreferences() async {
    try {
      final userPrefKeys = ['app_config', 'user_id', 'user_name', 'user_role', 'is_logged_in'];
      for (final key in userPrefKeys) {
        await _prefsAsync.remove(key);
      }
      print('Cleared user preferences');
    } catch (e) {
      print('Failed to clear user preferences: $e');
    }
  }

  Future<void> _setInitialDefaults() async {
    try {
      // Set any initial default values
      await _prefsAsync.setString('app_config', json.encode({
        'theme_mode': 'system',
        'notifications_enabled': true,
        'analytics_enabled': false,
        'language': 'en',
        'font_size': 14.0,
        'sound_enabled': true,
      }));
      print('Set initial defaults');
    } catch (e) {
      print('Failed to set initial defaults: $e');
    }
  }

  // Specific version migration examples
  Future<void> _migrateFrom1_0_0To1_1_0() async {
    print('Migrating from 1.0.0 to 1.1.0...');
    // Example: rename old preference keys
    try {
      String? oldTheme = await _prefsAsync.getString('theme');
      if (oldTheme != null) {
        await _prefsAsync.setString('theme_mode', oldTheme);
        await _prefsAsync.remove('theme');
      }
    } catch (e) {
      print('Migration 1.0.0 -> 1.1.0 failed: $e');
    }
  }

  Future<void> _migrateToVersion2_0_0() async {
    print('Migrating to version 2.0.0...');
    // Example: major changes requiring data restructure
    try {
      await _clearApiCache();
      // Add new required fields, restructure data, etc.
    } catch (e) {
      print('Migration to 2.0.0 failed: $e');
    }
  }

  Future<void> _saveCurrentVersion() async {
    try {
      await _prefsAsync.setString(_lastVersionKey, _currentVersion!);
      print('Saved current version: $_currentVersion');
    } catch (e) {
      print('Failed to save current version: $e');
    }
  }

  // Public utility methods
  Future<DateTime?> getInstallDate() async {
    try {
      String? installDateStr = await _prefsAsync.getString(_installDateKey);
      return installDateStr != null ? DateTime.parse(installDateStr) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> forceVersionMigration() async {
    await _performVersionMigrations();
  }

  Map<String, dynamic> getVersionInfo() {
    return {
      'current_version': _currentVersion,
      'last_version': _lastVersion,
      'is_first_run': _isFirstRun,
      'is_version_upgrade': _isVersionUpgrade,
      'is_version_downgrade': _isVersionDowngrade,
      'app_name': _packageInfo.appName,
      'package_name': _packageInfo.packageName,
      'build_number': _packageInfo.buildNumber,
    };
  }
}

extension MainServicesExtension on BuildContext {
  VersionService get versionService => getService<VersionService>();
}


   final version = context.versionService;

    // Version management
    if (version.isFirstRun) {
      print('Welcome! This is your first time using the app.');
    } else if (version.isVersionUpgrade) {
      print('App updated from ${version.lastVersion} to ${version.currentVersion}');
    }

    Map<String, dynamic> versionInfo = version.getVersionInfo();
    DateTime? installDate = await version.getInstallDate();
    print('App installed on: $installDate')

    // Force version migration if needed
    await version.forceVersionMigration();
*/
