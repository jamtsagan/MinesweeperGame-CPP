// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

// 这是我们的主题“模型”，定义了所有UI元素需要用到的“语义化”颜色
@immutable // 表示这个类的实例一旦创建，就不可改变
class AppTheme {
  final Color background;
  final Color surface;
  final Color primary;
  final Color tileHidden;
  final Color tileRevealed;
  final Color mineColor;
  final Color flagColor;
  final Color numberColor;
  final Brightness brightness;

  const AppTheme({
    required this.background,
    required this.surface,
    required this.primary,
    required this.tileHidden,
    required this.tileRevealed,
    required this.mineColor,
    required this.flagColor,
    required this.numberColor,
    required this.brightness,
  });

  // --- 在这里，我们创建具体的“调色盘”实例 ---

  // 暗黑主题
  static final AppTheme darkTheme = AppTheme(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    primary: AppColors.darkPrimary,
    tileHidden: AppColors.darkTileHidden,
    tileRevealed: AppColors.darkTileRevealed,
    mineColor: AppColors.mineColor,
    flagColor: AppColors.flagColor,
    numberColor: AppColors.numberColor,
    brightness: Brightness.dark,
  );

  // 亮白主题
  static final AppTheme lightTheme = AppTheme(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    primary: AppColors.lightPrimary,
    tileHidden: AppColors.lightTileHidden,
    tileRevealed: AppColors.lightTileRevealed,
    mineColor: AppColors.mineColor,
    flagColor: AppColors.flagColor,
    numberColor: AppColors.numberColor,
    brightness: Brightness.light,
  );
}
