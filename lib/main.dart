import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/reminder/presentation/providers/settings_provider.dart';
import 'shared/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database timezone SEBELUM app berjalan — wajib untuk
  // akurasi jadwal notifikasi (lihat NotificationService).
  await NotificationService.initializeTimeZones();

  // Data locale Indonesia untuk format tanggal (intl) — tanpa ini
  // DateFormat('...', 'id_ID') akan throw LocaleDataException.
  await initializeDateFormatting('id_ID', null);

  runApp(const ProviderScope(child: ReminderApp()));
}

class ReminderApp extends ConsumerWidget {
  const ReminderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(settingsProvider).themeMode;

    return MaterialApp.router(
      title: 'Reminder App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
