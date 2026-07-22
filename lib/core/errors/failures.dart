/// Representasi error yang aman ditampilkan ke UI (pesan human-readable),
/// hasil konversi dari [Exception] di layer data/domain.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// Helper untuk membungkus try-catch berulang di provider/usecase
/// menjadi satu baris, sekaligus logging sederhana ke console debug.
Failure mapExceptionToFailure(Object error) {
  // ignore: avoid_print
  print('[Reminder App] Error: $error');
  final message = error.toString();
  if (message.contains('DatabaseException')) {
    return DatabaseFailure(message);
  }
  if (message.contains('NotificationException')) {
    return NotificationFailure(message);
  }
  if (message.contains('PermissionDeniedException')) {
    return PermissionFailure(message);
  }
  return UnknownFailure(message);
}
