import 'package:flutter/material.dart';

import '../../features/reminder/domain/entities/reminder.dart';

/// Mapping warna untuk tiap prioritas — dipusatkan di sini supaya
/// konsisten di semua widget (badge, card, dsb) tanpa duplikasi.
class PriorityColors {
  PriorityColors._();

  static Color of(ReminderPriority priority) {
    switch (priority) {
      case ReminderPriority.low:
        return const Color(0xFF4CAF50);
      case ReminderPriority.medium:
        return const Color(0xFFFF9800);
      case ReminderPriority.high:
        return const Color(0xFFE53935);
    }
  }
}

/// Palet warna yang bisa dipilih pengguna untuk menandai reminder.
const List<int> reminderColorPalette = [
  0xFF6750A4, // ungu (default M3)
  0xFF1E88E5, // biru
  0xFF43A047, // hijau
  0xFFFB8C00, // oranye
  0xFFE53935, // merah
  0xFF00897B, // teal
  0xFF8E24AA, // magenta
];
