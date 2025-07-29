# Preview UI dengan Ikon - Halaman Rekam Hafalan

## Layout Visual Baru

### Header:
```
┌─────────────────────────────────────┐
│           Rekam Hafalan             │
└─────────────────────────────────────┘
```

### Konten:
```
Santri: [KODE_SANTRI]

Rekam Hafalan:
Merekam: 00:15 (jika sedang merekam)
Memutar rekaman... (jika sedang memutar)
File: hafalan_santri.mp3 (jika file dipilih)

┌─────────────────────────────────────┐
│  [🎙️ Mulai Merekam] [Pilih File]   │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  [▶️ Putar Rekaman] [⬆️ Upload]     │
└─────────────────────────────────────┘
```

## Deskripsi Ikon

### 🎙️ Tombol Mulai/Berhenti Merekam
- **State Normal**: Ikon play hijau + "Mulai Merekam"
- **State Recording**: Ikon stop merah + "Berhenti Merekam"
- **Warna Background**: Hijau (normal) / Merah (recording)
- **Fungsi**: Merekam hafalan langsung di aplikasi

### 📁 Tombol Pilih File
- **Ikon**: Tidak ada ikon khusus (text only)
- **Warna Background**: Teal
- **Fungsi**: Memilih file audio dari perangkat

### ▶️ Tombol Putar Rekaman
- **State Normal**: Ikon play_arrow + "Putar Rekaman"
- **State Playing**: Ikon stop + "Stop"
- **Warna Background**: Biru (normal) / Orange (playing)
- **Fungsi**: Preview rekaman sebelum upload

### ⬆️ Tombol Upload Rekaman
- **Ikon**: Upload arrow
- **Warna Background**: Ungu
- **Fungsi**: Mengirim file ke server

## Keunggulan Visual

### 1. Konsistensi Ikon
- Semua ikon menggunakan ukuran 20x20
- Warna ikon disesuaikan dengan tema tombol
- Spacing yang konsisten antar elemen

### 2. Intuitif
- Ikon play untuk memulai/memutar
- Ikon stop untuk berhenti
- Ikon upload untuk mengunggah
- Mudah dikenali tanpa perlu membaca teks

### 3. State Awareness
- Ikon berubah sesuai dengan state aplikasi
- Visual feedback yang jelas
- User tahu apa yang sedang terjadi

### 4. Modern Design
- Menggunakan SVG icons yang scalable
- Material Design principles
- Clean dan professional look

## Responsivitas

### Desktop/Tablet:
```
[🎙️ Mulai Merekam] [Pilih File] [▶️ Putar] [⬆️ Upload]
```

### Mobile (Portrait):
```
[🎙️ Mulai Merekam] [Pilih File]
[▶️ Putar Rekaman] [⬆️ Upload Rekaman]
```

### Mobile (Landscape):
```
[🎙️ Mulai] [Pilih] [▶️ Putar] [⬆️ Upload]
```

## Color Scheme

### Tombol States:
- **Hijau**: Mulai/Play actions
- **Merah**: Stop actions
- **Biru**: Play/Preview actions
- **Orange**: Stop/Playing state
- **Ungu**: Upload actions
- **Teal**: File selection

### Ikon Colors:
- **Putih**: Semua ikon pada tombol berwarna
- **Konsisten**: Menggunakan `ColorFilter.mode(Colors.white, BlendMode.srcIn)`

## User Experience

### Flow Visual:
1. **Mulai**: User melihat ikon play hijau → "Mulai Merekam"
2. **Recording**: Ikon berubah menjadi stop merah → "Berhenti Merekam"
3. **File Ready**: Muncul nama file dan tombol play/upload
4. **Preview**: Klik play untuk mendengarkan
5. **Upload**: Klik upload untuk kirim ke server

### Accessibility:
- Ikon + text untuk clarity
- Warna yang kontras
- Ukuran touch target yang cukup
- Feedback visual yang jelas

## Technical Implementation

### SVG Assets:
```dart
SvgPicture.asset(
  'assets/icons/Start Record.svg',
  width: 20,
  height: 20,
  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
)
```

### Material Icons:
```dart
Icon(Icons.play_arrow, size: 20)
Icon(Icons.stop, size: 20)
```

### Button Structure:
```dart
ElevatedButton.icon(
  icon: [SVG or Material Icon],
  label: Text('Button Text'),
  style: ElevatedButton.styleFrom(...),
)
``` 