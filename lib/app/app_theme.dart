import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFFFF8EE);
  static const card = Color(0xFFFFFFFF);
  static const primary = Color(0xFFC9252E);
  static const title = Color(0xFF6F1515);
  static const textPrimary = Color(0xFF3D1B18);
  static const textSecondary = Color(0xFF815F54);
  static const accent = Color(0xFFD6A15C);
  static const border = Color(0xFFE9D9C7);
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      surface: AppColors.card,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'NotoSansSC',
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontFamily: 'NotoSerifSC',
          fontSize: 32,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: AppColors.title,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'NotoSerifSC',
          fontSize: 24,
          height: 1.25,
          fontWeight: FontWeight.w700,
          color: AppColors.title,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          height: 1.4,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
