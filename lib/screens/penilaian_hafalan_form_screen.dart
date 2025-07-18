import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PenilaianHafalanFormScreen extends StatefulWidget {
  final String nis;
  const PenilaianHafalanFormScreen({super.key, required this.nis});

  @override
  State<PenilaianHafalanFormScreen> createState() => _PenilaianHafalanFormScreenState();
}

class _PenilaianHafalanFormScreenState extends State<PenilaianHafalanFormScreen> {
  final TextEditingController _dariAyatController = TextEditingController();
  final TextEditingController _sampaiAyatController = TextEditingController();
  String? _selectedSurat;
  String? _selectedTajwid;
  String? _result;
  String? _errorMessage;

  final Map<String, int> _jumlahAyatPerSurat = {
    'Al-Fatihah': 7,
    'Al-Baqarah': 286,
    'Ali Imran': 200,
    'An-Nisa': 176,
    'Al-Maidah': 120,
    'Al-Anam': 165,
    'Al-Araf': 206,
    'Al-Anfal': 75,
    'At-Taubah': 129,
    'Yunus': 109,
    'Hud': 123,
    'Yusuf': 111,
    'Ar-Ra’d': 43,
    'Ibrahim': 52,
    'Al-Hijr': 99,
    'An-Nahl': 128,
    'Al-Isra’': 111,
    'Al-Kahfi': 110,
    'Maryam': 98,
    'Ta-Ha': 135,
    'Al-Anbiya’': 112,
    'Al-Hajj': 78,
    'Al-Mu’minun': 118,
    'An-Nur': 64,
    'Al-Furqan': 77,
    'Ash-Shu’ara’': 227,
    'An-Naml': 93,
    'Al-Qasas': 88,
    'Al-Ankabut': 69,
    'Ar-Rum': 60,
    'Luqman': 34,
    'As-Sajda': 30,
    'Al-Ahzab': 73,
    'Saba’': 54,
    'Fatir': 45,
    'Ya-Sin': 83,
    'As-Saffat': 182,
    'Sad': 88,
    'Az-Zumar': 75,
    'Ghafir': 85,
    'Fussilat': 54,
    'Ash-Shura': 53,
    'Az-Zukhruf': 89,
    'Ad-Dukhan': 59,
    'Al-Jathiyah': 37,
    'Al-Ahqaf': 35,
    'Muhammad': 38,
    'Al-Fath': 29,
    'Al-Hujurat': 18,
    'Qaf': 45,
    'Adh-Dhariyat': 60,
    'At-Tur': 49,
    'An-Najm': 62,
    'Al-Qamar': 55,
    'Ar-Rahman': 78,
    'Al-Waqi’ah': 96,
    'Al-Hadid': 29,
    'Al-Mujadila': 22,
    'Al-Hashr': 24,
    'Al-Mumtahanah': 13,
    'As-Saff': 14,
    'Al-Jumu’ah': 11,
    'Al-Munafiqun': 11,
    'At-Taghabun': 18,
    'At-Talaq': 12,
    'At-Tahrim': 12,
    'Al-Mulk': 30,
    'Al-Qalam': 52,
    'Al-Haqqah': 52,
    'Al-Ma’arij': 44,
    'Nuh': 28,
    'Al-Jinn': 28,
    'Al-Muzzammil': 20,
    'Al-Muddathir': 56,
    'Al-Qiyamah': 40,
    'Al-Insan': 31,
    'Al-Mursalat': 50,
    'An-Naba’': 40,
    'An-Nazi’at': 46,
    'Abasa': 42,
    'At-Takwir': 29,
    'Al-Infitar': 19,
    'Al-Mutaffifin': 36,
    'Al-Inshiqaq': 25,
    'Al-Buruj': 22,
    'At-Tariq': 17,
    'Al-A’la': 19,
    'Al-Ghashiyah': 26,
    'Al-Fajr': 30,
    'Al-Balad': 20,
    'Ash-Shams': 15,
    'Al-Lail': 21,
    'Ad-Duha': 11,
    'Ash-Sharh': 8,
    'At-Tin': 8,
    'Al-‘Alaq': 19,
    'Al-Qadr': 5,
    'Al-Bayyinah': 8,
    'Az-Zalzalah': 8,
    'Al-‘Adiyat': 11,
    'Al-Qari’ah': 11,
    'At-Takathur': 8,
    'Al-Asr': 3,
    'Al-Humazah': 9,
    'Al-Fil': 5,
    'Quraysh': 4,
    'Al-Ma’un': 7,
    'Al-Kawthar': 3,
    'Al-Kafirun': 6,
    'An-Nasr': 3,
    'Al-Masad': 5,
    'Al-Ikhlas': 4,
    'Al-Falaq': 5,
    'An-Nas': 6,
  };

  final List<String> _daftarSurat = [
    'Al-Fatihah', 'Al-Baqarah', 'Ali Imran', 'An-Nisa', 'Al-Maidah',
    'Al-Anam', 'Al-Araf', 'Al-Anfal', 'At-Taubah', 'Yunus',
    'Hud', 'Yusuf', 'Ar-Ra’d', 'Ibrahim', 'Al-Hijr', 'An-Nahl', 'Al-Isra’', 'Al-Kahfi', 'Maryam', 'Ta-Ha',
    'Al-Anbiya’', 'Al-Hajj', 'Al-Mu’minun', 'An-Nur', 'Al-Furqan', 'Ash-Shu’ara’', 'An-Naml', 'Al-Qasas', 'Al-Ankabut', 'Ar-Rum',
    'Luqman', 'As-Sajda', 'Al-Ahzab', 'Saba’', 'Fatir', 'Ya-Sin', 'As-Saffat', 'Sad', 'Az-Zumar', 'Ghafir',
    'Fussilat', 'Ash-Shura', 'Az-Zukhruf', 'Ad-Dukhan', 'Al-Jathiyah', 'Al-Ahqaf', 'Muhammad', 'Al-Fath', 'Al-Hujurat', 'Qaf',
    'Adh-Dhariyat', 'At-Tur', 'An-Najm', 'Al-Qamar', 'Ar-Rahman', 'Al-Waqi’ah', 'Al-Hadid', 'Al-Mujadila', 'Al-Hashr', 'Al-Mumtahanah',
    'As-Saff', 'Al-Jumu’ah', 'Al-Munafiqun', 'At-Taghabun', 'At-Talaq', 'At-Tahrim', 'Al-Mulk', 'Al-Qalam', 'Al-Haqqah', 'Al-Ma’arij',
    'Nuh', 'Al-Jinn', 'Al-Muzzammil', 'Al-Muddathir', 'Al-Qiyamah', 'Al-Insan', 'Al-Mursalat', 'An-Naba’', 'An-Nazi’at', 'Abasa',
    'At-Takwir', 'Al-Infitar', 'Al-Mutaffifin', 'Al-Inshiqaq', 'Al-Buruj', 'At-Tariq', 'Al-A’la', 'Al-Ghashiyah', 'Al-Fajr', 'Al-Balad',
    'Ash-Shams', 'Al-Lail', 'Ad-Duha', 'Ash-Sharh', 'At-Tin', 'Al-‘Alaq', 'Al-Qadr', 'Al-Bayyinah', 'Az-Zalzalah', 'Al-‘Adiyat',
    'Al-Qari’ah', 'At-Takathur', 'Al-Asr', 'Al-Humazah', 'Al-Fil', 'Quraysh', 'Al-Ma’un', 'Al-Kawthar', 'Al-Kafirun', 'An-Nasr',
    'Al-Masad', 'Al-Ikhlas', 'Al-Falaq', 'An-Nas',
  ];

  final List<String> _penilaianTajwid = [
    'Kurang', 'Cukup', 'Baik', 'Sangat Baik'
  ];

  int? _maxAyat;

  void _onSuratChanged(String? newValue) {
    setState(() {
      _selectedSurat = newValue;
      _maxAyat = newValue != null ? _jumlahAyatPerSurat[newValue] : null;
      _dariAyatController.clear();
      _sampaiAyatController.clear();
    });
  }

  String? _validateAyat(String? value, {bool isDari = false}) {
    if (value == null || value.isEmpty) return 'Wajib diisi';
    final int? ayat = int.tryParse(value);
    if (ayat == null || ayat < 1) return 'Harus angka >= 1';
    if (_maxAyat != null && ayat > _maxAyat!) return 'Maksimal ayat: $_maxAyat';
    if (!isDari && _dariAyatController.text.isNotEmpty) {
      final int? dari = int.tryParse(_dariAyatController.text);
      if (dari != null && ayat < dari) return 'Tidak boleh kurang dari ayat awal';
    }
    if (isDari && _sampaiAyatController.text.isNotEmpty) {
      final int? sampai = int.tryParse(_sampaiAyatController.text);
      if (sampai != null && ayat > sampai) return 'Tidak boleh lebih dari ayat akhir';
    }
    return null;
  }

  @override
  void dispose() {
    _dariAyatController.dispose();
    _sampaiAyatController.dispose();
    super.dispose();
  }

  Future<void> _submitPenilaianForm() async {
    setState(() {
      _errorMessage = null;
      _result = null;
    });

    if (_selectedSurat == null ||
        _dariAyatController.text.isEmpty ||
        _sampaiAyatController.text.isEmpty ||
        _selectedTajwid == null) {
      setState(() {
        _errorMessage = 'Harap lengkapi semua bidang.';
      });
      return;
    }

    final apiUrl = 'http://10.123.201.11:5000/api/penilaian';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'nis': widget.nis,
          'surat': _selectedSurat,
          'dari_ayat': int.parse(_dariAyatController.text),
          'sampai_ayat': int.parse(_sampaiAyatController.text),
          'penilaian_tajwid': _selectedTajwid,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _result = 'Penilaian berhasil disimpan!';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Penilaian berhasil disimpan!')),
        );
      } else {
        final errorBody = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorBody['error'] ?? 'Terjadi kesalahan saat menyimpan penilaian.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server. Pastikan server Flask berjalan dan koneksi internet Anda aktif. Error: $e';
      });
      print('Error during penilaian API call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Form Penilaian Hafalan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Surat yang Dihafalkan',
              border: OutlineInputBorder(),
            ),
            value: _selectedSurat,
            hint: const Text('Pilih surat'),
            onChanged: _onSuratChanged,
            items: _daftarSurat
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _dariAyatController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Dari Ayat',
              border: const OutlineInputBorder(),
              suffix: _maxAyat != null ? Text('/$_maxAyat') : null,
            ),
            validator: (v) => _validateAyat(v, isDari: true),
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _sampaiAyatController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Sampai Ayat',
              border: const OutlineInputBorder(),
              suffix: _maxAyat != null ? Text('/$_maxAyat') : null,
            ),
            validator: (v) => _validateAyat(v),
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Penilaian Tajwid',
              border: OutlineInputBorder(),
            ),
            value: _selectedTajwid,
            hint: const Text('Pilih penilaian tajwid'),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTajwid = newValue;
              });
            },
            items: _penilaianTajwid
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitPenilaianForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: const Color.fromARGB(255, 26, 144, 11),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Simpan Penilaian',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 20),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          if (_result != null)
            Text(
              _result!,
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
} 