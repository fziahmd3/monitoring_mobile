import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monitoring_hafalan_app/screens/login_screen.dart';
import 'package:monitoring_hafalan_app/screens/dashboard_screen.dart'; // Import DashboardScreen

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // Definisikan GlobalKey

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Gunakan GlobalKey di MaterialApp
      title: 'Aplikasi Monitoring Hafalan Al-Quran',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/', // Tetapkan rute awal sebagai '/'
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>; // Ubah tipe menjadi dynamic
          return DashboardScreen(
            userType: args['userType']!,
            credential: args['credential']!,
            displayName: args['displayName']!, // Teruskan displayName
          );
        },
      },
    );
  }
}