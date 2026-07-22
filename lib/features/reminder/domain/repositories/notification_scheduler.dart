import '../entities/reminder.dart';

/// Abstraksi penjadwalan notifikasi di layer domain.
///
/// Domain/usecase tidak boleh tahu soal `flutter_local_notifications`
/// secara langsung (Dependency Inversion Principle) — implementasi
/// konkretnya (`NotificationService`, di core/services) di-inject
/// lewat interface ini. Manfaatnya: usecase bisa di-unit-test dengan
/// fake scheduler tanpa method channel platform.
abstract class NotificationScheduler {
  /// Jadwalkan notifikasi untuk satu [Reminder] pada [reminder.notifyAt].
  /// Jika reminder berulang, hanya instance berikutnya yang dijadwalkan
  /// (bukan semua instance sekaligus) — instance selanjutnya dijadwalkan
  /// ulang setelah notifikasi ini terpicu.
  Future<void> schedule(Reminder reminder);

  /// Batalkan notifikasi milik satu reminder (dipakai saat edit/hapus/selesai).
  Future<void> cancel(String reminderId);

  /// Jadwalkan ulang notifikasi snooze 5 menit dari sekarang,
  /// tanpa mengubah jadwal reminder utama di database.
  Future<void> snooze(Reminder reminder, {Duration duration = const Duration(minutes: 5)});
}
