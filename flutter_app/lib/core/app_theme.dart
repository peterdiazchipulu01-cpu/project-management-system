import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF6366F1);
  static const danger = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const sidebarBg = Color(0xFF111113);
  static const priorityLow = Color(0xFF22C55E);
  static const priorityMedium = Color(0xFFF59E0B);
  static const priorityHigh = Color(0xFFEF4444);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F4F5),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0B),
      );
}
