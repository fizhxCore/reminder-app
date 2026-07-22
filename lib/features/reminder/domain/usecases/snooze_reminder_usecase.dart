import '../entities/reminder.dart';
import '../repositories/notification_scheduler.dart';

/// Snooze 5 menit dari sekarang — jadwal reminder utama di database
/// TIDAK berubah, hanya notifikasi tunda yang dijadwalkan ulang.
class SnoozeReminderUseCase {
  const SnoozeReminderUseCase(this._scheduler);

  final NotificationScheduler _scheduler;

  Future<void> call(Reminder reminder) async {
    await _scheduler.snooze(reminder);
  }
}
