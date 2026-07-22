import 'package:flutter/material.dart';

/// Color scheme dibangun dari satu seed color (Material 3 dynamic
/// color generation) supaya light & dark mode otomatis harmonis
/// tanpa perlu menentukan tiap warna manual.
const Color _seedColor = Color(0xFF6750A4);

final ColorScheme lightColorScheme = ColorScheme.fromSeed(
  seedColor: _seedColor,
  brightness: Brightness.light,
);

final ColorScheme darkColorScheme = ColorScheme.fromSeed(
  seedColor: _seedColor,
  brightness: Brightness.dark,
);
