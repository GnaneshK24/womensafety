import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final String? themeModeString = _prefs?.getString(_themeKey);
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeString,
      );
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefs?.setString(_themeKey, _themeMode.toString());
    notifyListeners();
  }
}
