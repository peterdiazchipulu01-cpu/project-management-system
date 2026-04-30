import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/kanban/kanban_view.dart';
import '../widgets/gantt/gantt_view.dart';
import '../widgets/dialogs/task_dialog.dart';
import '../widgets/dialogs/project_dialog.dart';
import '../widgets/common/toast_service.dart';

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

  Future<void> _deleteProject() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text(
            'Delete "${widget.project.name}" and all its tasks?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ref
          .read(projectServiceProvider)
          .deleteProject(widget.project.id);
      ref.read(selectedProjectIdProvider.notifier).state = null;
      await ref.read(projectsProvider.notifier).refresh();
      if (mounted) {
        ToastService.showSuccess(context, 'Project deleted');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Error: $e');
    }
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
                                  .withOpacity(0.55),
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
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Color(0xFFEF4444)),
                tooltip: 'Delete project',
                onPressed: _deleteProject,
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
