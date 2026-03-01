import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Manages dark/light mode preference.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void loadTheme() {
    _isDarkMode = StorageService.getDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }
}
