# Fitur Progress Hafalan Santri untuk Guru

## Deskripsi
Fitur ini memungkinkan guru untuk melihat kemajuan hafalan dari santri yang dipilih berdasarkan kode santri. Guru dapat memilih santri dari daftar dan melihat detail progress hafalan mereka.

## Fitur Utama

### 1. Pemilihan Santri
- Dropdown menu untuk memilih santri dari daftar yang tersedia
- Menampilkan nama lengkap dan kode santri
- Interface yang user-friendly dengan icon dan styling yang menarik

### 2. Tampilan Progress Hafalan
- **Grafik Bar Chart**: Menampilkan rata-rata penilaian tajwid per surat (Top 5)
- **Progress Bar**: Visualisasi kemajuan per surat
- **Riwayat Penilaian**: Daftar penilaian terbaru dengan detail lengkap

### 3. Informasi Detail
- Tanggal penilaian
- Surat dan ayat yang dinilai
- Hasil penilaian (Kurang, Cukup, Baik, Sangat Baik)
- Catatan dari guru (jika ada)

## Implementasi Teknis

### File yang Dimodifikasi
- `lib/screens/dashboard_screen.dart`
  - Menambahkan tab baru "Progress Santri" di bottom navigation
  - Membuat widget `PilihSantriUntukProgress`
  - Mengintegrasikan dengan `KemajuanHafalanScreen`

### Widget Baru
```dart
class PilihSantriUntukProgress extends StatefulWidget
```
- Menangani pemilihan santri
- Menampilkan interface pemilihan yang intuitif
- Mengintegrasikan dengan API untuk mendapatkan daftar santri

### API Endpoint yang Digunakan
- `GET /api/daftar_santri` - Untuk mendapatkan daftar santri
- `GET /api/santri/{kode_santri}/penilaian` - Untuk mendapatkan data penilaian santri

## Cara Penggunaan

### Untuk Guru:
1. Login ke aplikasi sebagai guru
2. Pilih tab "Progress Santri" di bottom navigation
3. Pilih santri dari dropdown menu
4. Lihat detail progress hafalan santri yang dipilih
5. Gunakan tombol "Pilih Santri Lain" untuk melihat progress santri lainnya

### Interface:
- **Card Header**: Menampilkan judul dan deskripsi fitur
- **Dropdown Santri**: Pilihan santri dengan nama dan kode
- **Tombol Reset**: Untuk memilih santri lain
- **Progress View**: Tampilan detail kemajuan hafalan

## Keunggulan Fitur

1. **User Experience yang Baik**
   - Interface yang intuitif dan mudah digunakan
   - Loading states yang jelas
   - Error handling yang informatif

2. **Data yang Komprehensif**
   - Visualisasi data dengan grafik
   - Riwayat penilaian terbaru
   - Detail informasi yang lengkap

3. **Fleksibilitas**
   - Guru dapat melihat progress semua santri
   - Kemudahan beralih antar santri
   - Tampilan yang responsif

## Integrasi dengan Fitur Lain

- **Form Penilaian**: Terhubung dengan sistem penilaian yang ada
- **Dashboard**: Terintegrasi dengan dashboard guru
- **Profile**: Konsisten dengan sistem profil yang ada

## Testing

Untuk menguji fitur ini:
1. Login sebagai guru
2. Navigasi ke tab "Progress Santri"
3. Pilih santri dari dropdown
4. Verifikasi data yang ditampilkan
5. Test tombol "Pilih Santri Lain"

## Catatan Pengembangan

- Fitur ini menggunakan komponen yang sudah ada (`KemajuanHafalanScreen`)
- Menggunakan API yang sudah tersedia
- Konsisten dengan design pattern aplikasi
- Mengikuti standar coding Flutter yang ada 