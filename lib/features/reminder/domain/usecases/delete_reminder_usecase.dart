import '../repositories/notification_scheduler.dart';
import '../repositories/reminder_repository.dart';

/// Menghapus reminder — semua notifikasi terkait harus ikut dibatalkan
/// sebelum data dihapus, supaya tidak ada notifikasi "hantu" tersisa.
class DeleteReminderUseCase {
  const DeleteReminderUseCase(this._repository, this._scheduler);

  final ReminderRepository _repository;
  final NotificationScheduler _scheduler;

  Future<void> call(String reminderId) async {
    await _scheduler.cancel(reminderId);
    await _repository.delete(reminderId);
  }
}
