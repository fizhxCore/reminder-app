import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'reminder_table.g.dart';

/// Definisi tabel Drift — sengaja dipisah dari [ReminderModel] (mapper)
/// supaya perubahan schema database tidak langsung menyentuh layer
/// domain/entity.
class ReminderTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant(''))();
  IntColumn get colorValue => integer()();
  // Disimpan sebagai index int (0=low,1=medium,2=high) — lebih efisien
  // untuk sorting berdasarkan prioritas dibanding string.
  IntColumn get priorityIndex => integer()();
  DateTimeColumn get dueDateTime => dateTime()();
  TextColumn get repeatType => text()(); // nama enum RepeatType
  IntColumn get preReminderMinutes => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [ReminderTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Constructor khusus untuk unit test (in-memory database).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  // Lazy: koneksi database baru dibuka saat benar-benar diakses,
  // supaya startup app tidak terblokir I/O.
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'reminder_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
