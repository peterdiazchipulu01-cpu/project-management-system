import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../providers/task_provider.dart';
import '../widgets/kanban/kanban_view.dart';
import '../widgets/gantt/gantt_view.dart';
import '../widgets/dialogs/task_dialog.dart';
import '../widgets/dialogs/project_dialog.dart';

class ProjectBoardScreen extends ConsumerStatefulWidget {
  final Project project;
  const ProjectBoardScreen({super.key, required this.project});

  @override
  ConsumerState<ProjectBoardScreen> createState() =>
      _ProjectBoardScreenState();
}

class _ProjectBoardScreenState extends ConsumerState<ProjectBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider(widget.project.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (widget.project.description != null)
                      Text(
                        widget.project.description!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.55),
                            ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit project',
                onPressed: () => showProjectDialog(context,
                    project: widget.project),
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: () => showTaskDialog(context,
                    projectId: widget.project.id),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Task'),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Kanban'),
            Tab(text: 'Gantt Chart'),
          ],
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Expanded(
          child: tasks.when(
            skipLoadingOnRefresh: true,
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('Error loading tasks: $e')),
            data: (taskList) => TabBarView(
              controller: _tabController,
              children: [
                KanbanView(
                    tasks: taskList, projectId: widget.project.id),
                GanttView(
                    tasks: taskList, project: widget.project),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
