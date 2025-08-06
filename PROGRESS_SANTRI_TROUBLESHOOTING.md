# Troubleshooting Progress Hafalan Santri

## Masalah yang Ditemui
Error 404 saat mencoba melihat progress hafalan dari santri yang dipilih.

## Analisis Masalah

### 1. Error 404 - Not Found
```
Failed to load predictions: <!doctype html>
<html lang=en>
<title>404 Not Found</title>
<h1>Not Found</h1>
<p>The requested URL was not found on the server.</p>
```

### 2. Kemungkinan Penyebab
- **URL API tidak benar**: Endpoint tidak ditemukan di server
- **Koneksi server**: Server backend tidak berjalan
- **Konfigurasi URL**: Base URL tidak sesuai dengan server yang berjalan
- **Parameter kode santri**: Kode santri yang dikirim tidak valid

## Solusi yang Diterapkan

### 1. Enhanced Debugging
Menambahkan logging yang lebih detail untuk:
- URL yang digunakan
- Response status code
- Response body
- Error messages yang lebih informatif

### 2. Timeout Handling
Menambahkan timeout 10 detik untuk request API:
```dart
final response = await http.get(Uri.parse(apiUrl)).timeout(
  const Duration(seconds: 10),
  onTimeout: () {
    throw Exception('Request timeout');
  },
);
```

### 3. Error Messages yang Lebih Informatif
- Menampilkan status code dan response body pada error
- SnackBar notifications untuk error handling
- Debug information di console

### 4. Test Connection Button
Menambahkan tombol untuk test koneksi ke server:
- Test endpoint `/api/test_connection`
- Menampilkan hasil test di SnackBar
- Warna hijau untuk success, merah untuk error

## Langkah Troubleshooting

### 1. Periksa Server Backend
```bash
# Pastikan server Flask berjalan
cd monitoring_app
python run.py
```

### 2. Periksa Konfigurasi API
File: `lib/api_config.dart`
```dart
class ApiConfig {
  static String baseUrl = "https://constantly-disco-failed-baghdad.trycloudflare.com";
  // Pastikan URL ini benar dan server berjalan
}
```

### 3. Test Endpoint Manual
```bash
# Test endpoint daftar santri
curl https://constantly-disco-failed-baghdad.trycloudflare.com/api/daftar_santri

# Test endpoint penilaian santri
curl https://constantly-disco-failed-baghdad.trycloudflare.com/api/santri/SANTRI001/penilaian
```

### 4. Periksa Log Aplikasi
Lihat output console untuk:
- URL yang digunakan
- Response status
- Error messages

## Debugging Steps

### 1. Test Connection
1. Buka aplikasi mobile
2. Login sebagai guru
3. Pilih tab "Progress Santri"
4. Klik tombol "Test Connection"
5. Periksa hasil di SnackBar

### 2. Periksa Daftar Santri
1. Pastikan dropdown santri terisi
2. Jika kosong, periksa log untuk error
3. Test endpoint `/api/daftar_santri` manual

### 3. Test Progress Santri
1. Pilih santri dari dropdown
2. Periksa log untuk URL yang digunakan
3. Verifikasi kode santri yang dikirim

## Endpoint yang Digunakan

### 1. Daftar Santri
```
GET /api/daftar_santri
Response: [{"kode_santri": "...", "nama_lengkap": "..."}]
```

### 2. Penilaian Santri
```
GET /api/santri/{kode_santri}/penilaian
Response: [{"penilaian_id": 1, "surat": "...", ...}]
```

### 3. Test Connection
```
GET /api/test_connection
Response: {"message": "Server is running"}
```

## Monitoring dan Logging

### 1. Console Logs
Periksa output console untuk:
```
=== Fetch Santri List (Progress) ===
API URL: https://...
Base URL: https://...
Response status: 200
Decoded santri list: [...]
```

### 2. Error Handling
Error messages yang ditampilkan:
- Network timeout
- Server error (status code)
- Connection refused
- Invalid response format

## Prevention Measures

### 1. Server Health Check
- Implementasi endpoint `/api/health`
- Regular monitoring server status
- Auto-retry mechanism

### 2. Caching
- Cache daftar santri untuk mengurangi request
- Offline mode untuk data yang sudah di-cache

### 3. User Feedback
- Loading indicators
- Error messages yang user-friendly
- Retry buttons untuk failed requests

## Next Steps

1. **Verifikasi Server**: Pastikan backend server berjalan
2. **Test Endpoints**: Verifikasi semua endpoint berfungsi
3. **Monitor Logs**: Periksa console output untuk debugging
4. **User Testing**: Test fitur dengan data real
5. **Performance**: Optimasi jika diperlukan 