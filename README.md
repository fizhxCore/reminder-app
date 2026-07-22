# Reminder App

Aplikasi pengingat pribadi dibangun dengan Flutter, mengikuti Clean
Architecture, sebagai portfolio project (siap dikembangkan lebih lanjut
ke arah rilis Play Store).

## Tech Stack

| Kebutuhan | Package | Alasan |
|---|---|---|
| State management | `flutter_riverpod` | Compile-safe DI + reactive state, tanpa boilerplate `InheritedWidget` |
| Routing | `go_router` | Declarative routing, deep-link ready |
| Database | `drift` | Query relasional (filter+sort kombinasi) lebih natural dibanding key-value store; type-safe lewat codegen |
| Notifikasi | `flutter_local_notifications` + `timezone` | Local-only (tanpa FCM), akurat lintas timezone |
| Format | `intl` | Locale Indonesia untuk tanggal/waktu |
| Preferensi ringan | `shared_preferences` | Tema & format jam — terlalu sederhana untuk butuh Drift |

## Menjalankan Project

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generate Drift .g.dart
flutter run
```

`build_runner` WAJIB dijalankan sekali sebelum build pertama — file
`reminder_table.g.dart` (generated Drift code) belum ada di repo ini
karena sengaja tidak di-commit (lihat `.gitignore`).

## Arsitektur

```
lib/
├── core/            → infrastruktur lintas fitur (theme, service, utils)
├── features/reminder/
│   ├── data/        → Drift table, mapper, datasource, repository impl
│   ├── domain/      → entities, repository interface, usecases (murni Dart, no Flutter import)
│   └── presentation/→ pages, widgets, Riverpod providers
└── shared/          → app_router.dart (Go Router)
```

### Alur data (contoh: tambah reminder)

`AddReminderPage` → `ReminderActions.add()` → `AddReminderUseCase` →
`ReminderRepository.add()` (simpan ke Drift) → sekaligus
`NotificationScheduler.schedule()` (jadwalkan notifikasi) → stream Drift
otomatis emit perubahan → `HomePage` refresh via `StreamProvider`.

### Keputusan desain penting

- **Drift dipilih atas Hive** — kebutuhan filter kombinasi (hari ini +
  prioritas tinggi) dan sorting multi-kolom lebih natural dengan SQL.
- **Reschedule notifikasi manual**, bukan `matchDateTimeComponents` bawaan
  plugin — supaya kasus bulanan (tanggal 31 di bulan pendek) bisa
  ditangani eksplisit lewat `Reminder.nextOccurrence()`.
- **`NotificationScheduler` sebagai interface di domain** — Dependency
  Inversion, supaya usecase bisa di-unit-test tanpa method channel
  platform asli.
- **DI lewat Riverpod `Provider`**, bukan `get_it` terpisah — satu
  composition root (`reminder_di_providers.dart`).

## Fitur

- CRUD reminder (judul, catatan, kategori, warna, prioritas)
- Reminder berulang (harian/mingguan/bulanan) dengan auto-reschedule
- Pre-reminder configurable (tepat waktu s.d. 1 hari sebelumnya)
- Notification action: Tandai Selesai & Snooze 5 Menit (bekerja walau app tertutup)
- Search, filter (hari ini/besok/minggu ini/prioritas tinggi/selesai), sort
- Dark mode, format waktu 12/24 jam

## Belum diimplementasi (di luar scope batch ini)

- Deteksi timezone otomatis device (saat ini pakai `tz.local` default —
  untuk produksi tambahkan package `flutter_timezone` dan panggil
  `tz.setLocalLocation()` di `NotificationService.initializeTimeZones()`)
- Fitur Backup (masih placeholder di Settings, sesuai instruksi awal)
- Unit test menyeluruh (baru ada skeleton di `test/`)
