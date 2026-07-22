/// Konstanta global aplikasi — nilai yang dipakai lintas layer/fitur.
class AppConstants {
  AppConstants._();

  static const String appName = 'Reminder App';

  // Notification channel — Android mewajibkan channel id unik per app.
  static const String notificationChannelId = 'reminder_channel';
  static const String notificationChannelName = 'Reminder Notifications';
  static const String notificationChannelDescription =
      'Notifikasi untuk reminder yang telah dijadwalkan';

  // Action id untuk tombol aksi di notifikasi.
  static const String actionMarkComplete = 'action_mark_complete';
  static const String actionSnooze = 'action_snooze_5min';

  static const Duration snoozeDuration = Duration(minutes: 5);
}
