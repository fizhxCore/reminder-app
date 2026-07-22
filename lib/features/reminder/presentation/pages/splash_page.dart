import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/reminder_di_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final service = ref.read(notificationServiceProvider);
    await service.init();

    final granted = await _showPermissionDialog();
    if (granted) {
      await service.requestPermissions();
    }

    if (mounted) context.go('/home');
  }

  /// Dialog penjelasan alasan meminta izin notifikasi, ditampilkan
  /// SEBELUM system permission dialog muncul — mengikuti best practice
  /// "permission priming" agar tingkat penerimaan izin lebih tinggi.
  Future<bool> _showPermissionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.notifications_active_outlined),
        title: const Text('Izinkan Notifikasi'),
        content: const Text(
          'Reminder App perlu mengirim notifikasi supaya kamu tidak '
          'melewatkan pengingat yang sudah dijadwalkan, walau aplikasi '
          'sedang tidak dibuka.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Nanti Saja'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Izinkan'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primaryContainer,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_active_rounded,
              size: 72,
              color: scheme.onPrimaryContainer,
            ),
            const SizedBox(height: 16),
            Text(
              'Reminder App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: scheme.onPrimaryContainer),
          ],
        ),
      ),
    );
  }
}
