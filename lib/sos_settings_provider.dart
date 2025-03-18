import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SOSSettingsProvider with ChangeNotifier {
  bool _policeCallEnabled = false;
  bool get policeCallEnabled => _policeCallEnabled;

  SOSSettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _policeCallEnabled = prefs.getBool('police_call_enabled') ?? false;
    notifyListeners();
  }

  Future<void> togglePoliceCall(bool value) async {
    _policeCallEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('police_call_enabled', value);
    notifyListeners();
  }
} 