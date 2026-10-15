import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:khedmni/logic/cubits/theme_cubit.dart';

void main() {
  test('theme persistence toggles and loads', () async {
    SharedPreferences.setMockInitialValues({});
    final cubit = ThemeCubit();
    await cubit.loadTheme();
    // default should be system
    expect(cubit.state.mode, ThemeMode.system);

    await cubit.toggleTheme(true);
    expect(cubit.state.mode, ThemeMode.dark);

    // new cubit should read persisted value
    final cubit2 = ThemeCubit();
    await cubit2.loadTheme();
    expect(cubit2.state.mode, ThemeMode.dark);
  });
}
