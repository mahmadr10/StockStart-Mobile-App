// lib/theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider _instance = ThemeProvider._internal();
  factory ThemeProvider() => _instance;
  ThemeProvider._internal();

  bool _isDark = true;
  bool get isDark => _isDark;

  void setDark(bool value) {
    _isDark = value;
    notifyListeners();
  }

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }
}