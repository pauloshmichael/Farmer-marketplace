import 'package:flutter/material.dart';
import '../app/theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  
  ThemeData get themeData => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
    }
  }
}