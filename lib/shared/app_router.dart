import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/reminder/domain/entities/pre_reminder_offset.dart';
import '../features/reminder/domain/entities/reminder.dart';
import '../features/reminder/domain/entities/repeat_type.dart';
import '../features/reminder/presentation/pages/add_reminder_page.dart';
import '../features/reminder/presentation/pages/detail_reminder_page.dart';
import '../features/reminder/presentation/pages/edit_reminder_page.dart';
import '../features/reminder/presentation/pages/home_page.dart';
import '../features/reminder/presentation/pages/settings_page.dart';
import '../features/reminder/presentation/pages/splash_page.dart';
import '../features/reminder/presentation/providers/reminder_list_provider.dart';

/// Placeholder entity dipakai hanya saat reminder dengan [id] pada route
/// tidak (belum) ditemukan di stream — mencegah crash null saat state
/// masih loading atau id salah ketik.
Reminder _notFoundReminder(String id) {
  final now = DateTime.now();
  return Reminder(
    id: id,
    title: 'Reminder tidak ditemukan',
    note: '',
    category: '',
    colorValue: 0xFF9E9E9E,
    priority: ReminderPriority.low,
    dueDateTime: now,
    repeatType: RepeatType.none,
    preReminderOffset: PreReminderOffset.onTime,
    isCompleted: false,
    createdAt: now,
  );
}

/// Router didefinisikan sebagai provider (bukan variabel global) supaya
/// bisa mengakses provider lain (mis. mencari Reminder by id dari state
/// yang sudah di-watch), konsisten dengan composition root Riverpod.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddReminderPage(),
      ),
      GoRoute(
        path: '/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final reminder = _findReminder(ref, id);
          return EditReminderPage(reminder: reminder);
        },
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final reminder = _findReminder(ref, id);
          return DetailReminderPage(reminder: reminder);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});

Reminder _findReminder(Ref ref, String id) {
  final asyncList = ref.read(allRemindersProvider);
  final reminders = asyncList.value ?? const [];
  return reminders.firstWhere(
    (r) => r.id == id,
    orElse: () => _notFoundReminder(id),
  );
}
