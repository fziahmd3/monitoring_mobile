# Fitur Upload Rekaman Hafalan

## Deskripsi
Fitur ini menambahkan kemampuan untuk memilih dan mengupload file audio rekaman hafalan yang sudah ada di perangkat, selain dari merekam langsung di aplikasi.

## Perubahan yang Dilakukan

### 1. Dependencies
- **File**: `monitoring_mobile/pubspec.yaml`
  - Menambahkan `file_picker: ^8.0.0` untuk memilih file dari perangkat

### 2. Mobile App (Flutter)
- **File**: `monitoring_mobile/lib/screens/rekam_hafalan_screen.dart`
  - Menambahkan import `package:file_picker/file_picker.dart`
  - Menambahkan fungsi `_pickAudioFile()` untuk memilih file audio
  - Menambahkan tombol "Pilih File" di sebelah tombol "Mulai Merekam"
  - Menampilkan nama file yang dipilih
  - Memisahkan tombol play dan upload ke baris terpisah

## Cara Penggunaan

### Untuk Guru/Santri:
1. Buka halaman "Rekam Hafalan"
2. Ada dua opsi untuk mendapatkan file audio:
   - **Rekam Langsung**: Klik "Mulai Merekam" untuk merekam hafalan langsung
   - **Pilih File**: Klik "Pilih File" untuk memilih file audio yang sudah ada di perangkat
3. Setelah file tersedia (baik dari rekaman atau pilihan):
   - Klik "Putar Rekaman" untuk mendengarkan
   - Klik "Upload Rekaman" untuk mengirim ke server

### Format File yang Didukung:
- MP3
- M4A
- WAV
- Dan format audio lainnya yang didukung oleh sistem

## Keunggulan Fitur

1. **Fleksibilitas**: Santri bisa menggunakan rekaman yang sudah ada
2. **Kemudahan**: Tidak perlu merekam ulang jika sudah punya file bagus
3. **Efisiensi**: Menghemat waktu dengan menggunakan file yang sudah siap
4. **User-friendly**: Interface yang jelas dengan informasi file yang dipilih

## Alur Kerja

```
1. User membuka halaman Rekam Hafalan
2. User memilih salah satu:
   ├── Rekam langsung (tombol "Mulai Merekam")
   └── Pilih file (tombol "Pilih File")
3. File audio tersedia
4. User dapat:
   ├── Putar rekaman untuk preview
   └── Upload rekaman ke server
```

## Teknis

### Fungsi Utama:
- `_pickAudioFile()`: Memilih file audio dari perangkat
- `_playRecording()`: Memutar file audio yang dipilih
- `_uploadRecording()`: Mengupload file ke server

### UI Layout:
```
[Mulai Merekam] [Pilih File]
File: nama_file.mp3
[Putar Rekaman] [Upload Rekaman]
```

### Error Handling:
- Validasi file yang dipilih
- Feedback ke user jika terjadi error
- Informasi status upload

## Catatan Penting

1. **Permission**: Aplikasi memerlukan izin untuk mengakses file di perangkat
2. **Format**: Pastikan file audio dalam format yang didukung
3. **Ukuran**: Perhatikan ukuran file untuk upload yang optimal
4. **Koneksi**: Pastikan koneksi internet stabil untuk upload 