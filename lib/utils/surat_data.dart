class SuratData {
  final String nama;
  final int nomor;
  final int jumlahAyat;
  final List<int> juz; // Ubah dari int menjadi List<int> untuk surat yang melintasi juz

  SuratData({
    required this.nama,
    required this.nomor,
    required this.jumlahAyat,
    required this.juz,
  });
}

class AyatRange {
  final int dariAyat;
  final int sampaiAyat;
  final String surat;

  AyatRange({
    required this.dariAyat,
    required this.sampaiAyat,
    required this.surat,
  });
}

// Data surat Al-Qur'an dengan juz yang benar
final List<SuratData> daftarSurat = [
  SuratData(nama: "Al-Fatihah", nomor: 1, jumlahAyat: 7, juz: [1]),
  SuratData(nama: "Al-Baqarah", nomor: 2, jumlahAyat: 286, juz: [1, 2, 3]), // Melintasi juz 1-3
  SuratData(nama: "Ali 'Imran", nomor: 3, jumlahAyat: 200, juz: [3, 4]), // Melintasi juz 3-4
  SuratData(nama: "An-Nisa", nomor: 4, jumlahAyat: 176, juz: [4, 5, 6]), // Melintasi juz 4-6
  SuratData(nama: "Al-Ma'idah", nomor: 5, jumlahAyat: 120, juz: [6, 7]), // Melintasi juz 6-7
  SuratData(nama: "Al-An'am", nomor: 6, jumlahAyat: 165, juz: [7, 8]), // Melintasi juz 7-8
  SuratData(nama: "Al-A'raf", nomor: 7, jumlahAyat: 206, juz: [8, 9]), // Melintasi juz 8-9
  SuratData(nama: "Al-Anfal", nomor: 8, jumlahAyat: 75, juz: [9, 10]), // Melintasi juz 9-10
  SuratData(nama: "At-Taubah", nomor: 9, jumlahAyat: 129, juz: [10, 11]), // Melintasi juz 10-11
  SuratData(nama: "Yunus", nomor: 10, jumlahAyat: 109, juz: [11]), // Juz 11
  SuratData(nama: "Hud", nomor: 11, jumlahAyat: 123, juz: [11, 12]), // Melintasi juz 11-12
  SuratData(nama: "Yusuf", nomor: 12, jumlahAyat: 111, juz: [12, 13]), // Melintasi juz 12-13
  SuratData(nama: "Ar-Ra'd", nomor: 13, jumlahAyat: 43, juz: [13]), // Juz 13
  SuratData(nama: "Ibrahim", nomor: 14, jumlahAyat: 52, juz: [13]), // Juz 13
  SuratData(nama: "Al-Hijr", nomor: 15, jumlahAyat: 99, juz: [14]), // Juz 14
  SuratData(nama: "An-Nahl", nomor: 16, jumlahAyat: 128, juz: [14, 15]), // Melintasi juz 14-15
  SuratData(nama: "Al-Isra", nomor: 17, jumlahAyat: 111, juz: [15, 16]), // Melintasi juz 15-16
  SuratData(nama: "Al-Kahf", nomor: 18, jumlahAyat: 110, juz: [15, 16]), // Melintasi juz 15-16
  SuratData(nama: "Maryam", nomor: 19, jumlahAyat: 98, juz: [16]), // Juz 16
  SuratData(nama: "Taha", nomor: 20, jumlahAyat: 135, juz: [16, 17]), // Melintasi juz 16-17
  SuratData(nama: "Al-Anbiya", nomor: 21, jumlahAyat: 112, juz: [17]), // Juz 17
  SuratData(nama: "Al-Hajj", nomor: 22, jumlahAyat: 78, juz: [17]), // Juz 17
  SuratData(nama: "Al-Mu'minun", nomor: 23, jumlahAyat: 118, juz: [18]), // Juz 18
  SuratData(nama: "An-Nur", nomor: 24, jumlahAyat: 64, juz: [18]), // Juz 18
  SuratData(nama: "Al-Furqan", nomor: 25, jumlahAyat: 77, juz: [19]), // Juz 19
  SuratData(nama: "Asy-Syu'ara", nomor: 26, jumlahAyat: 227, juz: [19]), // Juz 19
  SuratData(nama: "An-Naml", nomor: 27, jumlahAyat: 93, juz: [19, 20]), // Melintasi juz 19-20
  SuratData(nama: "Al-Qasas", nomor: 28, jumlahAyat: 88, juz: [20]), // Juz 20
  SuratData(nama: "Al-'Ankabut", nomor: 29, jumlahAyat: 69, juz: [20, 21]), // Melintasi juz 20-21
  SuratData(nama: "Ar-Rum", nomor: 30, jumlahAyat: 60, juz: [21]), // Juz 21
  SuratData(nama: "Luqman", nomor: 31, jumlahAyat: 34, juz: [21]), // Juz 21
  SuratData(nama: "As-Sajdah", nomor: 32, jumlahAyat: 30, juz: [21]), // Juz 21
  SuratData(nama: "Al-Ahzab", nomor: 33, jumlahAyat: 73, juz: [21, 22]), // Melintasi juz 21-22
  SuratData(nama: "Saba", nomor: 34, jumlahAyat: 54, juz: [22]), // Juz 22
  SuratData(nama: "Fatir", nomor: 35, jumlahAyat: 45, juz: [22]), // Juz 22
  SuratData(nama: "Yasin", nomor: 36, jumlahAyat: 83, juz: [22, 23]), // Melintasi juz 22-23
  SuratData(nama: "As-Saffat", nomor: 37, jumlahAyat: 182, juz: [23]), // Juz 23
  SuratData(nama: "Sad", nomor: 38, jumlahAyat: 88, juz: [23]), // Juz 23
  SuratData(nama: "Az-Zumar", nomor: 39, jumlahAyat: 75, juz: [23, 24]), // Melintasi juz 23-24
  SuratData(nama: "Ghafir", nomor: 40, jumlahAyat: 85, juz: [24, 25]), // Melintasi juz 24-25
  SuratData(nama: "Fussilat", nomor: 41, jumlahAyat: 54, juz: [25]), // Juz 25
  SuratData(nama: "Asy-Syura", nomor: 42, jumlahAyat: 53, juz: [25]), // Juz 25
  SuratData(nama: "Az-Zukhruf", nomor: 43, jumlahAyat: 89, juz: [25]), // Juz 25
  SuratData(nama: "Ad-Dukhan", nomor: 44, jumlahAyat: 59, juz: [25]), // Juz 25
  SuratData(nama: "Al-Jatsiyah", nomor: 45, jumlahAyat: 37, juz: [25]), // Juz 25
  SuratData(nama: "Al-Ahqaf", nomor: 46, jumlahAyat: 35, juz: [26]), // Juz 26
  SuratData(nama: "Muhammad", nomor: 47, jumlahAyat: 38, juz: [26]), // Juz 26
  SuratData(nama: "Al-Fath", nomor: 48, jumlahAyat: 29, juz: [26]), // Juz 26
  SuratData(nama: "Al-Hujurat", nomor: 49, jumlahAyat: 18, juz: [26]), // Juz 26
  SuratData(nama: "Qaf", nomor: 50, jumlahAyat: 45, juz: [26]), // Juz 26
  SuratData(nama: "Az-Zariyat", nomor: 51, jumlahAyat: 60, juz: [26, 27]), // Melintasi juz 26-27
  SuratData(nama: "At-Tur", nomor: 52, jumlahAyat: 49, juz: [27]), // Juz 27
  SuratData(nama: "An-Najm", nomor: 53, jumlahAyat: 62, juz: [27]), // Juz 27
  SuratData(nama: "Al-Qamar", nomor: 54, jumlahAyat: 55, juz: [27]), // Juz 27
  SuratData(nama: "Ar-Rahman", nomor: 55, jumlahAyat: 78, juz: [27]), // Juz 27
  SuratData(nama: "Al-Waqi'ah", nomor: 56, jumlahAyat: 96, juz: [27]), // Juz 27
  SuratData(nama: "Al-Hadid", nomor: 57, jumlahAyat: 29, juz: [27]), // Juz 27
  SuratData(nama: "Al-Mujadilah", nomor: 58, jumlahAyat: 22, juz: [28]), // Juz 28
  SuratData(nama: "Al-Hasyr", nomor: 59, jumlahAyat: 24, juz: [28]), // Juz 28
  SuratData(nama: "Al-Mumtahanah", nomor: 60, jumlahAyat: 13, juz: [28]), // Juz 28
  SuratData(nama: "As-Saff", nomor: 61, jumlahAyat: 14, juz: [28]), // Juz 28
  SuratData(nama: "Al-Jumu'ah", nomor: 62, jumlahAyat: 11, juz: [28]), // Juz 28
  SuratData(nama: "Al-Munafiqun", nomor: 63, jumlahAyat: 11, juz: [28]), // Juz 28
  SuratData(nama: "At-Taghabun", nomor: 64, jumlahAyat: 18, juz: [28]), // Juz 28
  SuratData(nama: "At-Talaq", nomor: 65, jumlahAyat: 12, juz: [28]), // Juz 28
  SuratData(nama: "At-Tahrim", nomor: 66, jumlahAyat: 12, juz: [28]), // Juz 28
  SuratData(nama: "Al-Mulk", nomor: 67, jumlahAyat: 30, juz: [29]), // Juz 29
  SuratData(nama: "Al-Qalam", nomor: 68, jumlahAyat: 52, juz: [29]), // Juz 29
  SuratData(nama: "Al-Haqqah", nomor: 69, jumlahAyat: 52, juz: [29]), // Juz 29
  SuratData(nama: "Al-Ma'arij", nomor: 70, jumlahAyat: 44, juz: [29]), // Juz 29
  SuratData(nama: "Nuh", nomor: 71, jumlahAyat: 28, juz: [29]), // Juz 29
  SuratData(nama: "Al-Jinn", nomor: 72, jumlahAyat: 28, juz: [29]), // Juz 29
  SuratData(nama: "Al-Muzzammil", nomor: 73, jumlahAyat: 20, juz: [29]), // Juz 29
  SuratData(nama: "Al-Muddatsir", nomor: 74, jumlahAyat: 56, juz: [29]), // Juz 29
  SuratData(nama: "Al-Qiyamah", nomor: 75, jumlahAyat: 40, juz: [29]), // Juz 29
  SuratData(nama: "Al-Insan", nomor: 76, jumlahAyat: 31, juz: [29]), // Juz 29
  SuratData(nama: "Al-Mursalat", nomor: 77, jumlahAyat: 50, juz: [29]), // Juz 29
  SuratData(nama: "An-Naba", nomor: 78, jumlahAyat: 40, juz: [30]), // Juz 30
  SuratData(nama: "An-Nazi'at", nomor: 79, jumlahAyat: 46, juz: [30]), // Juz 30
  SuratData(nama: "Abasa", nomor: 80, jumlahAyat: 42, juz: [30]), // Juz 30
  SuratData(nama: "At-Takwir", nomor: 81, jumlahAyat: 29, juz: [30]), // Juz 30
  SuratData(nama: "Al-Infitar", nomor: 82, jumlahAyat: 19, juz: [30]), // Juz 30
  SuratData(nama: "Al-Mutaffifin", nomor: 83, jumlahAyat: 36, juz: [30]), // Juz 30
  SuratData(nama: "Al-Insyiqaq", nomor: 84, jumlahAyat: 25, juz: [30]), // Juz 30
  SuratData(nama: "Al-Buruj", nomor: 85, jumlahAyat: 22, juz: [30]), // Juz 30
  SuratData(nama: "At-Tariq", nomor: 86, jumlahAyat: 17, juz: [30]), // Juz 30
  SuratData(nama: "Al-A'la", nomor: 87, jumlahAyat: 19, juz: [30]), // Juz 30
  SuratData(nama: "Al-Gasyiyah", nomor: 88, jumlahAyat: 26, juz: [30]), // Juz 30
  SuratData(nama: "Al-Fajr", nomor: 89, jumlahAyat: 30, juz: [30]), // Juz 30
  SuratData(nama: "Al-Balad", nomor: 90, jumlahAyat: 20, juz: [30]), // Juz 30
  SuratData(nama: "Asy-Syams", nomor: 91, jumlahAyat: 15, juz: [30]), // Juz 30
  SuratData(nama: "Al-Lail", nomor: 92, jumlahAyat: 21, juz: [30]), // Juz 30
  SuratData(nama: "Ad-Duha", nomor: 93, jumlahAyat: 11, juz: [30]), // Juz 30
  SuratData(nama: "Al-Insyirah", nomor: 94, jumlahAyat: 8, juz: [30]), // Juz 30
  SuratData(nama: "At-Tin", nomor: 95, jumlahAyat: 8, juz: [30]), // Juz 30
  SuratData(nama: "Al-'Alaq", nomor: 96, jumlahAyat: 19, juz: [30]), // Juz 30
  SuratData(nama: "Al-Qadr", nomor: 97, jumlahAyat: 5, juz: [30]), // Juz 30
  SuratData(nama: "Al-Bayyinah", nomor: 98, jumlahAyat: 8, juz: [30]), // Juz 30
  SuratData(nama: "Az-Zalzalah", nomor: 99, jumlahAyat: 8, juz: [30]), // Juz 30
  SuratData(nama: "Al-'Adiyat", nomor: 100, jumlahAyat: 11, juz: [30]), // Juz 30
  SuratData(nama: "Al-Qari'ah", nomor: 101, jumlahAyat: 11, juz: [30]), // Juz 30
  SuratData(nama: "At-Takatsur", nomor: 102, jumlahAyat: 8, juz: [30]), // Juz 30
  SuratData(nama: "Al-'Asr", nomor: 103, jumlahAyat: 3, juz: [30]), // Juz 30
  SuratData(nama: "Al-Humazah", nomor: 104, jumlahAyat: 9, juz: [30]), // Juz 30
  SuratData(nama: "Al-Fil", nomor: 105, jumlahAyat: 5, juz: [30]), // Juz 30
  SuratData(nama: "Quraisy", nomor: 106, jumlahAyat: 4, juz: [30]), // Juz 30
  SuratData(nama: "Al-Ma'un", nomor: 107, jumlahAyat: 7, juz: [30]), // Juz 30
  SuratData(nama: "Al-Katsar", nomor: 108, jumlahAyat: 3, juz: [30]), // Juz 30
  SuratData(nama: "Al-Kafirun", nomor: 109, jumlahAyat: 6, juz: [30]), // Juz 30
  SuratData(nama: "An-Nasr", nomor: 110, jumlahAyat: 3, juz: [30]), // Juz 30
  SuratData(nama: "Al-Lahab", nomor: 111, jumlahAyat: 5, juz: [30]), // Juz 30
  SuratData(nama: "Al-Ikhlas", nomor: 112, jumlahAyat: 4, juz: [30]), // Juz 30
  SuratData(nama: "Al-Falaq", nomor: 113, jumlahAyat: 5, juz: [30]), // Juz 30
  SuratData(nama: "An-Nas", nomor: 114, jumlahAyat: 6, juz: [30]), // Juz 30
];