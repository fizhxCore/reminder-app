import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(_themeModeLabel(settings.themeMode)),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) {
              notifier.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
          ListTile(
            title: const Text('Ikuti Tema Sistem'),
            trailing: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (mode) {
                if (mode != null) notifier.setThemeMode(mode);
              },
            ),
            onTap: () => notifier.setThemeMode(ThemeMode.system),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Format Waktu 24 Jam'),
            subtitle: Text(settings.use24Hour ? '14:30' : '2:30 PM'),
            value: settings.use24Hour,
            onChanged: notifier.setUse24Hour,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup'),
            subtitle: const Text('Segera hadir'),
            enabled: false,
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Reminder App v1.0.0'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Reminder App',
              applicationVersion: '1.0.0',
              applicationLegalese:
                  'Dibangun dengan Flutter, Clean Architecture, Riverpod & Drift.',
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Nonaktif';
      case ThemeMode.dark:
        return 'Aktif';
      case ThemeMode.system:
        return 'Mengikuti sistem';
    }
  }
}
