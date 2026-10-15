import 'package:flutter/material.dart';

class ThemeState {
  final ThemeMode mode;

  ThemeState({required this.mode});

  bool get isDark => mode == ThemeMode.dark;
}
