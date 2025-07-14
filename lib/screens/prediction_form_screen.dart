import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionFormScreen extends StatefulWidget {
  const PredictionFormScreen({super.key});

  @override
  State<PredictionFormScreen> createState() => _PredictionFormScreenState();
}

class _PredictionFormScreenState extends State<PredictionFormScreen> {
  final TextEditingController _jumlahSetoranController = TextEditingController();
  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _kehadiranController = TextEditingController();
  String? _selectedTingkatHafalan;
  String? _predictionResult;
  String? _errorMessage;

  final List<String> _tingkatHafalanOptions = ['rendah', 'sedang', 'tinggi'];

  @override
  void dispose() {
    _jumlahSetoranController.dispose();
    _nisController.dispose();
    _kehadiranController.dispose();
    super.dispose();
  }

  Future<void> _submitPredictionForm() async {
    setState(() {
      _errorMessage = null;
      _predictionResult = null;
    });

    if (_selectedTingkatHafalan == null ||
        _jumlahSetoranController.text.isEmpty ||
        _nisController.text.isEmpty ||
        _kehadiranController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Harap lengkapi semua bidang.';
      });
      return;
    }

    // final apiUrl = 'http://10.95.121.11:5000/api/predict'; // Ubah ke /api/predict
    final apiUrl = 'http://192.18.20.236:5000/api/predict';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'tingkat_hafalan': _selectedTingkatHafalan,
          'jumlah_setoran': int.parse(_jumlahSetoranController.text),
          'kehadiran': int.parse(_kehadiranController.text),
          'nis': _nisController.text, // Pastikan NIS dikirim
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _predictionResult = 'Prediksi: ${responseBody['hasil_hafalan']}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prediksi berhasil disimpan!')), // Tambahkan pesan konfirmasi
        );
      } else {
        final errorBody = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorBody['error'] ?? 'Terjadi kesalahan saat memprediksi.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server. Pastikan server Flask berjalan dan koneksi internet Anda aktif. Error: $e';
      });
      print('Error during prediction API call: $e');
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
            'Form Prediksi Kemajuan Hafalan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tingkat Hafalan',
              border: OutlineInputBorder(),
            ),
            value: _selectedTingkatHafalan,
            hint: const Text('Pilih tingkat hafalan'),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTingkatHafalan = newValue;
              });
            },
            items: _tingkatHafalanOptions
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _jumlahSetoranController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah Setoran (per pekan)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _nisController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              labelText: 'NIS Santri',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _kehadiranController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Persentase Kehadiran (%)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitPredictionForm,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: const Color.fromARGB(255, 26, 144, 11), // Warna tombol
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Prediksi',
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
          if (_predictionResult != null)
            Text(
              _predictionResult!,
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