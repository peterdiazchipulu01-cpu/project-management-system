import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/supabase_config.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings/settings_form.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeAsync = ref.watch(themeProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.value ?? const AppSettings();
    final isDark = themeAsync.value == ThemeMode.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.5, -0.6),
                radius: 1.4,
                colors: [Color(0xFF0D1525), Color(0xFF060B18)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Appearance'),
                        const SizedBox(height: 12),
                        _glassCard(
                          child: Column(
                            children: [
                              _themeRow(ref, isDark),
                              _divider(),
                              _accentColorRow(ref, settings),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _sectionLabel('Display'),
                        const SizedBox(height: 12),
                        _glassCard(
                          child: Column(
                            children: [
                              _toggleRow(
                                icon: Icons.dashboard_outlined,
                                iconColor: const Color(0xFF6366F1),
                                title: 'Show Safety Dashboard on Launch',
                                subtitle:
                                    'Display the safety checklist screen when the app starts',
                                value: settings.showDashboardOnLaunch,
                                onChanged: (_) => ref
                                    .read(settingsProvider.notifier)
                                    .toggleShowDashboard(),
                              ),
                              _divider(),
                              _toggleRow(
                                icon: Icons.view_sidebar_outlined,
                                iconColor: const Color(0xFF3B82F6),
                                title: 'Compact Sidebar',
                                subtitle:
                                    'Reduce sidebar width to show more project content',
                                value: settings.compactSidebar,
                                onChanged: (_) => ref
                                    .read(settingsProvider.notifier)
                                    .toggleCompactSidebar(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _sectionLabel('Company Settings'),
                        const SizedBox(height: 12),
                        _glassCard(
                          child: const SettingsForm(orgId: defaultOrgId),
                        ),
                        const SizedBox(height: 24),
                        _sectionLabel('About'),
                        const SizedBox(height: 12),
                        _glassCard(
                          child: Column(
                            children: [
                              _infoRow(
                                icon: Icons.shield_outlined,
                                iconColor: const Color(0xFF22C55E),
                                title: 'SafeOps · PMS',
                                value: 'v1.0.0',
                              ),
                              _divider(),
                              _infoRow(
                                icon: Icons.storage_outlined,
                                iconColor: const Color(0xFFF59E0B),
                                title: 'Backend',
                                value: 'Supabase',
                              ),
                              _divider(),
                              _infoRow(
                                icon: Icons.code_outlined,
                                iconColor: const Color(0xFF8B5CF6),
                                title: 'Framework',
                                value: 'Flutter',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white70, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.settings_outlined,
              color: Color(0xFF6366F1), size: 20),
          const SizedBox(width: 10),
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeRow(WidgetRef ref, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: const Color(0xFFF59E0B),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme Mode',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(isDark ? 'Dark mode active' : 'Light mode active',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12)),
              ],
            ),
          ),
          _themeToggle(ref, isDark),
        ],
      ),
    );
  }

  Widget _themeToggle(WidgetRef ref, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _themeChip('Light', !isDark, Icons.light_mode_outlined, () {
          if (isDark) ref.read(themeProvider.notifier).toggle();
        }),
        const SizedBox(width: 6),
        _themeChip('Dark', isDark, Icons.dark_mode_outlined, () {
          if (!isDark) ref.read(themeProvider.notifier).toggle();
        }),
      ],
    );
  }

  Widget _themeChip(
      String label, bool selected, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF6366F1).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color(0xFF6366F1).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: selected
                    ? const Color(0xFF6366F1)
                    : Colors.white.withValues(alpha: 0.35)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF6366F1)
                    : Colors.white.withValues(alpha: 0.35),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accentColorRow(WidgetRef ref, AppSettings settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: settings.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.palette_outlined,
                    color: settings.accentColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Accent Color',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(accentColorNames[settings.accentColorIndex],
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(accentColors.length, (i) {
              final selected = settings.accentColorIndex == i;
              return GestureDetector(
                onTap: () =>
                    ref.read(settingsProvider.notifier).setAccentColor(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColors[i],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: accentColors[i].withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF6366F1),
            activeTrackColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ),
          Text(value,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.3),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
      );

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}
