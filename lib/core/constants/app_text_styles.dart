import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ✍️ Badelha Design System - Unified Cairo Typography
class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Cairo',
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Cairo',
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Cairo',
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
    fontFamily: 'Cairo',
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    fontFamily: 'Cairo',
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
    fontFamily: 'Cairo',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textMuted,
    fontFamily: 'Cairo',
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    fontFamily: 'Cairo',
  );
}
