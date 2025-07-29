# Preview UI Fitur Upload Rekaman

## Layout Baru di Halaman Rekam Hafalan

### Sebelum (Layout Lama):
```
Santri: [KODE_SANTRI]

Rekam Hafalan:
Merekam: 00:15 (jika sedang merekam)

[Mulai Merekam] [Putar Rekaman] [Upload Rekaman]
```

### Sesudah (Layout Baru):
```
Santri: [KODE_SANTRI]

Rekam Hafalan:
Merekam: 00:15 (jika sedang merekam)
Memutar rekaman... (jika sedang memutar)
File: hafalan_santri.mp3 (jika file dipilih)

[Mulai Merekam] [Pilih File]
[Putar Rekaman] [Upload Rekaman]
```

## Deskripsi Tombol

### Baris Pertama:
- **Mulai Merekam** (Hijau) → **Berhenti Merekam** (Merah)
  - Untuk merekam hafalan langsung di aplikasi
  - Berubah warna dan teks saat sedang merekam

- **Pilih File** (Teal)
  - Untuk memilih file audio yang sudah ada di perangkat
  - Membuka file picker untuk memilih file audio

### Baris Kedua (muncul jika ada file):
- **Putar Rekaman** (Biru) → **Stop** (Orange)
  - Untuk mendengarkan preview rekaman
  - Berubah warna dan teks saat sedang memutar

- **Upload Rekaman** (Ungu)
  - Untuk mengirim file ke server
  - Hanya aktif jika tidak sedang memutar

## Informasi File

Setelah file dipilih (baik dari rekaman atau pilihan), akan muncul:
```
File: nama_file.mp3
```
- Menampilkan nama file yang dipilih
- Warna abu-abu untuk tidak terlalu mencolok
- Posisi di tengah untuk mudah dibaca

## Keunggulan Layout Baru

1. **Organisasi yang Lebih Baik**: Tombol dikelompokkan berdasarkan fungsi
2. **Informasi yang Jelas**: User tahu file apa yang dipilih
3. **Fleksibilitas**: Bisa merekam langsung atau pilih file yang sudah ada
4. **User Experience**: Layout yang intuitif dan mudah dipahami

## Flow Penggunaan

### Opsi 1: Rekam Langsung
1. Klik "Mulai Merekam"
2. Rekam hafalan
3. Klik "Berhenti Merekam"
4. File siap untuk putar/upload

### Opsi 2: Pilih File
1. Klik "Pilih File"
2. Pilih file audio dari perangkat
3. File langsung siap untuk putar/upload

### Setelah File Tersedia:
1. Klik "Putar Rekaman" untuk preview
2. Klik "Upload Rekaman" untuk kirim ke server

## Responsivitas

Layout ini responsif dan akan menyesuaikan dengan ukuran layar:
- Tombol akan wrap ke baris baru jika layar terlalu kecil
- Spacing yang konsisten untuk tampilan yang rapi
- Padding yang cukup untuk touch target yang nyaman 