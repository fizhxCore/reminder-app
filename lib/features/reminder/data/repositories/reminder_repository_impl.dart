import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasource/reminder_local_datasource.dart';
import '../models/reminder_model.dart';

/// Implementasi konkret [ReminderRepository] — mengorkestrasi
/// datasource lokal dan melakukan mapping model <-> entity.
/// Tidak menyentuh notification sama sekali; scheduling notifikasi
/// jadi tanggung jawab usecase (lihat AddReminderUseCase dkk),
/// supaya repository ini fokus murni pada persistensi data (SRP).
class ReminderRepositoryImpl implements ReminderRepository {
  const ReminderRepositoryImpl(this._dataSource);

  final ReminderLocalDataSource _dataSource;

  @override
  Future<List<Reminder>> getAll() async {
    final rows = await _dataSource.getAll();
    return rows.map((row) => row.toEntity()).toList();
  }

  @override
  Future<Reminder?> getById(String id) async {
    final row = await _dataSource.getById(id);
    return row?.toEntity();
  }

  @override
  Future<void> add(Reminder reminder) {
    return _dataSource.insert(reminder.toCompanion());
  }

  @override
  Future<void> update(Reminder reminder) {
    return _dataSource.update(reminder.toCompanion());
  }

  @override
  Future<void> delete(String id) {
    return _dataSource.deleteById(id);
  }

  @override
  Stream<List<Reminder>> watchAll() {
    return _dataSource
        .watchAll()
        .map((rows) => rows.map((row) => row.toEntity()).toList());
  }
}
