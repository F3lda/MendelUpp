// User service
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Libs/main_services_provider.dart';

class UserService extends AppStartupService {
  @override
  String get serviceName => 'user';

  Map<String, dynamic>? _userProfile;
  bool _isAuthenticated = false;

  Map<String, dynamic>? get profile => _userProfile;
  bool get isAuthenticated => _isAuthenticated;
  String? get name => _userProfile?['name'];
  String? get email => _userProfile?['email'];
  String? get id => _userProfile?['id'];

  @override
  Future<void> initialize() async {
    await _checkAuthStatus();
    if (_isAuthenticated) {
      await _loadUserProfile();
    }
  }

  Future<void> _checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    _isAuthenticated = token != null && token.isNotEmpty;
  }

  Future<void> _loadUserProfile() async {
    // Simulate loading user profile
    await Future.delayed(Duration(milliseconds: 300));
    _userProfile = {
      'id': '12345',
      'name': 'John Doe',
      'email': 'john@example.com',
      'avatar_url': 'https://example.com/avatar.jpg',
    };
  }

  Future<void> signIn(String email, String password) async {
    // Simulate sign in
    await Future.delayed(Duration(seconds: 1));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', 'fake_token_123');

    _isAuthenticated = true;
    await _loadUserProfile();
  }

  Future<void> signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    _isAuthenticated = false;
    _userProfile = null;
  }
}

// Main extension for accessing services and data
extension MainServicesExtension on BuildContext {
  // Service getters with intuitive names
  UserService get userService => getService<UserService>();
}
