# Troubleshooting Audio Player

## Masalah Umum dan Solusi

### 1. Error "File rekaman tidak ditemukan"
**Penyebab:** File audio tidak tersimpan dengan benar atau path tidak valid
**Solusi:**
- Pastikan permission storage sudah diberikan
- Periksa apakah direktori penyimpanan dapat diakses
- Pastikan format file yang direkam adalah .m4a

### 2. Error "File rekaman kosong"
**Penyebab:** Proses perekaman gagal atau terhenti sebelum selesai
**Solusi:**
- Pastikan permission mikrofon sudah diberikan
- Periksa apakah ada aplikasi lain yang menggunakan mikrofon
- Coba rekam ulang dengan durasi yang lebih pendek

### 3. Error "Format file rekaman tidak didukung"
**Penyebab:** Format audio tidak kompatibel dengan audio player
**Solusi:**
- Gunakan format .m4a (AAC) yang sudah dikonfigurasi
- Pastikan encoder yang digunakan adalah AudioEncoder.aacLc

### 4. Error "Izin akses file ditolak"
**Penyebab:** Permission untuk mengakses file tidak diberikan
**Solusi:**
- Berikan permission storage di pengaturan aplikasi
- Restart aplikasi setelah memberikan permission

### 5. Audio tidak terdengar
**Penyebab:** Volume sistem atau aplikasi terlalu rendah
**Solusi:**
- Periksa volume sistem
- Pastikan tidak ada headphone yang terhubung
- Coba dengan speaker eksternal

## Debugging

### Log yang Perlu Diperhatikan:
1. `Attempting to play recording from path: [path]` - Memulai pemutaran
2. `File size: [size] bytes` - Ukuran file audio
3. `Audio playback started: [path]` - Pemutaran berhasil dimulai
4. `Error playing audio: [error]` - Error yang terjadi

### Cara Debug:
1. Buka Developer Tools di Flutter
2. Periksa console log untuk pesan error
3. Gunakan `print()` statements untuk debugging
4. Periksa file manager untuk memastikan file tersimpan

## Konfigurasi Android

### Permissions yang Diperlukan:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

### Versi Dependencies:
- audioplayers: ^5.0.0
- record: ^6.0.0
- path_provider: ^2.1.3
- permission_handler: ^11.3.1

## Tips Penggunaan

1. **Rekam dengan Durasi Pendek:** Mulai dengan rekaman 5-10 detik untuk testing
2. **Periksa Permission:** Pastikan semua permission sudah diberikan sebelum merekam
3. **Restart Aplikasi:** Jika ada masalah, restart aplikasi untuk reset state
4. **Gunakan Headphone:** Untuk testing yang lebih baik, gunakan headphone
5. **Periksa Storage:** Pastikan ada ruang penyimpanan yang cukup

## Error Codes

| Error | Penyebab | Solusi |
|-------|----------|--------|
| FileSystemException | File tidak dapat diakses | Periksa permission dan path |
| FormatException | Format tidak didukung | Gunakan format .m4a |
| PermissionException | Permission ditolak | Berikan permission di settings |
| AudioPlayerException | Audio player error | Restart aplikasi |

## Support

Jika masalah masih berlanjut:
1. Periksa versi Flutter dan dependencies
2. Coba di device/emulator yang berbeda
3. Periksa log error lengkap
4. Pastikan tidak ada konflik dengan aplikasi lain 