import 'package:flutter/material.dart';
import '../../models/task.dart';
import 'kanban_column.dart';

class KanbanView extends StatelessWidget {
  final List<Task> tasks;
  final int projectId;

  const KanbanView(
      {super.key, required this.tasks, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final todo =
        tasks.where((t) => t.status == TaskStatus.todo).toList();
    final inProgress =
        tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    final done =
        tasks.where((t) => t.status == TaskStatus.done).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KanbanColumn(
              status: TaskStatus.todo,
              tasks: todo,
              projectId: projectId),
          KanbanColumn(
              status: TaskStatus.inProgress,
              tasks: inProgress,
              projectId: projectId),
          KanbanColumn(
              status: TaskStatus.done,
              tasks: done,
              projectId: projectId),
        ],
      ),
    );
  }
}
