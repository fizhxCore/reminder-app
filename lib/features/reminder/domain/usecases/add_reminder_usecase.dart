import '../entities/reminder.dart';
import '../repositories/notification_scheduler.dart';
import '../repositories/reminder_repository.dart';

/// Satu usecase = satu tanggung jawab: menambah reminder baru
/// sekaligus menjadwalkan notifikasinya.
///
/// Dipanggil seperti function lewat `call()` override, sehingga
/// pemanggilan di provider cukup `addReminderUseCase(reminder)`.
class AddReminderUseCase {
  const AddReminderUseCase(this._repository, this._scheduler);

  final ReminderRepository _repository;
  final NotificationScheduler _scheduler;

  Future<void> call(Reminder reminder) async {
    await _repository.add(reminder);
    if (!reminder.isCompleted) {
      await _scheduler.schedule(reminder);
    }
  }
}
