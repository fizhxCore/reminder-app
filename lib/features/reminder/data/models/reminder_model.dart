import 'package:drift/drift.dart';

import '../../domain/entities/pre_reminder_offset.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/repeat_type.dart';
import 'reminder_table.dart';

/// Konversi dua arah antara row Drift ([ReminderTableData]) dan
/// [Reminder] (domain entity). Semua "pengetahuan" soal encoding
/// (enum -> string, menit -> offset, dsb) hidup di sini saja.
extension ReminderModelMapper on ReminderTableData {
  Reminder toEntity() {
    return Reminder(
      id: id,
      title: title,
      note: note,
      category: category,
      colorValue: colorValue,
      priority: ReminderPriority.values[priorityIndex],
      dueDateTime: dueDateTime,
      repeatType: RepeatType.fromName(repeatType),
      preReminderOffset: PreReminderOffset.fromMinutes(preReminderMinutes),
      isCompleted: isCompleted,
      createdAt: createdAt,
    );
  }
}

extension ReminderEntityMapper on Reminder {
  ReminderTableCompanion toCompanion() {
    return ReminderTableCompanion.insert(
      id: id,
      title: title,
      note: Value(note),
      category: Value(category),
      colorValue: colorValue,
      priorityIndex: priority.index,
      dueDateTime: dueDateTime,
      repeatType: repeatType.name,
      preReminderMinutes: preReminderOffset.minutes,
      isCompleted: Value(isCompleted),
      createdAt: createdAt,
    );
  }
}
