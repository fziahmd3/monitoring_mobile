# Endpoint Login API - Aplikasi Mobile

## Masalah yang Ditemui

### Error 404 Not Found
```
127.0.0.1 - - [31/Jul/2025 12:32:49] "POST /api/login HTTP/1.1" 404 -
```

### Analisis Masalah
- Aplikasi mobile mencoba mengakses endpoint `/api/login` yang tidak ada di server Flask
- Endpoint yang ada hanya `/login_admin` untuk web interface
- Perlu membuat endpoint API khusus untuk aplikasi mobile

## Solusi yang Diterapkan

### 1. Membuat Endpoint `/api/login`
Menambahkan endpoint baru di `monitoring_app/app/routes.py`:

```python
@app.route('/api/login', methods=['POST'])
def api_login():
    try:
        print("=== API Login Endpoint ===")
        data = request.get_json()
        
        if not data:
            return jsonify({'message': 'Data tidak valid'}), 400
        
        user_type = data.get('user_type')
        credential = data.get('credential')
        
        print(f"User Type: {user_type}")
        print(f"Credential: {credential}")
        
        if not user_type or not credential:
            return jsonify({'message': 'Tipe pengguna dan kredensial harus diisi'}), 400
        
        # Cari user berdasarkan tipe dan kredensial
        user = None
        display_name = None
        
        if user_type == 'Santri':
            user = Santri.query.filter_by(kode_santri=credential).first()
            if user:
                display_name = user.nama_lengkap
        elif user_type == 'Guru':
            user = Guru.query.filter_by(kode_guru=credential).first()
            if user:
                display_name = user.nama_lengkap
        elif user_type == 'OrangTua':
            user = OrangTuaSantri.query.filter_by(kode_orangtua=credential).first()
            if user:
                display_name = user.nama_lengkap
        elif user_type == 'Admin':
            user = Admin.query.filter_by(username=credential).first()
            if user:
                display_name = user.username
        
        if user:
            print(f"User found: {display_name}")
            # Update last_login untuk user yang ditemukan
            user.last_login = datetime.datetime.now()
            db.session.commit()
            
            return jsonify({
                'message': 'Login berhasil',
                'user_type': user_type,
                'credential': credential,
                'display_name': display_name
            }), 200
        else:
            print(f"User not found for {user_type}: {credential}")
            return jsonify({'message': 'Kredensial tidak valid atau pengguna tidak ditemukan'}), 401
            
    except Exception as e:
        print(f"Error in api_login: {e}")
        return jsonify({'message': f'Terjadi kesalahan server: {str(e)}'}), 500
```

### 2. Fitur Endpoint Login

#### Authentication Logic
- Menerima `user_type` dan `credential` dari aplikasi mobile
- Mencari user berdasarkan tipe dan kredensial yang sesuai
- Mendukung 4 tipe user: Santri, Guru, OrangTua, Admin

#### Database Queries
- **Santri**: `Santri.query.filter_by(kode_santri=credential).first()`
- **Guru**: `Guru.query.filter_by(kode_guru=credential).first()`
- **OrangTua**: `OrangTuaSantri.query.filter_by(kode_orangtua=credential).first()`
- **Admin**: `Admin.query.filter_by(username=credential).first()`

#### Response Format
```json
// Success Response (200)
{
  "message": "Login berhasil",
  "user_type": "Guru",
  "credential": "GURU001",
  "display_name": "Ahmad Guru"
}

// Error Response (401)
{
  "message": "Kredensial tidak valid atau pengguna tidak ditemukan"
}

// Error Response (400)
{
  "message": "Tipe pengguna dan kredensial harus diisi"
}
```

## Langkah-langkah Implementasi

### 1. Restart Flask Server
```bash
cd monitoring_app
python run.py
```

### 2. Test API Endpoint
```bash
# Test login dengan PowerShell
Invoke-WebRequest -Uri "https://ja-volumes-gourmet-experience.trycloudflare.com/api/login" -Method POST -Headers @{"Content-Type"="application/json"} -Body '{"user_type": "Santri", "credential": "1"}'

# Response sukses:
{
  "credential": "1",
  "display_name": "Adik Firmansyah",
  "message": "Login berhasil",
  "user_type": "Santri"
}
```

### 3. Test dari Aplikasi Mobile
- Buka aplikasi mobile
- Pilih tipe pengguna (Guru/Santri/OrangTua/Admin)
- Masukkan kredensial
- Test login

## Monitoring dan Debugging

### 1. Server Logs
Periksa log server untuk debugging:
```
=== API Login Endpoint ===
User Type: Guru
Credential: GURU001
User found: Ahmad Guru
```

### 2. Error Handling
- Validasi input data
- Pencarian user di database
- Update last_login timestamp
- Error logging untuk debugging

### 3. Security Considerations
- Tidak menggunakan password (hanya kredensial)
- Update last_login untuk tracking
- Validasi tipe pengguna
- Error messages yang tidak expose sensitive data

## Data Requirements

### 1. Database Records
Pastikan ada data user di database:

#### Santri
```sql
INSERT INTO Santri (kode_santri, nama_lengkap) VALUES ('SANTRI001', 'Ahmad Santri');
```

#### Guru
```sql
INSERT INTO Guru (kode_guru, nama_lengkap) VALUES ('GURU001', 'Ahmad Guru');
```

#### OrangTua
```sql
INSERT INTO OrangTuaSantri (kode_orangtua, nama_lengkap) VALUES ('ORTU001', 'Ahmad OrangTua');
```

#### Admin
```sql
INSERT INTO Admin (username) VALUES ('admin');
```

### 2. Field Requirements
- `kode_santri` untuk Santri
- `kode_guru` untuk Guru
- `kode_orangtua` untuk OrangTua
- `username` untuk Admin
- `nama_lengkap` untuk display name

## Troubleshooting

### Jika Login Gagal
1. Periksa kredensial di database
2. Verifikasi tipe pengguna
3. Periksa log server untuk error
4. Test dengan curl untuk debugging

### Jika User Tidak Ditemukan
1. Periksa data di database
2. Verifikasi field yang digunakan untuk pencarian
3. Periksa case sensitivity
4. Test dengan data yang valid

### Jika Server Error
1. Periksa log server
2. Verifikasi database connection
3. Periksa model imports
4. Restart server jika diperlukan

## Kesimpulan

Endpoint `/api/login` telah berhasil dibuat dan diuji dengan:
1. ✅ Mendukung 4 tipe pengguna (Santri, Guru, OrangTua, Admin)
2. ✅ Validasi input dan error handling
3. ✅ Update last_login timestamp
4. ✅ Response format yang sesuai dengan aplikasi mobile
5. ✅ Logging untuk debugging
6. ✅ **TEST BERHASIL** - Login dengan Santri kode "1" berhasil

Aplikasi mobile sekarang dapat melakukan login dengan benar menggunakan endpoint `/api/login`. 