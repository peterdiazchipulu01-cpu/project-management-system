import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/project.dart';
import '../../providers/project_provider.dart';
import '../common/toast_service.dart';

Future<void> showProjectDialog(BuildContext context,
    {Project? project}) async {
  await showDialog(
    context: context,
    builder: (ctx) => _ProjectDialog(project: project),
  );
}

class _ProjectDialog extends ConsumerStatefulWidget {
  final Project? project;
  const _ProjectDialog({this.project});

  @override
  ConsumerState<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends ConsumerState<_ProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.project?.name ?? '');
    _descCtrl =
        TextEditingController(text: widget.project?.description ?? '');
    _startDate = widget.project?.startDate;
    _endDate = widget.project?.endDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial =
        (isStart ? _startDate : _endDate) ?? DateTime.now();
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
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'name': _nameCtrl.text.trim(),
      };
      if (_descCtrl.text.trim().isNotEmpty) {
        data['description'] = _descCtrl.text.trim();
      }
      if (_startDate != null) {
        data['start_date'] = _fmt(_startDate!);
      }
      if (_endDate != null) {
        data['end_date'] = _fmt(_endDate!);
      }

      final service = ref.read(projectServiceProvider);
      if (widget.project == null) {
        await service.createProject(data);
      } else {
        await service.updateProject(widget.project!.id, data);
      }
      await ref.read(projectsProvider.notifier).refresh();
      if (mounted) {
        Navigator.pop(context);
        ToastService.showSuccess(
          context,
          widget.project == null ? 'Project created' : 'Project updated',
        );
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.project != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Project' : 'New Project'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Project Name *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name required' : null,
                autofocus: true,
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
                    child: _DateField(
                      label: 'Start Date',
                      date: _startDate,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'End Date',
                      date: _endDate,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
            ],
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
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16),
        ),
        child: Text(date != null ? _fmt(date!) : '—',
            style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
