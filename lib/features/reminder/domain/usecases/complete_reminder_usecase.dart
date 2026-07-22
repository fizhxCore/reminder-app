import '../entities/reminder.dart';
import '../repositories/notification_scheduler.dart';
import '../repositories/reminder_repository.dart';
import 'schedule_reminder_usecase.dart';

/// Menandai reminder selesai.
///
/// - Reminder tidak berulang: batalkan notifikasi berikutnya (tidak ada lagi).
/// - Reminder berulang: tetap reschedule ke next occurrence, karena
///   "selesai" untuk instance berulang berarti "selesai untuk hari ini",
///   bukan menghentikan seluruh seri.
class CompleteReminderUseCase {
  const CompleteReminderUseCase(
    this._repository,
    this._scheduler,
    this._scheduleReminderUseCase,
  );

  final ReminderRepository _repository;
  final NotificationScheduler _scheduler;
  final ScheduleReminderUseCase _scheduleReminderUseCase;

  Future<void> call(Reminder reminder) async {
    final completed = reminder.copyWith(isCompleted: true);
    await _repository.update(completed);
    await _scheduler.cancel(reminder.id);

    if (reminder.isRepeating) {
      await _scheduleReminderUseCase(completed);
    }
  }
}
