# Jurnal Hari Ini

Jurnal pribadi berbasis Flutter untuk menyimpan satu kalimat dari setiap hari.

Jurnal ini dibuat untuk mencatat hal kecil yang biasanya cepat terlupakan. Kamu bisa menulis catatan hari ini, kembali ke tanggal sebelumnya, lalu melihat pola mood dan tema setelah beberapa hari.

## Fitur

- Menulis satu kalimat dengan batas 160 karakter.
- Memberi nilai mood dan tema pada setiap catatan.
- Mengisi catatan untuk tanggal sebelumnya jika sempat lupa.
- Mengedit atau menghapus catatan dari kalender riwayat.
- Melihat refleksi 7 hari, 30 hari, atau seluruh catatan.
- Melihat grafik mood, tema yang sering muncul, dan streak menulis.
- Menggunakan mode gelap.
- Menyalin jurnal sebagai JSON atau menyimpannya sebagai file.
- Menyimpan data secara lokal di perangkat.

## Teknologi

- Flutter
- Dart
- Material 3
- `shared_preferences` untuk penyimpanan lokal
- `table_calendar` untuk riwayat tanggal
- `fl_chart` untuk grafik mood
- `path_provider` untuk ekspor file JSON

## Menjalankan project

Pastikan Flutter dan Android SDK sudah terpasang, lalu jalankan:

```bash
flutter pub get
flutter run
```

Untuk menjalankan test:

```bash
flutter test
```

## Struktur project

```text
lib/
├── core/       # Warna, tema, dan pilihan mood atau tema
├── features/   # Halaman home, riwayat, refleksi, onboarding, pengaturan
├── models/     # Model JournalEntry
├── services/   # Penyimpanan jurnal, pengaturan, dan ekspor data
├── app.dart    # Root aplikasi dan navigasi utama
└── main.dart   # Entry point aplikasi
```

## Catatan privasi

Jurnal disimpan secara lokal menggunakan penyimpanan perangkat. Aplikasi ini tidak memiliki akun atau server untuk mengirim isi jurnal.

## Status

Versi saat ini masih berupa MVP pribadi. Pengingat harian belum tersedia.
