import '../entities/reminder.dart';
import '../repositories/reminder_repository.dart';

/// Mengambil seluruh reminder sebagai stream (reactive). Filtering,
/// sorting, dan search dilakukan di layer presentation (provider)
/// supaya usecase ini tetap sederhana dan reusable.
class GetRemindersUseCase {
  const GetRemindersUseCase(this._repository);

  final ReminderRepository _repository;

  Stream<List<Reminder>> call() => _repository.watchAll();
}
