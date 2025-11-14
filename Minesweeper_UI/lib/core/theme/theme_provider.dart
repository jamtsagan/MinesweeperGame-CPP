// lib/core/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

// 这是一个 ChangeNotifier，当它的状态改变时，可以通知监听它的 Widget
class ThemeProvider with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.darkTheme; // 默认是暗黑主题

  AppTheme get currentTheme => _currentTheme;

  void toggleTheme() {
    if (_currentTheme == AppTheme.darkTheme) {
      _currentTheme = AppTheme.lightTheme;
    } else {
      _currentTheme = AppTheme.darkTheme;
    }
    notifyListeners(); // 【核心】通知所有监听者：“主题变了，快重绘！”
  }
}