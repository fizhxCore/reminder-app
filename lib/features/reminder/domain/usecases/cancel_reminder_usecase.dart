import '../repositories/notification_scheduler.dart';

/// Membatalkan notifikasi tanpa menyentuh data reminder di database.
/// Dipakai secara terpisah dari delete/edit saat hanya notifikasi
/// yang perlu dibatalkan (misal reminder ditandai selesai, non-repeat).
class CancelReminderUseCase {
  const CancelReminderUseCase(this._scheduler);

  final NotificationScheduler _scheduler;

  Future<void> call(String reminderId) async {
    await _scheduler.cancel(reminderId);
  }
}
