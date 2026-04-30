import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project.dart';
import '../providers/project_provider.dart';
import '../widgets/dialogs/project_dialog.dart';
import '../widgets/common/toast_service.dart';
import '../core/app_theme.dart';

class ProjectSidebar extends ConsumerWidget {
  const ProjectSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final selectedId = ref.watch(selectedProjectIdProvider);

    return Container(
      color: AppTheme.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 8, 8),
            child: Row(
              children: [
                const Text(
                  'PROJECTS',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add,
                      color: Colors.white60, size: 18),
                  tooltip: 'New Project',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => showProjectDialog(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: projectsAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: Colors.white38, strokeWidth: 2)),
              error: (e, _) => const Center(
                  child: Text('Error',
                      style: TextStyle(color: Colors.white38, fontSize: 12))),
              data: (list) => list.isEmpty
                  ? const Center(
                      child: Text(
                        'No projects yet',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      itemCount: list.length,
                      itemBuilder: (ctx, i) => _ProjectItem(
                        project: list[i],
                        isSelected: list[i].id == selectedId,
                        onTap: () => ref
                            .read(selectedProjectIdProvider.notifier)
                            .state = list[i].id,
                        onEdit: () => showProjectDialog(context,
                            project: list[i]),
                        onDelete: () =>
                            _deleteProject(context, ref, list[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject(
      BuildContext context, WidgetRef ref, Project project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project'),
        content:
            Text('Delete "${project.name}" and all its tasks?'),
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
    if (confirm != true) return;
    try {
      await ref
          .read(projectServiceProvider)
          .deleteProject(project.id);
      if (ref.read(selectedProjectIdProvider) == project.id) {
        ref.read(selectedProjectIdProvider.notifier).state = null;
      }
      await ref.read(projectsProvider.notifier).refresh();
      if (context.mounted) {
        ToastService.showSuccess(context, 'Project deleted');
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.showError(context, 'Error: $e');
      }
    }
  }
}

class _ProjectItem extends StatelessWidget {
  final Project project;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectItem({
    required this.project,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primary.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListTile(
        dense: true,
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8),
        minLeadingWidth: 12,
        leading: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary
                : Colors.white38,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          project.name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected
                ? FontWeight.w600
                : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert,
              color: Colors.white30, size: 15),
          padding: EdgeInsets.zero,
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(
                value: 'delete',
                child: Text('Delete',
                    style:
                        TextStyle(color: Color(0xFFEF4444)))),
          ],
        ),
      ),
    );
  }
}
