import '../entities/reminder.dart';
import '../repositories/notification_scheduler.dart';
import '../repositories/reminder_repository.dart';

/// Dipanggil oleh background notification handler setelah sebuah
/// notifikasi terpicu untuk reminder yang berulang: menghitung
/// [Reminder.nextOccurrence] lalu menyimpan & menjadwalkan ulang.
///
/// Reminder tidak berulang tidak perlu di-reschedule — cukup usecase
/// ini return tanpa melakukan apa pun (idempotent, aman dipanggil).
class ScheduleReminderUseCase {
  const ScheduleReminderUseCase(this._repository, this._scheduler);

  final ReminderRepository _repository;
  final NotificationScheduler _scheduler;

  Future<void> call(Reminder triggeredReminder) async {
    if (!triggeredReminder.isRepeating) return;

    final next = triggeredReminder.copyWith(
      dueDateTime: triggeredReminder.nextOccurrence(),
      isCompleted: false,
    );
    await _repository.update(next);
    await _scheduler.schedule(next);
  }
}
