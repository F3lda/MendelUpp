// Analytics service
import 'package:flutter/material.dart';

import '../Libs/main_services_provider.dart';

class AnalyticsService extends AppStartupService {
  @override
  String get serviceName => 'analytics';

  bool _isInitialized = false;
  Map<String, dynamic> _userProperties = {};

  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    try {
      // Simulate analytics SDK initialization
      await Future.delayed(Duration(milliseconds: 200));
      _isInitialized = true;
      print('Analytics service initialized');
    } catch (e) {
      print('Failed to initialize analytics: $e');
    }
  }

  void track(String eventName, [Map<String, dynamic>? properties]) {
    if (!_isInitialized) return;

    print('Analytics Event: $eventName');
    if (properties != null) {
      print('Properties: $properties');
    }
  }

  void setUserProperties(Map<String, dynamic> properties) {
    _userProperties.addAll(properties);
    print('User properties updated: $_userProperties');
  }

  @override
  void dispose() {
    _isInitialized = false;
    _userProperties.clear();
    super.dispose();
  }
}

// Main extension for accessing services and data
extension MainServicesExtension on BuildContext {
  // Service getters with intuitive names
  AnalyticsService get analyticsService => getService<AnalyticsService>();
}
