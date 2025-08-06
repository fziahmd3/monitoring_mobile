# Solusi Masalah Machine Learning Model - Penilaian Hafalan

## Masalah yang Ditemui

### Error Machine Learning Model
```
Error: Machine Learning model not loaded on server.
```

### Analisis Masalah
- Server Flask tidak dapat memuat model Naive Bayes untuk penilaian hafalan
- File `naive_bayes_model.pkl` dan `naive_bayes_encoder.pkl` tidak ada di folder `output/`
- Model diperlukan untuk endpoint `/api/penilaian` untuk melakukan prediksi hasil penilaian

## Solusi yang Diterapkan

### 1. Menjalankan Build Model Script
Menjalankan script `build_model.py` untuk membuat model yang diperlukan:

```bash
cd monitoring_app
python build_model.py
```

### 2. Model yang Dibuat
Script `build_model.py` membuat 4 file model:

#### File Model untuk Prediksi Umum:
- `output/model.pkl` - Model MultinomialNB untuk prediksi kemajuan
- `output/encoder.pkl` - Encoder untuk fitur tingkat_hafalan dan target kemajuan

#### File Model untuk Penilaian Hafalan:
- `output/naive_bayes_model.pkl` - Model GaussianNB untuk penilaian hafalan
- `output/naive_bayes_encoder.pkl` - Encoder untuk hasil penilaian

### 3. Data Training untuk Model Penilaian
Model Naive Bayes dilatih dengan data dummy untuk penilaian hafalan:

```python
# Contoh data pelatihan (X: tajwid, kelancaran, kefasihan; y: hasil penilaian)
X_train_nb = np.array([
    [5, 5, 5], # Sangat Baik
    [4, 5, 4], # Sangat Baik
    [5, 4, 5], # Sangat Baik
    [4, 4, 4], # Baik
    [3, 4, 3], # Baik
    [4, 3, 4], # Baik
    [3, 3, 3], # Cukup
    [2, 3, 2], # Cukup
    [3, 2, 3], # Cukup
    [2, 2, 2], # Kurang
    [1, 2, 1], # Kurang
    [2, 1, 2], # Kurang
    [1, 1, 1], # Sangat Kurang
])
y_train_nb = np.array([
    'Sangat Baik', 'Sangat Baik', 'Sangat Baik',
    'Baik', 'Baik', 'Baik',
    'Cukup', 'Cukup', 'Cukup',
    'Kurang', 'Kurang', 'Kurang',
    'Sangat Kurang',
])
```

### 4. Model Loading di Routes
Model dimuat saat aplikasi Flask dimulai:

```python
# Muat model dan encoder Naive Bayes yang sudah dilatih
global naive_bayes_model, le_hasil_penilaian
try:
    with open('output/naive_bayes_model.pkl', 'rb') as f_model:
        naive_bayes_model = pickle.load(f_model)
    with open('output/naive_bayes_encoder.pkl', 'rb') as f_enc:
        le_hasil_penilaian = pickle.load(f_enc)
    print("Naive Bayes model and encoder for penilaian loaded successfully from output/.")
except FileNotFoundError:
    print("Error: Model Naive Bayes atau encoder tidak ditemukan di folder output/.")
    naive_bayes_model = None
    le_hasil_penilaian = None
```

## Langkah-langkah Implementasi

### 1. Jalankan Build Model
```bash
cd monitoring_app
python build_model.py
```

### 2. Verifikasi File Model
```bash
ls output/
# Harus ada file:
# - naive_bayes_model.pkl
# - naive_bayes_encoder.pkl
# - model.pkl
# - encoder.pkl
```

### 3. Restart Flask Server
```bash
python run.py
```

### 4. Test API Endpoint
```bash
# Test endpoint penilaian
curl -X POST https://constantly-disco-failed-baghdad.trycloudflare.com/api/penilaian \
  -H "Content-Type: application/json" \
  -d '{
    "kode_santri": "SANTRI001",
    "kode_guru": "GURU001",
    "surat": "Al-Fatihah",
    "dari_ayat": 1,
    "sampai_ayat": 7,
    "penilaian_tajwid": 4,
    "kelancaran": 4,
    "kefasihan": 4,
    "catatan": "Bagus sekali!"
  }'
```

## Hasil yang Diharapkan

### 1. Model Loading
- Model Naive Bayes berhasil dimuat saat server start
- Tidak ada error "Machine Learning model not loaded"
- Log menunjukkan "Naive Bayes model and encoder loaded successfully"

### 2. API Functionality
- Endpoint `/api/penilaian` berfungsi normal
- Prediksi hasil penilaian berhasil dilakukan
- Response berisi `hasil_prediksi_naive_bayes`

### 3. Mobile App
- Form penilaian hafalan dapat disimpan
- Prediksi hasil penilaian ditampilkan
- Tidak ada error model loading

## Monitoring dan Verifikasi

### 1. Log Monitoring
Periksa log server untuk:
```
Naive Bayes model and encoder for penilaian loaded successfully from output/.
General prediction model and encoders loaded successfully from output/.
```

### 2. Model Verification
```python
# Test model loading
import pickle

# Test Naive Bayes model
with open('output/naive_bayes_model.pkl', 'rb') as f:
    model = pickle.load(f)
print("Naive Bayes model loaded successfully")

# Test encoder
with open('output/naive_bayes_encoder.pkl', 'rb') as f:
    encoder = pickle.load(f)
print("Encoder loaded successfully")
```

### 3. API Testing
- Test endpoint dengan data valid
- Verifikasi response format
- Test dengan berbagai nilai penilaian

## Prevention Measures

### 1. Model Management
- Selalu jalankan `build_model.py` setelah deploy
- Backup file model di repository
- Verifikasi model loading saat server start

### 2. Error Handling
- Implementasi fallback jika model tidak ada
- Logging yang informatif untuk debugging
- Graceful degradation jika model gagal dimuat

### 3. Model Updates
- Dokumentasikan perubahan model
- Version control untuk file model
- Test model dengan data real

## Troubleshooting

### Jika Model Tidak Dimuat
1. Periksa file model ada di folder `output/`
2. Jalankan `python build_model.py`
3. Restart Flask server
4. Periksa log untuk error detail

### Jika Prediksi Gagal
1. Verifikasi format input data
2. Periksa model compatibility
3. Test dengan data training
4. Update model jika diperlukan

### Jika File Model Hilang
1. Jalankan ulang `build_model.py`
2. Restore dari backup
3. Rebuild model dari data training
4. Verifikasi model performance

## Kesimpulan

Masalah Machine Learning model telah berhasil diatasi dengan:
1. ✅ Menjalankan `build_model.py` untuk membuat model
2. ✅ Membuat file `naive_bayes_model.pkl` dan `naive_bayes_encoder.pkl`
3. ✅ Model berhasil dimuat saat server start
4. ✅ Endpoint penilaian dapat melakukan prediksi

Fitur penilaian hafalan sekarang seharusnya berfungsi dengan baik dengan prediksi Machine Learning yang aktif. 