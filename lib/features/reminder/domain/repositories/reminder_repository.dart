import '../entities/reminder.dart';

/// Kontrak domain untuk akses data reminder.
///
/// Domain hanya tahu interface ini — implementasi konkret (Drift)
/// ada di layer `data`, sehingga domain & usecase bisa di-test tanpa
/// menyentuh database asli.
abstract class ReminderRepository {
  Future<List<Reminder>> getAll();
  Future<Reminder?> getById(String id);
  Future<void> add(Reminder reminder);
  Future<void> update(Reminder reminder);
  Future<void> delete(String id);
  Stream<List<Reminder>> watchAll();
}
