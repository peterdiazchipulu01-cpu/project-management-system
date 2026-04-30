import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../providers/user_provider.dart';
import '../common/avatar_widget.dart';
import '../common/priority_badge.dart';
import '../common/progress_bar.dart';
import '../dialogs/task_dialog.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  final int projectId;

  const TaskCard({super.key, required this.task, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignee = ref.watch(userByIdProvider(task.assigneeId));
    final now = DateTime.now();
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(now) &&
        task.status != TaskStatus.done;

    return LongPressDraggable<Task>(
      data: task,
      delay: const Duration(milliseconds: 150),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 240,
          child: _CardContent(
              task: task, assignee: assignee, isOverdue: isOverdue),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _CardContent(
            task: task, assignee: assignee, isOverdue: isOverdue),
      ),
      child: GestureDetector(
        onTap: () => showTaskDialog(context,
            projectId: projectId, task: task),
        child: _CardContent(
            task: task, assignee: assignee, isOverdue: isOverdue),
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final Task task;
  final User? assignee;
  final bool isOverdue;

  const _CardContent(
      {required this.task, required this.assignee, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PriorityBadge(priority: task.priority),
                if (assignee != null) AvatarWidget(user: assignee!, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (task.dueDate != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.calendar_today_outlined,
                    size: 12,
                    color: isOverdue
                        ? const Color(0xFFEF4444)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d').format(task.dueDate!),
                    style: TextStyle(
                      fontSize: 11,
                      color: isOverdue
                          ? const Color(0xFFEF4444)
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: ProgressBar(progress: task.progress)),
                const SizedBox(width: 8),
                Text(
                  '${task.progress}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
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
