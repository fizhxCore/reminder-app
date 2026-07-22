import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/notification_service.dart';
import '../../data/datasource/reminder_local_datasource.dart';
import '../../data/models/reminder_table.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/repositories/notification_scheduler.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/usecases/add_reminder_usecase.dart';
import '../../domain/usecases/cancel_reminder_usecase.dart';
import '../../domain/usecases/complete_reminder_usecase.dart';
import '../../domain/usecases/delete_reminder_usecase.dart';
import '../../domain/usecases/edit_reminder_usecase.dart';
import '../../domain/usecases/get_reminders_usecase.dart';
import '../../domain/usecases/schedule_reminder_usecase.dart';
import '../../domain/usecases/snooze_reminder_usecase.dart';

/// --- Composition root ---
/// Semua dependency di-wire di sini lewat Riverpod `Provider`, tanpa
/// package DI terpisah (get_it dsb) — satu sumber kebenaran untuk
/// bagaimana objek-objek saling terhubung (lihat Tahap 2: Arsitektur).

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final notificationPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(notificationPluginProvider));
});

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return ref.watch(notificationServiceProvider);
});

final reminderLocalDataSourceProvider =
    Provider<ReminderLocalDataSource>((ref) {
  return ReminderLocalDataSource(ref.watch(appDatabaseProvider));
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepositoryImpl(ref.watch(reminderLocalDataSourceProvider));
});

// --- Usecase providers ---

final getRemindersUseCaseProvider = Provider<GetRemindersUseCase>((ref) {
  return GetRemindersUseCase(ref.watch(reminderRepositoryProvider));
});

final scheduleReminderUseCaseProvider =
    Provider<ScheduleReminderUseCase>((ref) {
  return ScheduleReminderUseCase(
    ref.watch(reminderRepositoryProvider),
    ref.watch(notificationSchedulerProvider),
  );
});

final addReminderUseCaseProvider = Provider<AddReminderUseCase>((ref) {
  return AddReminderUseCase(
    ref.watch(reminderRepositoryProvider),
    ref.watch(notificationSchedulerProvider),
  );
});

final editReminderUseCaseProvider = Provider<EditReminderUseCase>((ref) {
  return EditReminderUseCase(
    ref.watch(reminderRepositoryProvider),
    ref.watch(notificationSchedulerProvider),
  );
});

final deleteReminderUseCaseProvider = Provider<DeleteReminderUseCase>((ref) {
  return DeleteReminderUseCase(
    ref.watch(reminderRepositoryProvider),
    ref.watch(notificationSchedulerProvider),
  );
});

final cancelReminderUseCaseProvider = Provider<CancelReminderUseCase>((ref) {
  return CancelReminderUseCase(ref.watch(notificationSchedulerProvider));
});

final snoozeReminderUseCaseProvider = Provider<SnoozeReminderUseCase>((ref) {
  return SnoozeReminderUseCase(ref.watch(notificationSchedulerProvider));
});

final completeReminderUseCaseProvider =
    Provider<CompleteReminderUseCase>((ref) {
  return CompleteReminderUseCase(
    ref.watch(reminderRepositoryProvider),
    ref.watch(notificationSchedulerProvider),
    ref.watch(scheduleReminderUseCaseProvider),
  );
});
