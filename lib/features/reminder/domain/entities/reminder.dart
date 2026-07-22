import 'package:flutter/foundation.dart';

import 'pre_reminder_offset.dart';
import 'repeat_type.dart';

/// Prioritas reminder. Urutan enum sengaja dari rendah -> tinggi
/// supaya bisa langsung dibandingkan dengan `index` saat sorting.
enum ReminderPriority {
  low('Rendah'),
  medium('Sedang'),
  high('Tinggi');

  const ReminderPriority(this.label);
  final String label;
}

/// Entity murni domain — tidak tahu apa-apa soal Drift, JSON, atau UI.
/// Semua field final & immutable; perubahan data dilakukan lewat
/// [copyWith] supaya aman dipakai di Riverpod state.
@immutable
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.note,
    required this.category,
    required this.colorValue,
    required this.priority,
    required this.dueDateTime,
    required this.repeatType,
    required this.preReminderOffset,
    required this.isCompleted,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String note;
  final String category;
  final int colorValue;
  final ReminderPriority priority;
  final DateTime dueDateTime;
  final RepeatType repeatType;
  final PreReminderOffset preReminderOffset;
  final bool isCompleted;
  final DateTime createdAt;

  /// Waktu aktual notifikasi akan berbunyi (dueDateTime dikurangi offset).
  DateTime get notifyAt =>
      dueDateTime.subtract(Duration(minutes: preReminderOffset.minutes));

  bool get isOverdue =>
      !isCompleted && dueDateTime.isBefore(DateTime.now());

  bool get isRepeating => repeatType != RepeatType.none;

  Reminder copyWith({
    String? title,
    String? note,
    String? category,
    int? colorValue,
    ReminderPriority? priority,
    DateTime? dueDateTime,
    RepeatType? repeatType,
    PreReminderOffset? preReminderOffset,
    bool? isCompleted,
  }) {
    return Reminder(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      category: category ?? this.category,
      colorValue: colorValue ?? this.colorValue,
      priority: priority ?? this.priority,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      repeatType: repeatType ?? this.repeatType,
      preReminderOffset: preReminderOffset ?? this.preReminderOffset,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  /// Menghitung due date berikutnya untuk reminder berulang.
  /// Dipanggil oleh [ScheduleReminderUseCase] setelah notifikasi
  /// pertama terpicu, supaya instance berikutnya bisa dijadwalkan.
  DateTime nextOccurrence() {
    switch (repeatType) {
      case RepeatType.none:
        return dueDateTime;
      case RepeatType.daily:
        return dueDateTime.add(const Duration(days: 1));
      case RepeatType.weekly:
        return dueDateTime.add(const Duration(days: 7));
      case RepeatType.monthly:
        // Tambah bulan secara eksplisit (bukan Duration) supaya
        // tanggal 31 di bulan pendek tidak overflow salah -
        // fallback ke tanggal terakhir bulan tersebut.
        final nextMonth = dueDateTime.month == 12 ? 1 : dueDateTime.month + 1;
        final nextYear =
            dueDateTime.month == 12 ? dueDateTime.year + 1 : dueDateTime.year;
        final daysInNextMonth =
            DateTime(nextYear, nextMonth + 1, 0).day;
        final safeDay = dueDateTime.day > daysInNextMonth
            ? daysInNextMonth
            : dueDateTime.day;
        return DateTime(
          nextYear,
          nextMonth,
          safeDay,
          dueDateTime.hour,
          dueDateTime.minute,
        );
    }
  }

  @override
  bool operator ==(Object other) => other is Reminder && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
