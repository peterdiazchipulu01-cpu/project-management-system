import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../core/app_theme.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (priority) {
      TaskPriority.low => (
          AppTheme.priorityLow.withValues(alpha: 0.15),
          AppTheme.priorityLow
        ),
      TaskPriority.medium => (
          AppTheme.priorityMedium.withValues(alpha: 0.15),
          AppTheme.priorityMedium
        ),
      TaskPriority.high => (
          AppTheme.priorityHigh.withValues(alpha: 0.15),
          AppTheme.priorityHigh
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        priority.label,
        style: TextStyle(
            color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
