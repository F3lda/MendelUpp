import 'package:flutter/material.dart';

class Counter with ChangeNotifier {
  int value = 0;

  void increment() {
    value += 1;
    notifyListeners();
  }
  int getValue() {
    return value;
  }
}

class PageLevelCounter with ChangeNotifier {
  int value = 0;

  void increment() {
    value += 1;
    notifyListeners();
  }
  void decrement() {
    value -= 1;
    notifyListeners();
  }
  int getValue() {
    return value;
  }
}

class OffStageNotify with ChangeNotifier {
  bool value = false;

  void toggle() {
    value = !value;
    notifyListeners();
  }
  bool getValue() {
    return value;
  }
}

class AppThemeChangeNotify with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  void toggle() {
    if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }
    notifyListeners();
  }
  ThemeMode getValue() {
    return themeMode;
  }
}