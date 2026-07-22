import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/priority_constants.dart';
import '../../../../core/utils/date_time_extension.dart';
import '../../domain/entities/reminder.dart';
import '../providers/reminder_actions_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/priority_badge.dart';

class DetailReminderPage extends ConsumerWidget {
  const DetailReminderPage({super.key, required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final use24Hour = ref.watch(settingsProvider).use24Hour;
    final color = Color(reminder.colorValue);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/edit/${reminder.id}'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(radius: 10, backgroundColor: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reminder.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              PriorityBadge(priority: reminder.priority),
              CategoryChip(label: reminder.category),
            ],
          ),
          const SizedBox(height: 24),
          _InfoTile(
            icon: Icons.event_outlined,
            label: 'Jadwal',
            value: reminder.dueDateTime.toDisplayDateTime(
              use24Hour: use24Hour,
            ),
          ),
          _InfoTile(
            icon: Icons.repeat_outlined,
            label: 'Pengulangan',
            value: reminder.repeatType.label,
          ),
          _InfoTile(
            icon: Icons.notifications_active_outlined,
            label: 'Ingatkan',
            value: reminder.preReminderOffset.label,
          ),
          if (reminder.note.isNotEmpty)
            _InfoTile(
              icon: Icons.notes_outlined,
              label: 'Catatan',
              value: reminder.note,
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: reminder.isCompleted
                ? null
                : () async {
                    await ref.read(reminderActionsProvider).complete(reminder);
                    if (context.mounted) context.pop();
                  },
            icon: const Icon(Icons.check_circle_outline),
            label: Text(
              reminder.isCompleted ? 'Sudah Selesai' : 'Tandai Selesai',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Reminder?'),
        content: Text('"${reminder.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(reminderActionsProvider).delete(reminder.id);
      if (context.mounted) context.pop();
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.outline, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 12, color: scheme.outline)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
