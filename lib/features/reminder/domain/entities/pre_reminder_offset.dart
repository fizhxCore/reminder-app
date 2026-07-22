/// Berapa lama sebelum waktu reminder notifikasi harus muncul.
///
/// Disimpan sebagai menit (int) di database supaya fleksibel, tapi
/// dibungkus enum di layer domain/presentation agar pilihan di UI
/// selalu konsisten dengan yang didukung notification scheduler.
enum PreReminderOffset {
  onTime(0, 'Tepat pada waktunya'),
  fiveMinutes(5, '5 menit sebelumnya'),
  tenMinutes(10, '10 menit sebelumnya'),
  fifteenMinutes(15, '15 menit sebelumnya'),
  thirtyMinutes(30, '30 menit sebelumnya'),
  oneHour(60, '1 jam sebelumnya'),
  oneDay(1440, '1 hari sebelumnya');

  const PreReminderOffset(this.minutes, this.label);

  final int minutes;
  final String label;

  static PreReminderOffset fromMinutes(int minutes) {
    return PreReminderOffset.values.firstWhere(
      (e) => e.minutes == minutes,
      orElse: () => PreReminderOffset.onTime,
    );
  }
}
