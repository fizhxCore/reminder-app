import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/reminder.dart';
import '../providers/reminder_actions_provider.dart';
import '../providers/reminder_list_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/reminder_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(homeGroupedRemindersProvider);
    final use24Hour = ref.watch(settingsProvider).use24Hour;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          const _SearchAndFilterBar(),
          Expanded(
            child: groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Terjadi kesalahan: $err')),
              data: (groups) {
                final isEmpty = groups.today.isEmpty &&
                    groups.upcoming.isEmpty &&
                    groups.overdue.isEmpty &&
                    groups.completed.isEmpty;
                if (isEmpty) {
                  return const EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: 'Belum ada reminder',
                    subtitle: 'Ketuk tombol + untuk membuat reminder pertama.',
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  children: [
                    if (groups.overdue.isNotEmpty)
                      _Section(
                        title: 'Terlambat',
                        reminders: groups.overdue,
                        use24Hour: use24Hour,
                      ),
                    if (groups.today.isNotEmpty)
                      _Section(
                        title: 'Hari Ini',
                        reminders: groups.today,
                        use24Hour: use24Hour,
                      ),
                    if (groups.upcoming.isNotEmpty)
                      _Section(
                        title: 'Akan Datang',
                        reminders: groups.upcoming,
                        use24Hour: use24Hour,
                      ),
                    if (groups.completed.isNotEmpty)
                      _Section(
                        title: 'Selesai',
                        reminders: groups.completed,
                        use24Hour: use24Hour,
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add'),
        icon: const Icon(Icons.add),
        label: const Text('Reminder'),
      ),
    );
  }
}

class _SearchAndFilterBar extends ConsumerWidget {
  const _SearchAndFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reminderFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Cari judul atau kategori...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) =>
                ref.read(reminderSearchQueryProvider.notifier).state = value,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ReminderFilter.values.map((f) {
                final selected = f == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_filterLabel(f)),
                    selected: selected,
                    onSelected: (_) =>
                        ref.read(reminderFilterProvider.notifier).state = f,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _filterLabel(ReminderFilter filter) {
    switch (filter) {
      case ReminderFilter.all:
        return 'Semua';
      case ReminderFilter.today:
        return 'Hari Ini';
      case ReminderFilter.tomorrow:
        return 'Besok';
      case ReminderFilter.thisWeek:
        return 'Minggu Ini';
      case ReminderFilter.highPriority:
        return 'Prioritas Tinggi';
      case ReminderFilter.completed:
        return 'Selesai';
    }
  }
}

class _Section extends ConsumerWidget {
  const _Section({
    required this.title,
    required this.reminders,
    required this.use24Hour,
  });

  final String title;
  final List<Reminder> reminders;
  final bool use24Hour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        ...reminders.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReminderCard(
                reminder: r,
                use24Hour: use24Hour,
                onTap: () => context.push('/detail/${r.id}'),
                onToggleComplete: () async {
                  if (r.isCompleted) return;
                  await ref.read(reminderActionsProvider).complete(r);
                },
              ),
            )),
      ],
    );
  }
}
