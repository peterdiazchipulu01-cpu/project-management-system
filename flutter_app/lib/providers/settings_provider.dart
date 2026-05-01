import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const accentColors = [
  Color(0xFF6366F1), // Indigo (default)
  Color(0xFF3B82F6), // Blue
  Color(0xFF22C55E), // Green
  Color(0xFFF59E0B), // Amber
  Color(0xFFEF4444), // Red
  Color(0xFF8B5CF6), // Purple
  Color(0xFF06B6D4), // Cyan
  Color(0xFFF97316), // Orange
];

const accentColorNames = [
  'Indigo', 'Blue', 'Green', 'Amber', 'Red', 'Purple', 'Cyan', 'Orange',
];

class AppSettings {
  final int accentColorIndex;
  final bool compactSidebar;
  final bool showDashboardOnLaunch;

  const AppSettings({
    this.accentColorIndex = 0,
    this.compactSidebar = false,
    this.showDashboardOnLaunch = true,
  });

  Color get accentColor => accentColors[accentColorIndex];

  AppSettings copyWith({
    int? accentColorIndex,
    bool? compactSidebar,
    bool? showDashboardOnLaunch,
  }) =>
      AppSettings(
        accentColorIndex: accentColorIndex ?? this.accentColorIndex,
        compactSidebar: compactSidebar ?? this.compactSidebar,
        showDashboardOnLaunch:
            showDashboardOnLaunch ?? this.showDashboardOnLaunch,
      );
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      accentColorIndex: prefs.getInt('accentColorIndex') ?? 0,
      compactSidebar: prefs.getBool('compactSidebar') ?? false,
      showDashboardOnLaunch: prefs.getBool('showDashboardOnLaunch') ?? true,
    );
  }

  Future<void> setAccentColor(int index) async {
    final current = state.value ?? const AppSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accentColorIndex', index);
    state = AsyncData(current.copyWith(accentColorIndex: index));
  }

  Future<void> toggleCompactSidebar() async {
    final current = state.value ?? const AppSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('compactSidebar', !current.compactSidebar);
    state = AsyncData(current.copyWith(compactSidebar: !current.compactSidebar));
  }

  Future<void> toggleShowDashboard() async {
    final current = state.value ?? const AppSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showDashboardOnLaunch', !current.showDashboardOnLaunch);
    state = AsyncData(
        current.copyWith(showDashboardOnLaunch: !current.showDashboardOnLaunch));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
