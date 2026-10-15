import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: kPrimarySwatch,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.surface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.surface),
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: kPrimarySwatch).copyWith(
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      textTheme: TextTheme(
        titleLarge: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF071018),
        elevation: 0,
      ),
      colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark, primarySwatch: kPrimarySwatch).copyWith(
        secondary: AppColors.accent,
      ),
    );
  }
}
