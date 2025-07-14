import 'package:flutter/material.dart';
import 'package:monitoring_hafalan_app/screens/login_screen.dart'; // Import layar login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome(); // Panggil fungsi navigasi saat inisialisasi state
  }

  _navigateToHome() async {
    // Tunggu selama 3 detik (atau durasi yang diinginkan)
    await Future.delayed(const Duration(seconds: 3), () {});

    // Navigasi ke layar Login dan hapus SplashScreen dari stack
    if (mounted) { // Pastikan widget masih ada di widget tree sebelum navigasi
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 26, 144, 11), // Warna latar belakang splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/icons/logo.png', width: 150, height: 150), // Menggunakan logo aplikasi
            const SizedBox(height: 20),
            const Text(
              'Aplikasi Monitoring Hafalan Al-Quran',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Warna loading indicator
            ),
          ],
        ),
      ),
    );
  }
}