import 'package:intl/intl.dart';

/// Helper format tanggal/jam terpusat — dipakai lintas widget supaya
/// format tanggal Indonesia konsisten di seluruh app.
extension DateTimeFormatting on DateTime {
  String toDisplayDate() => DateFormat('d MMMM yyyy', 'id_ID').format(this);

  String toDisplayTime({bool use24Hour = true}) {
    final pattern = use24Hour ? 'HH:mm' : 'h:mm a';
    return DateFormat(pattern, 'id_ID').format(this);
  }

  String toDisplayDateTime({bool use24Hour = true}) {
    return '${toDisplayDate()} · ${toDisplayTime(use24Hour: use24Hour)}';
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday() => isSameDay(DateTime.now());

  bool isTomorrow() => isSameDay(DateTime.now().add(const Duration(days: 1)));

  bool isThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }
}
