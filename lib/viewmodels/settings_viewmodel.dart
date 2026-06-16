import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  // Nilai default sesuai dengan desain Anda
  bool notifyLowStock = true;
  bool notifyOutOfStock = true;
  bool notifyExpiry = false;
  bool notifyDailySummary = true;
  bool notifyActivity = false;
  bool methodPush = true;
  bool methodEmail = false;
  String language = 'id';
  bool isDarkMode = false;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    notifyLowStock = prefs.getBool('notifyLowStock') ?? true;
    notifyOutOfStock = prefs.getBool('notifyOutOfStock') ?? true;
    notifyExpiry = prefs.getBool('notifyExpiry') ?? false;
    notifyDailySummary = prefs.getBool('notifyDailySummary') ?? true;
    notifyActivity = prefs.getBool('notifyActivity') ?? false;
    methodPush = prefs.getBool('methodPush') ?? true;
    methodEmail = prefs.getBool('methodEmail') ?? false;
    language = prefs.getString('language') ?? 'id';
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    // Update state lokal
    switch (key) {
      case 'notifyLowStock':
        notifyLowStock = value;
        break;
      case 'notifyOutOfStock':
        notifyOutOfStock = value;
        break;
      case 'notifyExpiry':
        notifyExpiry = value;
        break;
      case 'notifyDailySummary':
        notifyDailySummary = value;
        break;
      case 'notifyActivity':
        notifyActivity = value;
        break;
      case 'methodPush':
        methodPush = value;
        break;
      case 'methodEmail':
        methodEmail = value;
        break;
      case 'language':
        language = value as String;
        await prefs.setString(key, language);
        break;
      case 'isDarkMode':
        isDarkMode = value;
        await prefs.setBool(key, isDarkMode);
        break;
    }
    notifyListeners();
  }
}
