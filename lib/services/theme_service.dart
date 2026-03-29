// lib/services/theme_service.dart
// Handles light/dark mode toggle + persistence

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.dark;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'light') {
      _mode = ThemeMode.light;
    } else {
      _mode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> toggle() async {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setDark() async {
    _mode = ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'dark');
    notifyListeners();
  }

  Future<void> setLight() async {
    _mode = ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'light');
    notifyListeners();
  }
}