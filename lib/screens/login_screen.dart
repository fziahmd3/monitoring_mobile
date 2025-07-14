import 'package:flutter/material.dart';
import 'package:monitoring_hafalan_app/screens/dashboard_screen.dart'; // Import dashboard
import 'package:http/http.dart' as http; // Import http package
import 'dart:convert'; // Import for JSON encoding/decoding

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk input teks
  final TextEditingController _credentialController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Controller untuk password
  String? _selectedUserType; // Untuk menyimpan tipe pengguna yang dipilih
  String? _errorMessage; // Untuk menampilkan pesan error

  // Daftar tipe pengguna
  final List<String> _userTypes = [
    // 'Admin', // Aktifkan kembali Admin
    'Guru',
    'Santri',
    'Orang Tua Santri',
  ];

  // Helper untuk mendapatkan label input berdasarkan tipe pengguna
  String _getInputLabel() {
    switch (_selectedUserType) {
      // case 'Admin':
      //   return 'Username'; // Label untuk Admin adalah Username
      case 'Guru':
        return 'NIP';
      case 'Santri':
        return 'NISN';
      case 'Orang Tua Santri':
        return 'Nama Santri';
      default:
        return 'Kredensial';
    }
  }

  // Logika login
  Future<void> _login() async { // Ubah menjadi Future<void> dan async
    setState(() {
      _errorMessage = null; // Reset error message
    });

    if (_selectedUserType == null ||
        _credentialController.text.isEmpty ||
        (_selectedUserType == 'Admin' && _passwordController.text.isEmpty)) { // Hanya periksa password jika Admin
      setState(() {
        _errorMessage = 'Mohon pilih tipe pengguna, isi kredensial,';
        if (_selectedUserType == 'Admin') {
          _errorMessage = '$_errorMessage dan kata sandi.';
        } else {
          _errorMessage = '$_errorMessage.';
        }
      });
      return;
    }

    // final String apiUrl = 'http://192.18.20.236:5000/api/login';
    final String apiUrl = 'http://10.95.121.11:5000/api/login';

    Map<String, String> requestBody = {
      'user_type': _selectedUserType!,
      'credential': _credentialController.text,
    };

    if (_selectedUserType == 'Admin') {
      requestBody['password'] = _passwordController.text;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody), // Kirim requestBody yang sudah disesuaikan
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'])),
        );
        final String displayName = responseBody['display_name'] ?? _credentialController.text; // Ambil display_name, fallback ke credential

        print('Navigating to dashboard...'); // Tambahkan baris ini
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: {
            'userType': _selectedUserType!,
            'credential': _credentialController.text,
            'displayName': displayName, // Teruskan nama lengkap
          },
        );
      } else {
        final errorBody = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorBody['message'] ?? 'Terjadi kesalahan saat login.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda atau alamat server.';
      });
      print('Error during login API call: $e');
    }
  }

  @override
  void dispose() {
    _credentialController.dispose();
    _passwordController.dispose(); // Dispose password controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Aplikasi Hafalan'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Logo atau Icon Aplikasi (opsional)
              // Icon(Icons.menu_book, size: 100, color: Colors.blueGrey),
              // const SizedBox(height: 30),

              const Text(
                'Selamat Datang!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 30),

              // Dropdown untuk memilih tipe pengguna
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Pilih Tipe Pengguna',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                value: _selectedUserType,
                hint: const Text('Pilih peran Anda'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUserType = newValue;
                    _credentialController.clear(); // Bersihkan input saat tipe berubah
                    // _passwordController.clear(); // Bersihkan password saat tipe berubah
                    _errorMessage = null; // Hapus pesan error
                  });
                },
                items: _userTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Input kredensial yang dinamis
              TextField(
                controller: _credentialController,
                decoration: InputDecoration(
                  labelText: _getInputLabel(),
                  hintText: 'Masukkan ${_getInputLabel()}',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: Icon(
                    // _selectedUserType == 'Admin'
                    //     ? Icons.person
                    // _selectedUserType == 'Admin'
                    //         ? Icons.person
                            _selectedUserType == 'Guru'
                                ? Icons.school
                                : _selectedUserType == 'Santri'
                                    ? Icons.school
                                    : Icons.group),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: (_selectedUserType == 'Guru' || _selectedUserType == 'Santri')
                    ? TextInputType.number // NIP/NIS bisa angka
                    : TextInputType.text, // Username/Nama bisa teks
                obscureText: false,
              ),
              const SizedBox(height: 20),

              // Input Kata Sandi (hanya tampil untuk Admin)
              // if (_selectedUserType == 'Admin')
              //   TextField(
              //     controller: _passwordController,
              //     decoration: InputDecoration(
              //       labelText: 'Kata Sandi',
              //       hintText: 'Masukkan Kata Sandi Anda',
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(8.0),
              //       ),
              //       prefixIcon: const Icon(Icons.lock),
              //       contentPadding:
              //           const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              //     ),
              //     obscureText: true, // Untuk menyembunyikan input password
              //   ),
              // if (_selectedUserType == 'Admin')
              //   const SizedBox(height: 20), // Spasi setelah password input

              // Tampilkan pesan error jika ada
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),

              // Tombol Login
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}