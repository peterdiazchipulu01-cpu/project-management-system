import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../widgets/common/avatar_widget.dart';
import '../widgets/common/toast_service.dart';

void showTeamScreen(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => const _TeamDialog(),
  );
}

class _TeamDialog extends ConsumerStatefulWidget {
  const _TeamDialog();

  @override
  ConsumerState<_TeamDialog> createState() => _TeamDialogState();
}

class _TeamDialogState extends ConsumerState<_TeamDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (name.isEmpty || email.isEmpty) return;

    setState(() => _adding = true);
    try {
      await ref.read(userServiceProvider).createUser({
        'name': name,
        'email': email,
      });
      await ref.read(usersProvider.notifier).refresh();
      _nameCtrl.clear();
      _emailCtrl.clear();
      if (mounted) {
        ToastService.showSuccess(context, 'Team member added');
      }
    } catch (e) {
      if (mounted) ToastService.showError(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return AlertDialog(
      title: const Text('Team Members'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            usersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (list) => list.isEmpty
                  ? Text(
                      'No team members yet.',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5)),
                    )
                  : Column(
                      children: list
                          .map(
                            (u) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: AvatarWidget(user: u, size: 36),
                              title: Text(u.name),
                              subtitle: Text(u.email),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const Divider(height: 28),
            Text('Add Member',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Full Name', isDense: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                  labelText: 'Email', isDense: true),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _adding ? null : _addMember,
              child: _adding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child:
                          CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Add Member'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close')),
      ],
    );
  }
}
