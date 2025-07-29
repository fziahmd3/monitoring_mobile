# Perbaikan Kode Guru Kosong Saat Upload Rekaman

## Masalah
Saat santri melakukan upload rekaman, kode guru yang diterima di backend selalu kosong (`''`). Ini terjadi karena:

1. Di `dashboard_screen.dart`, saat navigasi ke `RekamHafalanScreen`, parameter `kodeGuru` selalu dikirim sebagai string kosong
2. Tidak ada mekanisme untuk santri memilih guru yang akan menerima rekaman

## Solusi
Ditambahkan dialog input kode guru sebelum memulai rekaman:

### 1. Perubahan di `dashboard_screen.dart`
- **Import**: Menambahkan import `rekam_hafalan_screen.dart`
- **Method baru**: `_showRekamHafalanDialog()` untuk menampilkan dialog input kode guru
- **Navigasi**: Mengubah navigasi langsung menjadi dialog terlebih dahulu

### 2. Flow Baru
1. Santri klik tombol "Rekam Hafalan"
2. Dialog muncul meminta input kode guru
3. Santri memasukkan kode guru yang valid
4. Dialog tertutup dan navigasi ke `RekamHafalanScreen` dengan kode guru yang benar
5. Upload rekaman dengan kode guru yang sudah diisi

### 3. Kode yang Diubah

#### Dialog Input Kode Guru
```dart
void _showRekamHafalanDialog() {
  final TextEditingController kodeGuruController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Rekam Hafalan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan kode guru yang akan menerima rekaman:'),
            const SizedBox(height: 10),
            TextField(
              controller: kodeGuruController,
              decoration: const InputDecoration(
                labelText: 'Kode Guru',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final kodeGuru = kodeGuruController.text.trim();
              if (kodeGuru.isNotEmpty) {
                Navigator.of(context).pop();
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => RekamHafalanScreen(
                      kodeSantri: widget.credential, 
                      kodeGuru: kodeGuru
                    )
                  )
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kode guru harus diisi')),
                );
              }
            },
            child: const Text('Mulai Rekam'),
          ),
        ],
      );
    },
  );
}
```

#### Perubahan Navigasi
```dart
// Sebelum
Navigator.push(context, MaterialPageRoute(builder: (context) => 
  RekamHafalanScreen(kodeSantri: widget.credential, kodeGuru: '')));

// Sesudah  
onPressed: () {
  _showRekamHafalanDialog();
},
```

## Hasil
- Kode guru tidak lagi kosong saat upload rekaman
- Santri dapat memilih guru yang akan menerima rekaman
- Backend dapat menyimpan informasi guru dengan benar
- Guru dapat melihat rekaman berdasarkan kode santri yang mengupload

## Testing
1. Login sebagai santri
2. Klik "Rekam Hafalan"
3. Masukkan kode guru yang valid
4. Lakukan rekaman dan upload
5. Login sebagai guru dan cek apakah rekaman muncul dengan kode guru yang benar 