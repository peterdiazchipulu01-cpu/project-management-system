import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends AsyncNotifier<ThemeMode> {
  @override
  Future<ThemeMode> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkMode') ?? false ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final current = state.value ?? ThemeMode.light;
    final isDark = current == ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', !isDark);
    state = AsyncData(!isDark ? ThemeMode.dark : ThemeMode.light);
  }
}

final themeProvider =
    AsyncNotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
