import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary color (used for AppBar, buttons, etc.)
  static const Color primary = Color(0xFF0A84FF);
  static const Color primaryVariant = Color(0xFF0060DF);

  // Accent / secondary
  static const Color accent = Color(0xFFFFC107);

  // Background & surfaces
  static const Color background = Color(0xFFF7F7F8);
  static const Color surface = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
}

/// A MaterialColor for use as `primarySwatch` in ThemeData.
/// Adjust the shades to match your brand if needed.
final MaterialColor kPrimarySwatch = const MaterialColor(
  0xFF0A84FF,
  <int, Color>{
    50: Color(0xFFEAF4FF),
    100: Color(0xFFCCE9FF),
    200: Color(0xFF99D4FF),
    300: Color(0xFF66BFFF),
    400: Color(0xFF339AFF),
    500: Color(0xFF0A84FF), // primary
    600: Color(0xFF0973E6),
    700: Color(0xFF0762CC),
    800: Color(0xFF0551B3),
    900: Color(0xFF033F80),
  },
);