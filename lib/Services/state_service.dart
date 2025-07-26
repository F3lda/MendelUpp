// AppStateService - Handles API calls with offline caching and user state
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Libs/main_services_provider.dart';
/*
class StateService extends AppStartupService {
  @override
  String get serviceName => 'app_state';

  static const String apiUrl = 'https://api.example.com';
  static const String _cachePrefix = 'api_cache_';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _isLoggedInKey = 'is_logged_in';

  late SharedPreferencesAsync _prefsAsync;
  bool _isOffline = false;
  String? _userId;
  String? _userName;
  String? _userRole;
  bool _isUserLoggedIn = false;

  // Getters
  bool get isOffline => _isOffline;
  String? get userId => _userId;
  String? get userName => _userName;
  String? get userRole => _userRole;
  bool get isUserLoggedin => _isUserLoggedIn;

  @override
  Future<void> initialize() async {
    _prefsAsync = SharedPreferencesAsync();
    await _loadUserState();
    await _checkServerConnection();
  }

  Future<void> _loadUserState() async {
    try {
      _userId = await _prefsAsync.getString(_userIdKey);
      _userName = await _prefsAsync.getString(_userNameKey);
      _userRole = await _prefsAsync.getString(_userRoleKey);
      _isUserLoggedIn = await _prefsAsync.getBool(_isLoggedInKey) ?? false;
      print('Loaded user state: loggedIn=$_isUserLoggedIn, userId=$_userId');
    } catch (e) {
      print('Failed to load user state: $e');
    }
  }

  Future<void> _checkServerConnection() async {
    try {
      // Use CHECK_SERVER command to verify server connectivity
      final response = await http.get(
        Uri.parse('$apiUrl/CHECK_SERVER'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        _isOffline = false;
        print('Server is online');
      } else {
        _isOffline = true;
        print('Server returned error: ${response.statusCode}');
      }
    } catch (e) {
      _isOffline = true;
      print('Server is offline: $e');
    }
  }

  Future<Map<String, dynamic>> callApi(String cmd, Map<String, dynamic>? data) async {
    final cacheKey = '$_cachePrefix$cmd';

    if (!_isOffline) {
      // Try to fetch from server
      try {
        final response = await _fetchFromServer(cmd, data);

        // Cache successful response
        await _cacheResponse(cacheKey, response);
        return response;
      } catch (e) {
        print('API call failed, falling back to cache: $e');
        // Fall back to cached data if server call fails
        return await _loadFromCache(cacheKey) ?? _getErrorResponse('Server error: $e');
      }
    } else {
      // Load from cache when offline
      print('Offline mode: loading $cmd from cache');
      return await _loadFromCache(cacheKey) ?? _getErrorResponse('No cached data available for $cmd');
    }
  }

  Future<Map<String, dynamic>> _fetchFromServer(String cmd, Map<String, dynamic>? data) async {
    final url = Uri.parse('$apiUrl/$cmd');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': _isUserLoggedIn && _userId != null ? 'Bearer $_userId' : '',
    };

    final response = await http.post(
      url,
      headers: headers,
      body: data != null ? json.encode(data) : null,
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      print('API call successful: $cmd');
      return responseData;
    } else {
      throw HttpException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> _cacheResponse(String cacheKey, Map<String, dynamic> response) async {
    try {
      final responseJson = json.encode(response);
      await _prefsAsync.setString(cacheKey, responseJson);
      print('Cached response for key: $cacheKey');
    } catch (e) {
      print('Failed to cache response: $e');
    }
  }

  Future<Map<String, dynamic>?> _loadFromCache(String cacheKey) async {
    try {
      final cachedJson = await _prefsAsync.getString(cacheKey);
      if (cachedJson != null) {
        final cachedData = json.decode(cachedJson) as Map<String, dynamic>;
        print('Loaded from cache: $cacheKey');
        return cachedData;
      }
    } catch (e) {
      print('Failed to load from cache: $e');
    }
    return null;
  }

  Map<String, dynamic> _getErrorResponse(String message) {
    return {
      'success': false,
      'error': message,
      'cached': true,
    };
  }

  // User management methods
  Future<void> loginUser({
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    _userId = userId;
    _userName = userName;
    _userRole = userRole;
    _isUserLoggedIn = true;

    await _saveUserState();
    print('User logged in: $userName ($userRole)');
  }

  Future<void> logoutUser() async {
    _userId = null;
    _userName = null;
    _userRole = null;
    _isUserLoggedIn = false;

    await _saveUserState();
    await _clearUserCache();
    print('User logged out');
  }

  Future<void> _saveUserState() async {
    try {
      await _prefsAsync.setString(_userIdKey, _userId ?? '');
      await _prefsAsync.setString(_userNameKey, _userName ?? '');
      await _prefsAsync.setString(_userRoleKey, _userRole ?? '');
      await _prefsAsync.setBool(_isLoggedInKey, _isUserLoggedIn);
    } catch (e) {
      print('Failed to save user state: $e');
    }
  }

  Future<void> _clearUserCache() async {
    try {
      // Get all keys and remove those with our cache prefix
      final allKeys = await _prefsAsync.getKeys();
      for (final key in allKeys) {
        if (key.startsWith(_cachePrefix)) {
          await _prefsAsync.remove(key);
        }
      }
      print('Cleared user cache');
    } catch (e) {
      print('Failed to clear user cache: $e');
    }
  }

  // Utility methods
  Future<void> clearCache() async {
    await _clearUserCache();
  }

  Future<void> clearSpecificCache(String cmd) async {
    try {
      final cacheKey = '$_cachePrefix$cmd';
      await _prefsAsync.remove(cacheKey);
      print('Cleared cache for: $cmd');
    } catch (e) {
      print('Failed to clear cache for $cmd: $e');
    }
  }

  Future<bool> hasCachedData(String cmd) async {
    try {
      final cacheKey = '$_cachePrefix$cmd';
      final cachedData = await _prefsAsync.getString(cacheKey);
      return cachedData != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshServerStatus() async {
    await _checkServerConnection();
  }
}

extension MainServicesExtension on BuildContext {
  AppStateService get stateService => getService<StateService>();
}
*/
// Example usage class showing how to use all services
/*class ConfigExample {
  static void demonstrateUsage(BuildContext context) async {
    final appState = context.stateService;

    // App state and API calls
    bool isOffline = appState.isOffline;
    bool isLoggedIn = appState.isUserLoggedin;
    String? currentUser = appState.userName;

    // Login user
    await appState.loginUser(
      userId: '12345',
      userName: 'John Doe',
      userRole: 'admin',
    );

    // Make API calls (automatically handles online/offline)
    try {
      Map<String, dynamic> userProfile = await appState.callApi(
        'user/profile',
        {'user_id': appState.userId},
      );

      Map<String, dynamic> dashboardData = await appState.callApi(
        'dashboard/data',
        null,
      );

      print('User profile: $userProfile');
      print('Dashboard: $dashboardData');
    } catch (e) {
      print('API error: $e');
    }

    // Check connectivity and cache
    await appState.refreshServerStatus();
    bool hasUserData = await appState.hasCachedData('user/profile');

    // Logout user
    await appState.logoutUser();
  }
}*/
