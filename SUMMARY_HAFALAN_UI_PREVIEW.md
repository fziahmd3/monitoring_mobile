# Preview UI Fitur Summary Hafalan

## Deskripsi
Dokumentasi ini menjelaskan tampilan UI untuk fitur Summary Hafalan dan Log Harian yang telah dibuat.

## Halaman Progress Hafalan (Guru)

### Sebelum Memilih Santri
```
┌─────────────────────────────────────┐
│           Progress Hafalan          │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │      📊 Icon + Text        │   │
│  │   Lihat Progress Hafalan    │   │
│  │      Santri                 │   │
│  │                             │   │
│  │  Pilih santri untuk melihat │   │
│  │  kemajuan hafalan mereka    │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  📋 Pilih Santri ▼         │   │
│  │  [Dropdown dengan daftar    │   │
│  │   santri]                   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  🔄 Test Connection        │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Setelah Memilih Santri
```
┌─────────────────────────────────────┐
│           Progress Hafalan          │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │      📊 Icon + Text        │   │
│  │   Lihat Progress Hafalan    │   │
│  │      Santri                 │   │
│  │                             │   │
│  │  Pilih santri untuk melihat │   │
│  │  kemajuan hafalan mereka    │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  📋 Pilih Santri ▼         │   │
│  │  [Santri yang dipilih]     │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────┬───────────────┐   │
│  │ 📊 Lihat    │ 🔄 Pilih      │   │
│  │ Summary     │ Santri Lain   │   │
│  └─────────────┴───────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  🔄 Test Connection        │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## Halaman Summary Hafalan

### Header Santri
```
┌─────────────────────────────────────┐
│        Summary [Nama Santri]       │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │        🟢 Background       │   │
│  │                             │   │
│  │           👤 [A]           │   │
│  │                             │   │
│  │        [Nama Santri]       │   │
│  │      Kode: [KODE_SANTRI]   │   │
│  │                             │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Card Summary
```
┌─────────────────────────────────────┐
│  📊 Summary Hafalan                │
├─────────────────────────────────────┤
│  ┌─────────────┬───────────────┐   │
│  │    📚       │    📄         │   │
│  │ Total Surat │ Total Ayat    │   │
│  │     5       │     150       │   │
│  └─────────────┴───────────────┘   │
│                                     │
│  ┌─────────────┬───────────────┐   │
│  │    ⭐       │    📅         │   │
│  │ Rata-rata   │ Sesi Hari    │   │
│  │ Tajwid      │ Ini          │   │
│  │    3.2      │     2        │   │
│  └─────────────┴───────────────┘   │
└─────────────────────────────────────┘
```

### Card Log Harian
```
┌─────────────────────────────────────┐
│  📋 Log Harian                     │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │  📊 Hafalan Al-Fatihah     │   │
│  │     (Ayat 1-7)             │   │
│  │                             │   │
│  │  Tanggal: 2024-01-15       │   │
│  │  Catatan: Tajwid sudah      │   │
│  │  baik, perlu perbaikan      │   │
│  │  pada makhraj              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  📊 Hafalan Al-Baqarah     │   │
│  │     (Ayat 1-5)             │   │
│  │                             │   │
│  │  Tanggal: 2024-01-14       │   │
│  │  Catatan: Lancar dan baik  │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Card Penilaian Terbaru
```
┌─────────────────────────────────────┐
│  📈 Penilaian Terbaru              │
├─────────────────────────────────────┤
│  ┌─────────────────────────────┐   │
│  │  ✅ Al-Fatihah (Ayat 1-7)  │   │
│  │                             │   │
│  │  Tanggal: 2024-01-15       │   │
│  │  Hasil: Baik               │   │
│  │  Catatan: Tajwid sudah      │   │
│  │  baik, perlu perbaikan      │   │
│  │  pada makhraj              │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  ⚠️ Al-Baqarah (Ayat 1-5)  │   │
│  │                             │   │
│  │  Tanggal: 2024-01-14       │   │
│  │  Hasil: Cukup              │   │
│  │  Catatan: Perlu latihan    │   │
│  │  lebih lanjut              │   │
│  └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

## Warna dan Tema

### Primary Colors
- **Hijau**: `Color.fromARGB(255, 26, 144, 11)` - Header dan accent
- **Putih**: Background utama
- **Abu-abu**: `Colors.grey[50]` - Background card

### Status Colors
- **Baik**: `Colors.green` - Hasil penilaian baik
- **Cukup**: `Colors.orange` - Hasil penilaian cukup  
- **Kurang**: `Colors.red` - Hasil penilaian kurang
- **Info**: `Colors.blue` - Log harian
- **Warning**: `Colors.orange[700]` - Catatan

### Icon Colors
- **Summary**: `Colors.green` - Analytics icon
- **Log**: `Colors.blue` - History icon
- **Penilaian**: `Colors.purple` - Assessment icon

## Responsive Design

### Mobile Portrait (320px - 480px)
- Single column layout
- Full width cards
- Compact spacing
- Smaller font sizes

### Mobile Landscape (481px - 768px)
- Maintain single column
- Slightly larger cards
- Better spacing
- Medium font sizes

### Tablet (769px - 1024px)
- Two column layout for summary items
- Larger cards
- More generous spacing
- Larger font sizes

## Loading States

### Initial Loading
```
┌─────────────────────────────────────┐
│        Summary [Nama Santri]       │
├─────────────────────────────────────┤
│                                     │
│           ⭕ Loading...            │
│                                     │
└─────────────────────────────────────┘
```

### Error State
```
┌─────────────────────────────────────┐
│        Summary [Nama Santri]       │
├─────────────────────────────────────┤
│                                     │
│           ❌ Error Icon            │
│                                     │
│      Tidak dapat memuat data       │
│                                     │
│        [🔄 Coba Lagi]             │
│                                     │
└─────────────────────────────────────┘
```

### Empty State
```
┌─────────────────────────────────────┐
│  📊 Summary Hafalan                │
├─────────────────────────────────────┤
│                                     │
│        Belum ada data summary      │
│                                     │
└─────────────────────────────────────┘
```

## Navigation Flow

### Flow 1: Guru → Progress Hafalan → Summary
1. Guru login dengan akun guru
2. Masuk ke tab "Progress Hafalan"
3. Pilih santri dari dropdown
4. Klik tombol "Lihat Summary"
5. Masuk ke halaman Summary Hafalan
6. Lihat data summary, log harian, dan penilaian terbaru
7. Klik back untuk kembali ke progress hafalan

### Flow 2: Refresh Data
1. Di halaman Summary Hafalan
2. Pull down untuk refresh
3. Data diperbarui secara otomatis
4. Loading indicator muncul
5. Data baru ditampilkan

## Accessibility Features

### Screen Reader Support
- Semantic labels untuk semua elemen
- Proper heading hierarchy
- Alt text untuk icons
- Descriptive button labels

### Color Contrast
- Minimum 4.5:1 contrast ratio
- High contrast mode support
- Color blind friendly palette

### Touch Targets
- Minimum 44x44dp touch targets
- Adequate spacing between elements
- No overlapping interactive elements

## Performance Considerations

### Image Optimization
- Lazy loading untuk foto profil
- Compressed images
- Caching strategy

### API Optimization
- Parallel API calls
- Request caching
- Error retry mechanism

### UI Performance
- Efficient widget rebuilds
- Optimized list rendering
- Memory management 