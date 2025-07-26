import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:convert'; // Pastikan ini ada
import '../api_config.dart'; // Pastikan ini ada

class PenilaianHafalanFormScreen extends StatefulWidget {
  final String kodeSantri;
  const PenilaianHafalanFormScreen({super.key, required this.kodeSantri});

  @override
  State<PenilaianHafalanFormScreen> createState() => _PenilaianHafalanFormScreenState();
}

class _PenilaianHafalanFormScreenState extends State<PenilaianHafalanFormScreen> {
  final _suratController = TextEditingController();
  final _dariAyatController = TextEditingController();
  final _sampaiAyatController = TextEditingController();
  final _penilaianTajwidController = TextEditingController(); // Controller baru untuk penilaian tajwid
  final _kelancaranController = TextEditingController(); // Controller baru untuk kelancaran
  final _kefasihanController = TextEditingController(); // Controller baru untuk kefasihan
  String? _selectedSurat;
  // String? _selectedTajwid; // Tidak lagi digunakan
  String? _result;
  String? _errorMessage;

  // Bagian perekaman suara telah dipindahkan ke RekamHafalanScreen
  // String? _recordingPath;
  // bool _isRecording = false;
  // final AudioRecorder _audioRecorder = AudioRecorder();
  // Timer? _timer;
  // int _recordDuration = 0;

  final Map<String, int> _jumlahAyatPerSurat = {
    'Al-Fatihah': 7,
    'An-Nas': 6,
    'Al-Falaq': 5,
    'Al-Ikhlas': 4,
    'Al-Lahab': 5,
    'An-Nasr': 3,
    'Al-Kafirun': 6,
    'Al-Kautsar': 3,
    "Al-Ma'un": 7,
    'Quraisy': 4,
    'Al-Fil': 5,
    'Al-Humazah': 9,
    'Al-Asr': 3,
    'At-Takasur': 8,
    "Al-Qari'ah": 11,
    'Al-Adiyat': 11,
    'Az-Zalzalah': 8,
    'Al-Bayyinah': 8,
    'Al-Qadr': 5,
    'Al-Alaq': 19,
    'At-Tin': 8,
    'Al-Insyirah': 8,
    'Ad-Duha': 11,
    'Al-Lail': 21,
    'Asy-Syams': 15,
    'Al-Balad': 20,
    'Al-Fajr': 30,
    'Al-Ghasyiyah': 26,
    "Al-A'la": 19,
    'At-Tariq': 17,
    'Al-Buruj': 22,
    'Al-Insyiqaq': 25,
    'Al-Mutaffifin': 36,
    'Al-Infitar': 19,
    'At-Takwir': 29,
    'An-Naba': 40,
  };

  @override
  void dispose() {
    _suratController.dispose();
    _dariAyatController.dispose();
    _sampaiAyatController.dispose();
    _penilaianTajwidController.dispose(); // Dispose controller baru
    _kelancaranController.dispose(); // Dispose controller baru
    _kefasihanController.dispose(); // Dispose controller baru
    // _timer?.cancel(); // Sudah dipindahkan
    // _audioRecorder.dispose(); // Sudah dipindahkan
    super.dispose();
  }

  // Metode perekaman suara telah dipindahkan ke RekamHafalanScreen
  // Future<void> _startRecording() async { ... }
  // Future<void> _stopRecording() async { ... }
  // void _startTimer() { ... }
  // String _formatDuration(int seconds) { ... }
  // Future<void> _playRecording(String path) async { ... }

  Future<void> _submitPenilaianForm() async {
    setState(() {
      _result = null;
      _errorMessage = null;
    });

    if (_selectedSurat == null ||
        _dariAyatController.text.isEmpty ||
        _sampaiAyatController.text.isEmpty ||
        _penilaianTajwidController.text.isEmpty || // Cek field baru
        _kelancaranController.text.isEmpty || // Cek field baru
        _kefasihanController.text.isEmpty) { // Cek field baru
      setState(() {
        _errorMessage = 'Mohon lengkapi semua field yang diperlukan.';
      });
      return;
    }

    final apiUrl = '${ApiConfig.baseUrl}/api/penilaian';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'kode_santri': widget.kodeSantri,
          'surat': _selectedSurat,
          'dari_ayat': int.parse(_dariAyatController.text),
          'sampai_ayat': int.parse(_sampaiAyatController.text),
          'penilaian_tajwid': int.parse(_penilaianTajwidController.text), // Kirim sebagai int
          'kelancaran': int.parse(_kelancaranController.text), // Kirim field baru
          'kefasihan': int.parse(_kefasihanController.text), // Kirim field baru
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = '${data['message']} Hasil Penilaian: ${data['hasil_prediksi_naive_bayes']}'; // Tampilkan hasil Naive Bayes
        });
      } else {
        final errorBody = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorBody['error'] ?? 'Gagal menyimpan penilaian.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server. Error: $e';
      });
      print('Error submitting penilaian: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Penilaian Hafalan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Santri: ${widget.kodeSantri}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedSurat,
              hint: const Text('Pilih Surat'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSurat = newValue;
                  _dariAyatController.clear();
                  _sampaiAyatController.clear();
                });
              },
              items: _jumlahAyatPerSurat.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Surat',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _dariAyatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Dari Ayat',
                border: const OutlineInputBorder(),
                hintText: _selectedSurat != null
                    ? '1 - ${_jumlahAyatPerSurat[_selectedSurat]}'
                    : '',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sampaiAyatController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Sampai Ayat',
                border: const OutlineInputBorder(),
                hintText: _selectedSurat != null
                    ? '1 - ${_jumlahAyatPerSurat[_selectedSurat]}'
                    : '',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _penilaianTajwidController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Penilaian Tajwid (1-5)',
                border: const OutlineInputBorder(),
                hintText: 'Masukkan angka 1-5',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _kelancaranController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Kelancaran (1-5)',
                border: const OutlineInputBorder(),
                hintText: 'Masukkan angka 1-5',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _kefasihanController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Kefasihan (1-5)',
                border: const OutlineInputBorder(),
                hintText: 'Masukkan angka 1-5',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPenilaianForm,
              child: const Text('Simpan Penilaian'),
            ),
            if (_result != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Hasil: $_result',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Error: $_errorMessage',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            // Bagian Rekaman Suara
            // const SizedBox(height: 20);
            // Text(
            //   'Rekam Hafalan:',
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // );
            // const SizedBox(height: 10);
            // if (_isRecording)
            //   Text(
            //     'Merekam: ${_formatDuration(_recordDuration)}',
            //     style: TextStyle(fontSize: 16, color: Colors.red),
            //   );
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     ElevatedButton(
            //       onPressed: _isRecording ? _stopRecording : _startRecording,
            //       child: Text(_isRecording ? 'Berhenti Merekam' : 'Mulai Merekam'),
            //     ),
            //     if (!_isRecording && _recordingPath != null)
            //       Padding(
            //         padding: const EdgeInsets.only(left: 10.0),
            //         child: ElevatedButton(
            //           onPressed: () {
            //             _playRecording(_recordingPath!); // Call the play function
            //           },
            //           child: const Text('Putar Rekaman'),
            //         ),
            //       ),
            //     if (!_isRecording && _recordingPath != null)
            //       Padding(
            //         padding: const EdgeInsets.only(left: 10.0),
            //         child: ElevatedButton(
            //           onPressed: () {
            //             // _uploadRecording(_recordingPath!); // Fungsi ini akan diimplementasikan nanti
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               const SnackBar(content: Text('Fitur upload rekaman akan ditambahkan.')),
            //             );
            //           },
            //           child: const Text('Upload Rekaman'),
            //         ),
            //       ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
} 