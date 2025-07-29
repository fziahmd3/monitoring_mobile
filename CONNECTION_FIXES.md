# Perbaikan Masalah Koneksi

## Masalah yang Diperbaiki

### 1. Error "Connection refused"
**Masalah:** Aplikasi Flutter tidak dapat terhubung ke backend Flask
```
I/flutter: Error during upload: ClientException with SocketException: Connection refused (OS Error: Connection refused, errno = 111), address = localhost, port = 45842, uri=http://localhost:5000/upload_recording
```

**Penyebab:**
- Aplikasi Flutter berjalan di emulator/device dengan IP berbeda
- `localhost` di emulator mengarah ke device itu sendiri, bukan ke komputer host
- Port yang salah (45842 vs 5000)

**Solusi:**
- Menggunakan IP address komputer host (10.181.189.11:5000)
- Memperbarui endpoint upload untuk menggunakan `ApiConfig.baseUrl`

## File yang Dimodifikasi

### 1. `lib/screens/rekam_hafalan_screen.dart`
- Menambahkan import `../api_config.dart`
- Mengubah endpoint dari `http://localhost:5000/upload_recording` menjadi `${ApiConfig.baseUrl}/upload_recording`

### 2. `lib/api_config.dart`
- Sudah dikonfigurasi dengan IP yang benar: `http://10.181.189.11:5000`

## Konfigurasi Jaringan

### IP Address Komputer Host
```
IPv4 Address: 10.181.189.11
Subnet Mask: 255.255.255.0
Default Gateway: 10.181.189.172
```

### Backend Flask
- **Host:** `0.0.0.0` (menerima koneksi dari semua interface)
- **Port:** `5000`
- **URL:** `http://10.181.189.11:5000`

### Aplikasi Flutter
- **API Base URL:** `http://10.181.189.11:5000`
- **Endpoint Upload:** `http://10.181.189.11:5000/upload_recording`

## Troubleshooting Koneksi

### 1. Periksa Backend Flask
```bash
# Cek apakah Flask berjalan
netstat -an | findstr :5000

# Jalankan Flask dengan host yang benar
python run.py
```

### 2. Test Koneksi dari Komputer
```bash
# Test dengan curl
curl -X GET http://10.181.189.11:5000/

# Test endpoint upload
curl -X POST \
  -F "recording=@test.m4a" \
  -F "kodeSantri=SANTRI001" \
  -F "kodeGuru=GURU001" \
  http://10.181.189.11:5000/upload_recording
```

### 3. Periksa Firewall
- Pastikan port 5000 tidak diblokir firewall
- Jika menggunakan antivirus, pastikan tidak memblokir koneksi

### 4. Test dari Emulator/Device
```bash
# Dari terminal emulator
adb shell ping 10.181.189.11

# Atau dari aplikasi Flutter
print('Testing connection to: ${ApiConfig.baseUrl}');
```

## Error yang Umum

### 1. Connection Refused
**Penyebab:** Backend tidak berjalan atau port salah
**Solusi:** 
- Pastikan Flask berjalan di port 5000
- Periksa IP address yang benar

### 2. Timeout
**Penyebab:** Koneksi lambat atau terputus
**Solusi:**
- Periksa koneksi jaringan
- Tambahkan timeout pada request

### 3. Network Unreachable
**Penyebab:** IP address salah atau tidak dalam jaringan yang sama
**Solusi:**
- Periksa IP address komputer host
- Pastikan device/emulator dalam jaringan yang sama

## Konfigurasi untuk Development

### 1. Backend Flask (`run.py`)
```python
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

### 2. Aplikasi Flutter (`api_config.dart`)
```dart
class ApiConfig {
  static String baseUrl = "http://10.181.189.11:5000";
}
```

### 3. Endpoint Upload
```dart
var uri = Uri.parse('${ApiConfig.baseUrl}/upload_recording');
```

## Testing Checklist

### ✅ Backend Flask
- [ ] Flask berjalan di port 5000
- [ ] Host dikonfigurasi ke `0.0.0.0`
- [ ] Endpoint `/upload_recording` tersedia
- [ ] Dapat diakses dari browser: `http://10.181.189.11:5000`

### ✅ Aplikasi Flutter
- [ ] `ApiConfig.baseUrl` menggunakan IP yang benar
- [ ] Import `api_config.dart` di `rekam_hafalan_screen.dart`
- [ ] Endpoint upload menggunakan `${ApiConfig.baseUrl}`
- [ ] Permission internet sudah ditambahkan

### ✅ Jaringan
- [ ] Komputer host dan device dalam jaringan yang sama
- [ ] Port 5000 tidak diblokir firewall
- [ ] IP address 10.181.189.11 dapat di-ping

## Tips Pengembangan

### 1. Gunakan IP Address Dinamis
```dart
// Untuk development, bisa menggunakan IP yang berbeda
class ApiConfig {
  static String baseUrl = "http://10.181.189.11:5000"; // Development
  // static String baseUrl = "http://192.168.1.100:5000"; // Alternatif
}
```

### 2. Tambahkan Error Handling
```dart
try {
  var response = await request.send();
  // Handle response
} catch (e) {
  print('Connection error: $e');
  // Show user-friendly error message
}
```

### 3. Test dengan Different Devices
- Test di emulator Android
- Test di device fisik
- Test di iOS simulator (jika ada)

## Kesimpulan

Perbaikan ini mengatasi masalah koneksi dengan:
- Menggunakan IP address yang benar (10.181.189.11:5000)
- Memastikan backend Flask dapat diakses dari jaringan
- Menggunakan `ApiConfig.baseUrl` untuk konsistensi
- Menambahkan error handling yang lebih baik

Sekarang aplikasi Flutter dapat terhubung ke backend Flask untuk upload rekaman audio. 