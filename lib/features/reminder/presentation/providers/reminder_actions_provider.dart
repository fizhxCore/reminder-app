import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/reminder.dart';
import 'reminder_di_providers.dart';

/// Notifier tipis yang membungkus pemanggilan usecase supaya UI (page)
/// tidak memanggil banyak provider usecase satu-satu, dan supaya error
/// ditangani konsisten lewat [Result]/[Failure] di satu tempat.
class ReminderActions {
  ReminderActions(this._ref);

  final Ref _ref;

  Future<Failure?> add(Reminder reminder) async {
    try {
      await _ref.read(addReminderUseCaseProvider)(reminder);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  Future<Failure?> edit(Reminder reminder) async {
    try {
      await _ref.read(editReminderUseCaseProvider)(reminder);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  Future<Failure?> delete(String id) async {
    try {
      await _ref.read(deleteReminderUseCaseProvider)(id);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  Future<Failure?> complete(Reminder reminder) async {
    try {
      await _ref.read(completeReminderUseCaseProvider)(reminder);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  Future<Failure?> snooze(Reminder reminder) async {
    try {
      await _ref.read(snoozeReminderUseCaseProvider)(reminder);
      return null;
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}

final reminderActionsProvider = Provider<ReminderActions>((ref) {
  return ReminderActions(ref);
});
