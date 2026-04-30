import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../core/app_theme.dart';
import 'task_card.dart';

class KanbanColumn extends ConsumerWidget {
  final TaskStatus status;
  final List<Task> tasks;
  final int projectId;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tasks,
    required this.projectId,
  });

  Color get _dotColor => switch (status) {
        TaskStatus.todo => Colors.grey,
        TaskStatus.inProgress => AppTheme.priorityMedium,
        TaskStatus.done => AppTheme.success,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<Task>(
      onAcceptWithDetails: (details) async {
        final task = details.data;
        if (task.status == status) return;
        try {
          await ref
              .read(taskServiceProvider)
              .updateTask(task.id, {'status': status.toJson()});
          ref.invalidate(tasksProvider(projectId));
        } catch (_) {}
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Container(
          width: 268,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: isHighlighted
                ? Border.all(color: AppTheme.primary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: _dotColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status.label.toUpperCase(),
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${tasks.length}',
                          style: Theme.of(context).textTheme.labelSmall),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.35),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        itemCount: tasks.length,
                        itemBuilder: (context, i) => TaskCard(
                            task: tasks[i], projectId: projectId),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
