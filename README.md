<p align="center">
  <img src="assets/jurnal-icon.svg" alt="Ikon Jurnal Hari Ini" width="128">
</p>

<h1 align="center">Jurnal Hari Ini</h1>

<p align="center">Satu kalimat untuk menyimpan bagian kecil dari harimu.</p>

<p align="center">
  <a href="https://flutter.dev">Flutter</a> ·
  Penyimpanan lokal ·
  Refleksi 30 hari
</p>

Jurnal pribadi berbasis Flutter untuk menyimpan satu kalimat dari setiap hari.

Jurnal ini dibuat untuk mencatat hal kecil yang biasanya cepat terlupakan. Kamu bisa menulis catatan hari ini, kembali ke tanggal sebelumnya, lalu melihat pola mood dan tema setelah beberapa hari.

## Fitur utama

| Fitur | Kegunaan |
| --- | --- |
| Satu kalimat | Menulis catatan dengan batas 160 karakter. |
| Mood dan tema | Memberi konteks pada setiap catatan. |
| Kalender riwayat | Mengisi, mengedit, atau menghapus catatan berdasarkan tanggal. |
| Refleksi | Membaca pola 7 hari, 30 hari, atau seluruh catatan. |
| Streak menulis | Melihat kebiasaan menulis saat ini dan rekor terpanjang. |
| Ekspor data | Menyalin jurnal sebagai JSON atau menyimpannya sebagai file. |
| Mode gelap | Mengubah tampilan sesuai kenyamanan membaca. |

## Dibangun dengan

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

## Status project

Versi saat ini masih berupa MVP pribadi. Pengingat harian belum tersedia.
