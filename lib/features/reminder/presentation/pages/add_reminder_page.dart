import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/reminder_actions_provider.dart';
import '../widgets/reminder_form.dart';

class AddReminderPage extends ConsumerWidget {
  const AddReminderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Reminder')),
      body: ReminderForm(
        onSubmit: (reminder) async {
          final failure =
              await ref.read(reminderActionsProvider).add(reminder);
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
