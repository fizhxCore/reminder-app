import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/reminder.dart';
import '../providers/reminder_actions_provider.dart';
import '../widgets/reminder_form.dart';

class EditReminderPage extends ConsumerWidget {
  const EditReminderPage({super.key, required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Reminder')),
      body: ReminderForm(
        initial: reminder,
        onSubmit: (updated) async {
          final failure =
              await ref.read(reminderActionsProvider).edit(updated);
          if (!context.mounted) return;
          if (failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failure.message)),
            );
            return;
          }
          context.pop();
        },
      ),
    );
  }
}
