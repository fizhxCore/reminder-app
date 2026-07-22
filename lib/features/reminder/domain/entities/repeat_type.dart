/// Interval pengulangan reminder.
///
/// Kenapa enum, bukan string bebas: supaya semua pengecekan interval
/// (reschedule, UI dropdown, dsb) type-safe dan exhaustive-checked oleh
/// compiler saat ada `switch`.
enum RepeatType {
  none,
  daily,
  weekly,
  monthly;

  String get label {
    switch (this) {
      case RepeatType.none:
        return 'Tidak berulang';
      case RepeatType.daily:
        return 'Harian';
      case RepeatType.weekly:
        return 'Mingguan';
      case RepeatType.monthly:
        return 'Bulanan';
    }
  }

  static RepeatType fromName(String name) {
    return RepeatType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => RepeatType.none,
    );
  }
}
