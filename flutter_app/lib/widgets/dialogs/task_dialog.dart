import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';
import '../common/toast_service.dart';

Future<void> showTaskDialog(BuildContext context,
    {required int projectId, Task? task}) async {
  await showDialog(
    context: context,
    builder: (ctx) => _TaskDialog(projectId: projectId, task: task),
  );
}

class _TaskDialog extends ConsumerStatefulWidget {
  final int projectId;
  final Task? task;
  const _TaskDialog({required this.projectId, this.task});

  @override
  ConsumerState<_TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends ConsumerState<_TaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late TaskStatus _status;
  late TaskPriority _priority;
  DateTime? _startDate;
  DateTime? _dueDate;
  late double _progress;
  int? _assigneeId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _status = t?.status ?? TaskStatus.todo;
    _priority = t?.priority ?? TaskPriority.medium;
    _startDate = t?.startDate;
    _dueDate = t?.dueDate;
    _progress = (t?.progress ?? 0).toDouble();
    _assigneeId = t?.assigneeId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial =
        (isStart ? _startDate : _dueDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'title': _titleCtrl.text.trim(),
        'status': _status.toJson(),
        'priority': _priority.toJson(),
        'progress': _progress.round(),
        'description':
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'start_date': _startDate != null ? _fmtDate(_startDate!) : null,
        'due_date': _dueDate?.toIso8601String(),
        'assignee_id': _assigneeId,
      };
      if (widget.task == null) data['project_id'] = widget.projectId;

      final service = ref.read(taskServiceProvider);
      if (widget.task == null) {
        await service.createTask(data);
      } else {
        await service.updateTask(widget.task!.id, data);
      }
      ref.invalidate(tasksProvider(widget.projectId));
      if (mounted) {
        Navigator.pop(context);
        ToastService.showSuccess(
          context,
          widget.task == null ? 'Task created' : 'Task updated',
        );
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Delete "${widget.task!.title}"?'),
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
          .read(taskServiceProvider)
          .deleteTask(widget.task!.id);
      ref.invalidate(tasksProvider(widget.projectId));
      if (mounted) {
        Navigator.pop(context);
        ToastService.showSuccess(context, 'Task deleted');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Error: $e');
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider).value ?? [];
    final isEdit = widget.task != null;

    return AlertDialog(
      title: Row(
        children: [
          Text(isEdit ? 'Edit Task' : 'New Task'),
          const Spacer(),
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Color(0xFFEF4444)),
              tooltip: 'Delete task',
              onPressed: _delete,
            ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Title *'),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Title required'
                      : null,
                  autofocus: !isEdit,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TaskStatus>(
                        initialValue: _status,
                        decoration:
                            const InputDecoration(labelText: 'Status'),
                        items: TaskStatus.values
                            .map((s) => DropdownMenuItem(
                                value: s, child: Text(s.label)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _status = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<TaskPriority>(
                        initialValue: _priority,
                        decoration:
                            const InputDecoration(labelText: 'Priority'),
                        items: TaskPriority.values
                            .map((p) => DropdownMenuItem(
                                value: p, child: Text(p.label)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _priority = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _DateField(
                          label: 'Start Date',
                          date: _startDate,
                          onTap: () => _pickDate(true)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateField(
                          label: 'Due Date',
                          date: _dueDate,
                          onTap: () => _pickDate(false)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (users.isNotEmpty) ...[
                  DropdownButtonFormField<int?>(
                    initialValue: _assigneeId,
                    decoration:
                        const InputDecoration(labelText: 'Assignee'),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('Unassigned')),
                      ...users.map((u) => DropdownMenuItem(
                          value: u.id, child: Text(u.name))),
                    ],
                    onChanged: (v) =>
                        setState(() => _assigneeId = v),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress: ${_progress.round()}%',
                            style:
                                Theme.of(context).textTheme.bodySmall,
                          ),
                          Slider(
                            value: _progress,
                            min: 0,
                            max: 100,
                            divisions: 20,
                            onChanged: (v) =>
                                setState(() => _progress = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(isEdit ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateField(
      {required this.label, required this.date, required this.onTap});

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon:
              const Icon(Icons.calendar_today_outlined, size: 16),
        ),
        child: Text(date != null ? _fmt(date!) : '—',
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
