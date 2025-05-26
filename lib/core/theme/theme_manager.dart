import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _updateSystemUIOverlay();
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      // If system mode, toggle to opposite of current system setting
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      setThemeMode(brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
    }
  }

  void setSystemTheme() {
    setThemeMode(ThemeMode.system);
  }

  void setLightTheme() {
    setThemeMode(ThemeMode.light);
  }

  void setDarkTheme() {
    setThemeMode(ThemeMode.dark);
  }

  void _updateSystemUIOverlay() {
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    final statusBarBrightness = isDarkMode ? Brightness.light : Brightness.dark;
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: statusBarBrightness,
        statusBarIconBrightness: statusBarBrightness,
        systemNavigationBarColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
        systemNavigationBarIconBrightness: statusBarBrightness,
      ),
    );
  }

  // Initialize theme on app start
  void initialize() {
    _updateSystemUIOverlay();
  }
}