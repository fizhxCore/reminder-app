import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/reminder/domain/entities/reminder.dart';
import '../../features/reminder/domain/repositories/notification_scheduler.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

/// Nama port isolate untuk komunikasi background handler -> UI isolate
/// saat action notifikasi ditekan ketika app dalam keadaan background/terminated.
const String kNotificationActionPortName = 'notification_action_port';

/// Implementasi konkret [NotificationScheduler] menggunakan
/// `flutter_local_notifications` + `timezone`.
///
/// Kenapa timezone package wajib: `DateTime.now()` murni tidak cukup
/// untuk menjadwalkan notifikasi akurat — jika pengguna berpindah zona
/// waktu, jadwal yang disimpan sebagai wall-clock time bisa meleset.
/// `tz.TZDateTime` mengikat waktu ke lokasi timezone spesifik sehingga
/// platform native (AlarmManager di Android) tetap menghitung dengan benar.
class NotificationService implements NotificationScheduler {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<void> initializeTimeZones() async {
    tz_data.initializeTimeZones();
    // Catatan: idealnya lokasi timezone device dideteksi lewat package
    // `flutter_timezone` lalu di-set via tz.setLocalLocation(...).
    // Di sini kita pakai tz.local sebagai default dan biarkan
    // `initializeTimeZones()` menyediakan database lengkap IANA.
  }

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onForegroundResponse,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundResponse,
    );

    const channel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.max,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Minta izin notifikasi + exact alarm. Dipanggil sekali saat
  /// app pertama kali dibuka (lihat SplashPage / permission dialog).
  Future<bool> requestPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final notifGranted =
        await androidImpl?.requestNotificationsPermission() ?? false;
    await androidImpl?.requestExactAlarmsPermission();
    return notifGranted;
  }

  int _notificationIdFor(String reminderId) => reminderId.hashCode & 0x7fffffff;

  @override
  Future<void> schedule(Reminder reminder) async {
    try {
      final notifyAt = reminder.notifyAt;
      final scheduledDate = tz.TZDateTime.from(notifyAt, tz.local);

      // Jika waktu sudah lewat (misal offset negatif akibat edit),
      // jangan jadwalkan supaya tidak error dari plugin.
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

      final isExactTime = notifyAt.isAtSameMomentAs(reminder.dueDateTime);
      final body = isExactTime
          ? 'Sekarang waktunya ${reminder.title}.'
          : '${reminder.title} dimulai dalam ${_offsetLabel(reminder)}.';

      await _plugin.zonedSchedule(
        _notificationIdFor(reminder.id),
        '🔔 Waktunya Reminder',
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            actions: const [
              AndroidNotificationAction(
                AppConstants.actionMarkComplete,
                '✅ Tandai Selesai',
              ),
              AndroidNotificationAction(
                AppConstants.actionSnooze,
                '⏰ Snooze 5 Menit',
              ),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id,
      );
    } catch (e) {
      throw NotificationException('Gagal menjadwalkan notifikasi: $e');
    }
  }

  String _offsetLabel(Reminder reminder) {
    final minutes = reminder.preReminderOffset.minutes;
    if (minutes >= 1440) return '1 hari';
    if (minutes >= 60) return '${minutes ~/ 60} jam';
    return '$minutes menit';
  }

  @override
  Future<void> cancel(String reminderId) async {
    try {
      await _plugin.cancel(_notificationIdFor(reminderId));
    } catch (e) {
      throw NotificationException('Gagal membatalkan notifikasi: $e');
    }
  }

  @override
  Future<void> snooze(Reminder reminder,
      {Duration duration = AppConstants.snoozeDuration}) async {
    try {
      final snoozeTime =
          tz.TZDateTime.now(tz.local).add(duration);
      await _plugin.zonedSchedule(
        _notificationIdFor(reminder.id),
        '🔔 Waktunya Reminder',
        'Sekarang waktunya ${reminder.title}.',
        snoozeTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDescription,
            importance: Importance.max,
            priority: Priority.high,
            actions: const [
              AndroidNotificationAction(
                AppConstants.actionMarkComplete,
                '✅ Tandai Selesai',
              ),
              AndroidNotificationAction(
                AppConstants.actionSnooze,
                '⏰ Snooze 5 Menit',
              ),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id,
      );
    } catch (e) {
      throw NotificationException('Gagal snooze notifikasi: $e');
    }
  }

  /// Dipanggil saat app dalam foreground dan user menekan notifikasi/aksi.
  static void _onForegroundResponse(NotificationResponse response) {
    _forwardToUiIsolate(response);
  }

  /// Dipanggil di isolate terpisah saat app background/terminated.
  /// WAJIB berupa top-level/static function (requirement plugin).
  @pragma('vm:entry-point')
  static void _onBackgroundResponse(NotificationResponse response) {
    _forwardToUiIsolate(response);
  }

  static void _forwardToUiIsolate(NotificationResponse response) {
    final sendPort = IsolateNameServer.lookupPortByName(
      kNotificationActionPortName,
    );
    sendPort?.send({
      'actionId': response.actionId,
      'payload': response.payload,
    });
  }
}
