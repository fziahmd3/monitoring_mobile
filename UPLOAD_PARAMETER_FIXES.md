# Perbaikan Parameter Upload

## Masalah yang Diperbaiki

### 1. Error 400 - Bad Request
**Masalah:** Backend Flask mengembalikan error 400 saat upload rekaman
```
10.181.189.172 - - [26/Jul/2025 15:31:01] "POST /upload_recording HTTP/1.1" 400 -
```

**Penyebab:**
- Parameter `kodeGuru` dikirim sebagai string kosong (`''`) untuk santri yang merekam sendiri
- Backend memvalidasi bahwa `kodeGuru` tidak boleh kosong
- Tidak ada penanganan untuk kasus self-recording (santri merekam sendiri)

**Solusi:**
- Menambahkan validasi di aplikasi Flutter untuk hanya mengirim `kodeGuru` jika tidak kosong
- Memperbaiki backend untuk menangani kasus di mana `kodeGuru` tidak dikirim
- Menambahkan logging untuk debugging

## File yang Dimodifikasi

### 1. `lib/screens/rekam_hafalan_screen.dart`
- Menambahkan validasi untuk `kodeGuru` sebelum dikirim
- Menambahkan logging untuk debugging parameter
- Hanya mengirim `kodeGuru` jika tidak kosong

### 2. `app/routes.py`
- Memperbaiki validasi parameter di endpoint `/upload_recording`
- Menambahkan penanganan untuk kasus self-recording
- Menambahkan logging detail untuk debugging

## Logika Upload

### 1. Santri Merekam Sendiri
```
kodeSantri: "SANTRI001"
kodeGuru: "" (kosong)
→ Backend akan menggunakan kodeSantri sebagai kodeGuru
→ File disimpan: SANTRI001_SANTRI001_filename.m4a
```

### 2. Guru Merekam untuk Santri
```
kodeSantri: "SANTRI001"
kodeGuru: "GURU001"
→ Backend akan menggunakan kodeGuru yang dikirim
→ File disimpan: GURU001_SANTRI001_filename.m4a
```

## Perubahan Kode

### Aplikasi Flutter
```dart
var request = http.MultipartRequest('POST', uri)
  ..fields['kodeSantri'] = widget.kodeSantri;

// Hanya kirim kodeGuru jika tidak kosong
if (widget.kodeGuru.isNotEmpty) {
  request.fields['kodeGuru'] = widget.kodeGuru;
}
```

### Backend Flask
```python
if not kode_santri:
    print("Error: Missing kodeSantri")
    return jsonify({'success': False, 'message': 'Missing kodeSantri'}), 400

# Jika kodeGuru tidak ada, gunakan kodeSantri sebagai guru (self-recording)
if not kode_guru:
    kode_guru = kode_santri
    print(f"Using kodeSantri as kodeGuru: {kode_guru}")
```

## Logging untuk Debugging

### Aplikasi Flutter
```dart
print('Uploading recording...');
print('kodeSantri: ${widget.kodeSantri}');
print('kodeGuru: ${widget.kodeGuru}');
print('File path: $path');
```

### Backend Flask
```python
print("=== Upload Recording Request ===")
print(f"Files: {list(request.files.keys())}")
print(f"Form data: {list(request.form.keys())}")
print(f"File: {file.filename if file else 'None'}")
print(f"Kode Santri: {kode_santri}")
print(f"Kode Guru: {kode_guru}")
```

## Testing

### 1. Test Santri Merekam Sendiri
1. Login sebagai Santri
2. Rekam hafalan
3. Upload rekaman
4. Periksa log backend untuk memastikan `kodeGuru` menggunakan `kodeSantri`

### 2. Test Guru Merekam untuk Santri
1. Login sebagai Guru
2. Masukkan kode santri
3. Rekam hafalan
4. Upload rekaman
5. Periksa log backend untuk memastikan `kodeGuru` menggunakan nilai yang dikirim

### 3. Test Error Cases
1. Upload tanpa file
2. Upload tanpa kodeSantri
3. Upload dengan file format tidak didukung

## Response yang Diharapkan

### Success (200)
```json
{
  "success": true,
  "message": "File uploaded",
  "filename": "SANTRI001_SANTRI001_hafalan_recording_1234567890.m4a"
}
```

### Error (400)
```json
{
  "success": false,
  "message": "No file part"
}
```

## Struktur File yang Disimpan

### Format Nama File
```
{kode_guru}_{kode_santri}_{original_filename}
```

### Contoh
- Santri merekam sendiri: `SANTRI001_SANTRI001_hafalan_recording_1234567890.m4a`
- Guru merekam untuk santri: `GURU001_SANTRI001_hafalan_recording_1234567890.m4a`

## Troubleshooting

### 1. Error "Missing kodeSantri"
- Pastikan parameter `kodeSantri` dikirim dari aplikasi Flutter
- Periksa apakah `widget.kodeSantri` tidak null atau kosong

### 2. Error "No file part"
- Pastikan field `recording` ada dalam request
- Periksa apakah file path valid di aplikasi Flutter

### 3. Error "File type not allowed"
- Pastikan ekstensi file adalah m4a, mp3, wav, atau aac
- Periksa nama file asli

### 4. Error "No selected file"
- Pastikan file tidak kosong
- Periksa apakah file berhasil direkam

## Kesimpulan

Perbaikan ini mengatasi masalah parameter upload dengan:
- Menangani kasus self-recording (santri merekam sendiri)
- Memperbaiki validasi parameter di backend
- Menambahkan logging untuk debugging
- Memastikan kompatibilitas antara aplikasi Flutter dan backend Flask

Sekarang upload rekaman akan berfungsi baik untuk santri yang merekam sendiri maupun guru yang merekam untuk santri. 