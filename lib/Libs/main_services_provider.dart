import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Base class for any app startup service
abstract class AppStartupService {
  String get serviceName;
  Future<void> initialize();
  void dispose() {}
}

// InheritedWidget for services and rebuild function
class MainServicesInheritedWidget extends InheritedWidget {
  final Map<String, AppStartupService> services;
  final bool isInitialized;
  final VoidCallback serviceChanged;
  final int lastUpdated;

  const MainServicesInheritedWidget({
    super.key,
    required this.services,
    required this.isInitialized,
    required this.serviceChanged,
    required this.lastUpdated,
    required super.child,
  });

  static MainServicesInheritedWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainServicesInheritedWidget>();
  }

  @override
  bool updateShouldNotify(MainServicesInheritedWidget oldWidget) {
    return isInitialized != oldWidget.isInitialized ||
        lastUpdated != oldWidget.lastUpdated;
  }
}

// Main provider widget that manages app startup and global state
class MainWidgetServicesProvider extends StatefulWidget {
  final Widget child;
  final List<AppStartupService> services;

  const MainWidgetServicesProvider({
    super.key,
    required this.child,
    this.services = const [],
  });

  @override
  MainWidgetServicesProviderState createState() => MainWidgetServicesProviderState();

  static T getService<T extends AppStartupService>(BuildContext context) {
    final widget = MainServicesInheritedWidget.of(context);
    if (widget == null) {
      throw FlutterError(
        'MainServicesProvider.getService() called with a context that does not contain a MainServicesProvider.\n'
            'Make sure your app is wrapped with MainServicesProvider.',
      );
    }

    final service = widget.services.values.firstWhere(
          (service) => service is T,
      orElse: () => throw FlutterError('Service of type $T not found. Available services: ${widget.services.keys.join(", ")}'),
    );
    return service as T;
  }

  static bool isInitialized(BuildContext context) {
    final widget = MainServicesInheritedWidget.of(context);
    if (widget == null) {
      throw FlutterError(
        'MainServicesProvider.isInitialized() called with a context that does not contain a MainServicesProvider.',
      );
    }
    return widget.isInitialized;
  }

  static void serviceChanged(BuildContext context) {
    final widget = MainServicesInheritedWidget.of(context);
    if (widget == null) {
      throw FlutterError(
        'MainServicesProvider.serviceChanged() called with a context that does not contain a MainServicesProvider.',
      );
    }
    widget.serviceChanged();
  }
}

class MainWidgetServicesProviderState extends State<MainWidgetServicesProvider> {
  late Map<String, AppStartupService> _services;
  bool _isInitialized = false;
  int _lastUpdated = DateTime.now().microsecondsSinceEpoch;

  // This is the function that will be passed down via InheritedWidget
  void _serviceChanged() {
    setState(() {
      // Update timestamp to force rebuild
      _lastUpdated = DateTime.now().microsecondsSinceEpoch;
    });
  }

  @override
  void initState() {
    super.initState();
    _services = {for (var service in widget.services) service.serviceName: service};
    _initialize();
  }

  @override
  void dispose() {
    // Dispose all services
    for (var service in _services.values) {
      service.dispose();
    }
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      // Initialize all services in parallel
      await Future.wait(
        _services.values.map((service) => service.initialize()),
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error during app initialization: $e');
      // Handle initialization error - could show error screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainServicesInheritedWidget(
      services: _services,
      isInitialized: _isInitialized,
      serviceChanged: _serviceChanged,
      lastUpdated: _lastUpdated,
      child: widget.child,
    );
  }
}

// Main extension for accessing services and rebuild
extension MainServicesExtensionDefault on BuildContext {
  T getService<T extends AppStartupService>() => MainWidgetServicesProvider.getService<T>(this);

  bool get isAppInitialized => MainWidgetServicesProvider.isInitialized(this);

  void serviceChanged() {
    MainWidgetServicesProvider.serviceChanged(this);
  }
}
