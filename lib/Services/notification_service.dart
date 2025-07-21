// Notification service
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Libs/main_services_provider.dart';

class NotificationService extends AppStartupService {
  @override
  String get serviceName => 'notifications';

  bool _isPermissionGranted = false;
  List<Map<String, dynamic>> _pendingNotifications = [];

  bool get isPermissionGranted => _isPermissionGranted;
  List<Map<String, dynamic>> get pending => List.unmodifiable(_pendingNotifications);

  @override
  Future<void> initialize() async {
    await _requestPermission();
    await _loadPendingNotifications();
  }

  Future<void> _requestPermission() async {
    // Simulate permission request
    await Future.delayed(Duration(milliseconds: 100));
    _isPermissionGranted = true; // Assume granted for demo
    print('Notification permission granted: $_isPermissionGranted');
  }

  Future<void> _loadPendingNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('pending_notifications') ?? [];

    _pendingNotifications = notifications.map((notif) {
      // In real app, you'd decode JSON here
      return {'id': notif, 'title': 'Sample Notification'};
    }).toList();
  }

  Future<void> schedule({
    required String id,
    required String title,
    required String body,
    DateTime? scheduledTime,
  }) async {
    if (!_isPermissionGranted) return;

    final notification = {
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime?.toIso8601String(),
    };

    _pendingNotifications.add(notification);

    // Save to preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications = _pendingNotifications.map((n) => n['id'] as String).toList();
    await prefs.setStringList('pending_notifications', notifications);

    print('Notification scheduled: $title');
  }

  Future<void> cancel(String id) async {
    _pendingNotifications.removeWhere((notif) => notif['id'] == id);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications = _pendingNotifications.map((n) => n['id'] as String).toList();
    await prefs.setStringList('pending_notifications', notifications);
  }
}

// Main extension for accessing services and data
extension MainServicesExtension on BuildContext {
  // Service getters with intuitive names
  NotificationService get notificationService => getService<NotificationService>();
}
