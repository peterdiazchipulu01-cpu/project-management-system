import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/project_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/dashboard/drill_rig_painter.dart';
import '../widgets/dashboard/ppe_illustration.dart';
import 'home_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _safetyDismissed = false;
  final Map<String, bool> _checklist = {
    'PPE equipment inspected (hard hat, gloves, goggles)': false,
    'Site hazards identified and reported': false,
    'Emergency exits and muster points confirmed': false,
    'Equipment pre-start checks completed': false,
    'Team briefed on today\'s tasks and risks': false,
  };

  bool get _allChecked => _checklist.values.every((v) => v);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d · yyyy').format(now);
    final timeStr = DateFormat('HH:mm').format(now);
    final projects = ref.watch(projectsProvider);
    final users = ref.watch(usersProvider);
    final projectCount = projects.maybeWhen(data: (d) => d.length, orElse: () => 0);
    final userCount = users.maybeWhen(data: (d) => d.length, orElse: () => 0);

    return Scaffold(
      backgroundColor: const Color(0xFF060B18),
      body: Stack(
        children: [
          // Drill rig background
          const DrillRigBackground(),

          // Content fade in
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(dateStr, timeStr),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcome(),
                          const SizedBox(height: 28),
                          if (!_safetyDismissed) ...[
                            _buildSafetyCard(),
                            const SizedBox(height: 20),
                          ],
                          if (_safetyDismissed) ...[
                            _buildClearedBanner(),
                            const SizedBox(height: 20),
                          ],
                          _buildStatsRow(projectCount, userCount),
                          const SizedBox(height: 20),
                          _buildEnterButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(String date, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
            ),
            child: const Icon(Icons.shield_outlined, color: Color(0xFF3B82F6), size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'SafeOps · PMS',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
          const Spacer(),
          _chip(time, Icons.access_time_outlined),
          const SizedBox(width: 8),
          _chip(date, null),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData? icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white.withOpacity(0.5), size: 12),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good ${_greeting()},',
          style: TextStyle(
            color: Colors.white.withOpacity(0.45),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Project Manager',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Site operations active',
              style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSafetyCard() {
    return _glassCard(
      borderColor: _allChecked
          ? const Color(0xFF22C55E).withOpacity(0.4)
          : const Color(0xFFF59E0B).withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PPE illustration
              const PpeIllustration(width: 180, height: 90),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFF59E0B), size: 16),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Daily Safety Checklist',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Complete all checks before starting work on site.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _checklist.values.where((v) => v).length / _checklist.length,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        color: _allChecked ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_checklist.values.where((v) => v).length} / ${_checklist.length} completed',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 14),
          ..._checklist.entries.map((e) => _checkRow(e.key, e.value)),
          if (_allChecked) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _safetyDismissed = true),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text(
                  'Safety Confirmed — Start Work',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _checkRow(String label, bool checked) {
    return GestureDetector(
      onTap: () => setState(() => _checklist[label] = !checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: checked ? const Color(0xFF3B82F6) : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: checked
                      ? const Color(0xFF3B82F6)
                      : Colors.white.withOpacity(0.18),
                  width: 1.5,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check, color: Colors.white, size: 13)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: checked
                      ? Colors.white.withOpacity(0.85)
                      : Colors.white.withOpacity(0.5),
                  fontSize: 13,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white.withOpacity(0.25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearedBanner() {
    return _glassCard(
      borderColor: const Color(0xFF22C55E).withOpacity(0.4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.verified_outlined, color: Color(0xFF22C55E), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Safety Checks Cleared',
                  style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All PPE and site checks confirmed for today.',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _safetyDismissed = false;
              _checklist.updateAll((_, __) => false);
            }),
            child: Text('Reset', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int projectCount, int userCount) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Projects',
            projectCount.toString(),
            Icons.folder_open_outlined,
            const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Team',
            userCount.toString(),
            Icons.group_outlined,
            const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'Site Status',
            _safetyDismissed ? 'Clear' : 'Pending',
            Icons.security_outlined,
            _safetyDismissed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.38), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        ),
        icon: const Icon(Icons.dashboard_outlined, size: 20),
        label: const Text(
          'Open Project Board',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child, Color? borderColor}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.08),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}
