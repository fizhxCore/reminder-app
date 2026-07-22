/// Exception layer data — dilempar oleh datasource/repository saat
/// operasi database atau notifikasi gagal.
class DatabaseException implements Exception {
  const DatabaseException(this.message);
  final String message;

  @override
  String toString() => 'DatabaseException: $message';
}

class NotificationException implements Exception {
  const NotificationException(this.message);
  final String message;

  @override
  String toString() => 'NotificationException: $message';
}

class PermissionDeniedException implements Exception {
  const PermissionDeniedException(this.message);
  final String message;

  @override
  String toString() => 'PermissionDeniedException: $message';
}
