import 'package:drift/drift.dart';

import '../models/reminder_table.dart';

/// Wrapper tipis di atas generated Drift DAO (`AppDatabase`).
///
/// Kenapa perlu layer ini walau sudah ada Drift generated code:
/// supaya [ReminderRepositoryImpl] tidak bergantung langsung ke
/// `AppDatabase` (memudahkan mock saat testing repository) dan
/// query kompleks (misal gabungan where clause) terpusat di satu
/// tempat, bukan tersebar di repository.
class ReminderLocalDataSource {
  const ReminderLocalDataSource(this._db);

  final AppDatabase _db;

  Future<List<ReminderTableData>> getAll() {
    return _db.select(_db.reminderTable).get();
  }

  Future<ReminderTableData?> getById(String id) {
    return (_db.select(_db.reminderTable)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<ReminderTableData>> watchAll() {
    return (_db.select(_db.reminderTable)
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.dueDateTime)]))
        .watch();
  }

  Future<void> insert(ReminderTableCompanion companion) {
    return _db.into(_db.reminderTable).insertOnConflictUpdate(companion);
  }

  Future<void> update(ReminderTableCompanion companion) {
    return _db.update(_db.reminderTable).replace(companion);
  }

  Future<void> deleteById(String id) {
    return (_db.delete(_db.reminderTable)..where((tbl) => tbl.id.equals(id)))
        .go();
  }
}
