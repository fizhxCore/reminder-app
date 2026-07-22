import 'package:flutter_test/flutter_test.dart';
import 'package:reminder_app/features/reminder/domain/entities/pre_reminder_offset.dart';
import 'package:reminder_app/features/reminder/domain/entities/reminder.dart';
import 'package:reminder_app/features/reminder/domain/entities/repeat_type.dart';

void main() {
  group('Reminder.nextOccurrence', () {
    Reminder buildReminder({
      required DateTime due,
      required RepeatType repeat,
    }) {
      return Reminder(
        id: 'test-id',
        title: 'Test',
        note: '',
        category: '',
        colorValue: 0xFF000000,
        priority: ReminderPriority.medium,
        dueDateTime: due,
        repeatType: repeat,
        preReminderOffset: PreReminderOffset.onTime,
        isCompleted: false,
        createdAt: due,
      );
    }

    test('daily repeat adds exactly one day', () {
      final reminder = buildReminder(
        due: DateTime(2026, 7, 22, 19, 0),
        repeat: RepeatType.daily,
      );
      expect(reminder.nextOccurrence(), DateTime(2026, 7, 23, 19, 0));
    });

    test('weekly repeat adds seven days', () {
      final reminder = buildReminder(
        due: DateTime(2026, 7, 22, 19, 0),
        repeat: RepeatType.weekly,
      );
      expect(reminder.nextOccurrence(), DateTime(2026, 7, 29, 19, 0));
    });

    test('monthly repeat handles day-31 overflow into shorter month', () {
      final reminder = buildReminder(
        due: DateTime(2026, 1, 31, 8, 0),
        repeat: RepeatType.monthly,
      );
      // Februari 2026 hanya punya 28 hari.
      expect(reminder.nextOccurrence(), DateTime(2026, 2, 28, 8, 0));
    });

    test('notifyAt subtracts preReminderOffset correctly', () {
      final reminder = Reminder(
        id: 'x',
        title: 'Belajar Matematika',
        note: '',
        category: '',
        colorValue: 0xFF000000,
        priority: ReminderPriority.high,
        dueDateTime: DateTime(2026, 7, 25, 19, 0),
        repeatType: RepeatType.none,
        preReminderOffset: PreReminderOffset.fiveMinutes,
        isCompleted: false,
        createdAt: DateTime(2026, 7, 20),
      );
      expect(reminder.notifyAt, DateTime(2026, 7, 25, 18, 55));
    });
  });
}
