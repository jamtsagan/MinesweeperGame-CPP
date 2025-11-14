// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

// 我们使用 abstract class 作为命名空间，防止这个类被意外实例化
abstract class AppColors {
  // 暗黑主题的“颜料”
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimary = Colors.deepPurple;
  static const Color darkTileHidden = Color(0xFF424242);
  static const Color darkTileRevealed = Color(0xFF303030);

  // 亮白主题的“颜料”
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightPrimary = Colors.blue;
  static const Color lightTileHidden = Color(0xFFBDBDBD);
  static const Color lightTileRevealed = Color(0xFFE0E0E0);

  // 通用颜色
  static const Color mineColor = Colors.red;
  static const Color flagColor = Colors.orange;
  static const Color numberColor = Colors.blueAccent;
}