import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/app_theme.dart';
import '../models/task.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';

// ── Data ─────────────────────────────────────────────────────────────────────

class _ReportData {
  final List<Project> projects;
  final List<Task> allTasks;

  const _ReportData({required this.projects, required this.allTasks});

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime get weekStart {
    final t = _today;
    return t.subtract(Duration(days: t.weekday - 1));
  }

  DateTime get weekEnd => weekStart.add(const Duration(days: 6));

  List<Task> get done =>
      allTasks.where((t) => t.status == TaskStatus.done).toList();

  List<Task> get inProgress =>
      allTasks.where((t) => t.status == TaskStatus.inProgress).toList();

  List<Task> get todo =>
      allTasks.where((t) => t.status == TaskStatus.todo).toList();

  List<Task> get overdue => allTasks.where((t) {
        if (t.status == TaskStatus.done || t.dueDate == null) return false;
        return t.dueDate!.isBefore(_today);
      }).toList();

  List<Task> get dueThisWeek {
    final start = weekStart;
    final end = weekEnd.add(const Duration(days: 1));
    return allTasks.where((t) {
      if (t.dueDate == null) return false;
      final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return !d.isBefore(start) && d.isBefore(end);
    }).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
  }

  List<Task> get highPriority =>
      allTasks.where((t) => t.priority == TaskPriority.high).toList();

  List<Task> tasksForProject(int id) =>
      allTasks.where((t) => t.projectId == id).toList();

  double projectProgress(int id) {
    final tasks = tasksForProject(id);
    if (tasks.isEmpty) return 0;
    return tasks.fold<int>(0, (s, t) => s + t.progress) / tasks.length / 100.0;
  }
}

final _weeklyReportProvider = FutureProvider<_ReportData>((ref) async {
  final projects = await ref.watch(projectsProvider.future);
  final all = <Task>[];
  for (final p in projects) {
    all.addAll(await ref.watch(tasksProvider(p.id).future));
  }
  return _ReportData(projects: projects, allTasks: all);
});

// ── Screen ───────────────────────────────────────────────────────────────────

class WeeklyReportScreen extends ConsumerWidget {
  const WeeklyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(_weeklyReportProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.sidebarBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Weekly Report',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: Colors.white60),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(_weeklyReportProvider),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (report) => _ReportBody(report: report),
      ),
    );
  }
}

void showWeeklyReportScreen(BuildContext context) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => const WeeklyReportScreen(),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _ReportBody extends StatelessWidget {
  final _ReportData report;
  const _ReportBody({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('MMM d');
    final weekLabel =
        '${fmt.format(report.weekStart)} – ${fmt.format(report.weekEnd)}, '
        '${report.weekEnd.year}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ── Week banner ────────────────────────────────────────────────────
        _SectionHeader(
          icon: Icons.calendar_today_outlined,
          label: 'Week of $weekLabel',
          color: AppTheme.primary,
        ),
        const SizedBox(height: 12),

        // ── Summary stats ─────────────────────────────────────────────────
        _StatsGrid(report: report),
        const SizedBox(height: 24),

        // ── Due this week ─────────────────────────────────────────────────
        _SectionHeader(
          icon: Icons.event_outlined,
          label: 'Due This Week (${report.dueThisWeek.length})',
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 8),
        if (report.dueThisWeek.isEmpty)
          _EmptyHint('No tasks due this week')
        else
          ...report.dueThisWeek
              .map((t) => _TaskTile(task: t, report: report, theme: theme)),
        const SizedBox(height: 24),

        // ── Overdue ───────────────────────────────────────────────────────
        _SectionHeader(
          icon: Icons.warning_amber_rounded,
          label: 'Overdue (${report.overdue.length})',
          color: AppTheme.danger,
        ),
        const SizedBox(height: 8),
        if (report.overdue.isEmpty)
          _EmptyHint('No overdue tasks — great work!')
        else
          ...report.overdue
              .map((t) => _TaskTile(task: t, report: report, theme: theme)),
        const SizedBox(height: 24),

        // ── High priority ─────────────────────────────────────────────────
        _SectionHeader(
          icon: Icons.bolt_outlined,
          label: 'High Priority (${report.highPriority.length})',
          color: AppTheme.priorityHigh,
        ),
        const SizedBox(height: 8),
        if (report.highPriority.isEmpty)
          _EmptyHint('No high-priority tasks')
        else
          ...report.highPriority
              .map((t) => _TaskTile(task: t, report: report, theme: theme)),
        const SizedBox(height: 24),

        // ── Per-project breakdown ─────────────────────────────────────────
        _SectionHeader(
          icon: Icons.folder_open_outlined,
          label: 'Project Breakdown',
          color: const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 8),
        if (report.projects.isEmpty)
          _EmptyHint('No projects found')
        else
          ...report.projects.map((p) => _ProjectCard(project: p, report: report)),
      ],
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final _ReportData report;
  const _StatsGrid({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total Tasks',
                value: report.allTasks.length,
                icon: Icons.task_alt_outlined,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Done',
                value: report.done.length,
                icon: Icons.check_circle_outline,
                color: AppTheme.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'In Progress',
                value: report.inProgress.length,
                icon: Icons.autorenew_outlined,
                color: const Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Overdue',
                value: report.overdue.length,
                icon: Icons.schedule_outlined,
                color: AppTheme.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Due This Week',
                value: report.dueThisWeek.length,
                icon: Icons.event_outlined,
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'High Priority',
                value: report.highPriority.length,
                icon: Icons.bolt_outlined,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Task tile ─────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  final Task task;
  final _ReportData report;
  final ThemeData theme;

  const _TaskTile({
    required this.task,
    required this.report,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final project =
        report.projects.where((p) => p.id == task.projectId).firstOrNull;
    final dueFmt = task.dueDate != null
        ? DateFormat('MMM d').format(task.dueDate!)
        : null;
    final isOverdue = task.dueDate != null &&
        task.status != TaskStatus.done &&
        task.dueDate!.isBefore(DateTime.now());

    final statusColor = switch (task.status) {
      TaskStatus.done => AppTheme.success,
      TaskStatus.inProgress => const Color(0xFF3B82F6),
      TaskStatus.todo => theme.colorScheme.onSurface.withOpacity(0.4),
    };

    final priorityColor = switch (task.priority) {
      TaskPriority.high => AppTheme.priorityHigh,
      TaskPriority.medium => AppTheme.priorityMedium,
      TaskPriority.low => AppTheme.priorityLow,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 36,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: task.status == TaskStatus.done
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (project != null) ...[
                        Text(
                          project.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.45),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (dueFmt != null)
                        Text(
                          dueFmt,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isOverdue
                                ? AppTheme.danger
                                : theme.colorScheme.onSurface.withOpacity(0.45),
                            fontWeight: isOverdue ? FontWeight.w600 : null,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                task.status.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Project card ──────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final Project project;
  final _ReportData report;

  const _ProjectCard({required this.project, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasks = report.tasksForProject(project.id);
    final progress = report.projectProgress(project.id);
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final inProg = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final overdue = tasks
        .where((t) =>
            t.status != TaskStatus.done &&
            t.dueDate != null &&
            t.dueDate!.isBefore(DateTime.now()))
        .length;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.folder_outlined,
                      color: AppTheme.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    project.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${tasks.length} task${tasks.length == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor:
                    theme.colorScheme.onSurface.withOpacity(0.08),
                color: progress >= 1.0
                    ? AppTheme.success
                    : AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _Chip(label: '$done done', color: AppTheme.success),
                const SizedBox(width: 6),
                _Chip(
                    label: '$inProg in progress',
                    color: const Color(0xFF3B82F6)),
                if (overdue > 0) ...[
                  const SizedBox(width: 6),
                  _Chip(label: '$overdue overdue', color: AppTheme.danger),
                ],
                const Spacer(),
                Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }
}
