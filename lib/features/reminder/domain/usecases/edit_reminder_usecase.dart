import '../entities/reminder.dart';
import '../repositories/notification_scheduler.dart';
import '../repositories/reminder_repository.dart';

/// Mengedit reminder: batalkan notifikasi lama, simpan perubahan,
/// lalu jadwalkan ulang notifikasi baru sesuai data terbaru.
class EditReminderUseCase {
  const EditReminderUseCase(this._repository, this._scheduler);

  final ReminderRepository _repository;
  final NotificationScheduler _scheduler;

  Future<void> call(Reminder updatedReminder) async {
    await _scheduler.cancel(updatedReminder.id);
    await _repository.update(updatedReminder);
    if (!updatedReminder.isCompleted) {
      await _scheduler.schedule(updatedReminder);
    }
  }
}
