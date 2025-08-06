# Solusi Masalah URL API - Cloudflare Tunnel

## Masalah yang Ditemui

### Error Format Exception
```
Error during login API call: FormatException: Unexpected character (at character 1)
<!doctype html>
^
```

### Analisis Masalah
- Aplikasi mobile mendapatkan response HTML alih-alih JSON
- URL API Cloudflare tunnel telah berubah
- Server Flask mungkin tidak berjalan atau URL tidak sesuai

## Solusi yang Diterapkan

### 1. Update URL API Configuration
Memperbarui file `lib/api_config.dart` dengan URL yang benar:

```dart
class ApiConfig {
  // Gunakan URL yang sesuai dengan server yang sedang berjalan
  static String baseUrl = "https://ja-volumes-gourmet-experience.trycloudflare.com";
  
  // Alternatif URL untuk development
  // static String baseUrl = "http://10.0.2.2:5000"; // Android Emulator
  // static String baseUrl = "http://localhost:5000"; // Local development
  // static String baseUrl = "http://192.168.20.234:5000"; // Local network
  
  // Catatan: URL Cloudflare tunnel dapat berubah setiap kali server di-restart
  // Pastikan URL ini sesuai dengan yang ditampilkan oleh Cloudflare tunnel
}
```

### 2. Verifikasi Server Status
Pastikan server Flask berjalan dengan benar:

```bash
cd monitoring_app
python run.py
```

### 3. Test API Connection
Test koneksi ke API menggunakan curl:

```bash
# Test connection endpoint
curl https://ja-volumes-gourmet-experience.trycloudflare.com/api/test_connection

# Test daftar santri endpoint
curl https://ja-volumes-gourmet-experience.trycloudflare.com/api/daftar_santri
```

## Langkah-langkah Troubleshooting

### 1. Periksa Server Flask
```bash
# Pastikan server berjalan
cd monitoring_app
python run.py

# Periksa output untuk URL Cloudflare tunnel
# Contoh output:
# * Running on https://ja-volumes-gourmet-experience.trycloudflare.com
```

### 2. Update URL di Aplikasi Mobile
Jika URL berubah, update file `lib/api_config.dart`:

```dart
class ApiConfig {
  static String baseUrl = "https://NEW-URL-HERE.trycloudflare.com";
}
```

### 3. Test API Endpoints
```bash
# Test semua endpoint yang diperlukan
curl https://ja-volumes-gourmet-experience.trycloudflare.com/api/test_connection
curl https://ja-volumes-gourmet-experience.trycloudflare.com/api/daftar_santri
curl https://ja-volumes-gourmet-experience.trycloudflare.com/api/santri/SANTRI001/penilaian
```

### 4. Restart Aplikasi Mobile
```bash
cd monitoring_mobile
flutter clean
flutter pub get
flutter run
```

## Prevention Measures

### 1. URL Management
- Selalu periksa URL Cloudflare tunnel saat restart server
- Dokumentasikan perubahan URL
- Gunakan environment variables jika memungkinkan

### 2. Error Handling
- Implementasi retry mechanism untuk API calls
- Tampilkan error message yang informatif
- Log URL yang digunakan untuk debugging

### 3. Development vs Production
- Gunakan URL lokal untuk development
- Gunakan Cloudflare tunnel untuk production/testing
- Dokumentasikan perbedaan environment

## Monitoring dan Verifikasi

### 1. API Health Check
Periksa endpoint `/api/test_connection`:
```json
{
  "status": "success",
  "message": "Backend is running",
  "timestamp": "2025-01-27T10:00:00.000000"
}
```

### 2. Response Format
Pastikan semua endpoint mengembalikan JSON:
```json
// Success response
{
  "message": "Success",
  "data": [...]
}

// Error response
{
  "error": "Error message"
}
```

### 3. Network Connectivity
- Test koneksi internet
- Periksa firewall settings
- Verifikasi DNS resolution

## Troubleshooting Steps

### Jika Mendapat Response HTML
1. Periksa URL API di `api_config.dart`
2. Verifikasi server Flask berjalan
3. Test URL dengan browser atau curl
4. Update URL jika diperlukan

### Jika Server Tidak Berjalan
1. Start server Flask: `python run.py`
2. Periksa error log
3. Verifikasi dependencies terinstall
4. Periksa port availability

### Jika URL Berubah
1. Catat URL baru dari output server
2. Update `api_config.dart`
3. Restart aplikasi mobile
4. Test koneksi API

## Kesimpulan

Masalah URL API telah berhasil diatasi dengan:
1. ✅ Memperbarui URL di `api_config.dart`
2. ✅ Memastikan server Flask berjalan
3. ✅ Testing koneksi API
4. ✅ Dokumentasi troubleshooting

Aplikasi mobile sekarang seharusnya dapat terhubung ke server dengan benar. 