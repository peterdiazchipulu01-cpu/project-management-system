import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/project_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/project_sidebar.dart';
import '../screens/empty_state_screen.dart';
import '../screens/project_board_screen.dart';
import '../screens/team_screen.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProject = ref.watch(selectedProjectProvider);
    final themeAsync = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider).value ?? const AppSettings();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.sidebarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: const Text(
          'Project Management',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => showTeamScreen(context),
            icon: const Icon(Icons.people_outline,
                color: Colors.white60, size: 18),
            label: const Text('Team',
                style: TextStyle(color: Colors.white60, fontSize: 13)),
          ),
          const SizedBox(width: 4),
          themeAsync.when(
            loading: () => const SizedBox(width: 44),
            error: (_, __) => const SizedBox(width: 44),
            data: (mode) => IconButton(
              icon: Icon(
                mode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: Colors.white60,
              ),
              tooltip: mode == ThemeMode.dark
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              onPressed: () => ref.read(themeProvider.notifier).toggle(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white60),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const SettingsScreen(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: settings.compactSidebar ? 160 : 220,
            child: const ProjectSidebar(),
          ),
          Expanded(
            child: selectedProject == null
                ? const EmptyStateScreen()
                : ProjectBoardScreen(project: selectedProject),
          ),
        ],
      ),
    );
  }
}
