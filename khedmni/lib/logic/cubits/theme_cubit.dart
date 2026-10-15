import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const _prefKey = 'theme_mode';

  ThemeCubit() : super(ThemeState(mode: ThemeMode.system));

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefKey);
      if (stored != null) {
        emit(ThemeState(mode: _fromString(stored)));
      }
    } catch (e) {
      // If loading fails, keep default system theme
      print('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme(bool dark) async {
    try {
      final mode = dark ? ThemeMode.dark : ThemeMode.light;
      // Emit immediately for responsive UI
      emit(ThemeState(mode: mode));
      // Then persist to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, _toString(mode));
    } catch (e) {
      print('Error saving theme: $e');
      // If saving fails, the UI still updates
    }
  }

  ThemeMode _fromString(String s) {
    switch (s) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      default:
        return 'system';
    }
  }
}
