import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/date_time_extension.dart';
import '../../domain/entities/reminder.dart';
import 'reminder_di_providers.dart';

enum ReminderFilter { all, today, tomorrow, thisWeek, highPriority, completed }

enum ReminderSort { byDate, byPriority, byName }

/// Stream mentah dari database — hanya watch, tanpa filter/sort.
final _rawRemindersProvider = StreamProvider<List<Reminder>>((ref) {
  return ref.watch(getRemindersUseCaseProvider)();
});

/// Versi publik dari stream mentah, dipakai saat butuh reminder by id
/// tanpa terpengaruh filter/search aktif di Home (mis. saat navigasi
/// ke halaman Detail/Edit dari luar Home).
final allRemindersProvider = Provider<AsyncValue<List<Reminder>>>((ref) {
  return ref.watch(_rawRemindersProvider);
});

final reminderSearchQueryProvider = StateProvider<String>((ref) => '');
final reminderFilterProvider =
    StateProvider<ReminderFilter>((ref) => ReminderFilter.all);
final reminderSortProvider =
    StateProvider<ReminderSort>((ref) => ReminderSort.byDate);

/// Provider turunan yang menerapkan search + filter + sort di atas
/// stream mentah. Dipisah dari `_rawRemindersProvider` supaya logic
/// UI (search/filter/sort) tidak bercampur dengan sumber data asli —
/// gampang di-test dan di-reuse.
final filteredRemindersProvider = Provider<AsyncValue<List<Reminder>>>((ref) {
  final raw = ref.watch(_rawRemindersProvider);
  final query = ref.watch(reminderSearchQueryProvider).toLowerCase().trim();
  final filter = ref.watch(reminderFilterProvider);
  final sort = ref.watch(reminderSortProvider);

  return raw.whenData((reminders) {
    var result = reminders.where((r) {
      if (query.isEmpty) return true;
      return r.title.toLowerCase().contains(query) ||
          r.category.toLowerCase().contains(query);
    }).toList();

    result = switch (filter) {
      ReminderFilter.all => result,
      ReminderFilter.today =>
        result.where((r) => r.dueDateTime.isToday() && !r.isCompleted).toList(),
      ReminderFilter.tomorrow => result
          .where((r) => r.dueDateTime.isTomorrow() && !r.isCompleted)
          .toList(),
      ReminderFilter.thisWeek => result
          .where((r) => r.dueDateTime.isThisWeek() && !r.isCompleted)
          .toList(),
      ReminderFilter.highPriority => result
          .where((r) =>
              r.priority == ReminderPriority.high && !r.isCompleted)
          .toList(),
      ReminderFilter.completed =>
        result.where((r) => r.isCompleted).toList(),
    };

    result.sort((a, b) => switch (sort) {
          ReminderSort.byDate => a.dueDateTime.compareTo(b.dueDateTime),
          ReminderSort.byPriority =>
            b.priority.index.compareTo(a.priority.index),
          ReminderSort.byName =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        });

    return result;
  });
});

/// Grouping untuk Home Screen: Hari ini / Akan datang / Terlambat / Selesai.
final homeGroupedRemindersProvider = Provider<AsyncValue<HomeGroups>>((ref) {
  final filtered = ref.watch(filteredRemindersProvider);
  return filtered.whenData((reminders) {
    return HomeGroups(
      today: reminders
          .where((r) => r.dueDateTime.isToday() && !r.isCompleted)
          .toList(),
      upcoming: reminders
          .where((r) =>
              !r.isCompleted &&
              !r.isOverdue &&
              !r.dueDateTime.isToday())
          .toList(),
      overdue: reminders.where((r) => r.isOverdue).toList(),
      completed: reminders.where((r) => r.isCompleted).toList(),
    );
  });
});

class HomeGroups {
  const HomeGroups({
    required this.today,
    required this.upcoming,
    required this.overdue,
    required this.completed,
  });

  final List<Reminder> today;
  final List<Reminder> upcoming;
  final List<Reminder> overdue;
  final List<Reminder> completed;
}
