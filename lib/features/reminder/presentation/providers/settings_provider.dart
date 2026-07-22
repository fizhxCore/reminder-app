import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'settings.themeMode';
const _kUse24HourKey = 'settings.use24Hour';

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.use24Hour,
  });

  final ThemeMode themeMode;
  final bool use24Hour;

  SettingsState copyWith({ThemeMode? themeMode, bool? use24Hour}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      use24Hour: use24Hour ?? this.use24Hour,
    );
  }
}

/// Menyimpan preferensi ringan (bukan data reminder) ke SharedPreferences
/// — cukup untuk key-value sederhana seperti tema & format jam, tidak
/// perlu Drift untuk ini (over-engineering kalau dipaksakan ke database).
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
      : super(const SettingsState(
          themeMode: ThemeMode.system,
          use24Hour: true,
        )) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_kThemeModeKey);
    final use24Hour = prefs.getBool(_kUse24HourKey) ?? true;
    state = state.copyWith(
      themeMode: themeIndex != null
          ? ThemeMode.values[themeIndex]
          : ThemeMode.system,
      use24Hour: use24Hour,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeModeKey, mode.index);
  }

  Future<void> setUse24Hour(bool value) async {
    state = state.copyWith(use24Hour: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kUse24HourKey, value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
