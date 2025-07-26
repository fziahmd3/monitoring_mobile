import 'package:flutter/material.dart';
import 'package:monitoring_hafalan_app/screens/penilaian_hafalan_form_screen.dart'; // Import baru
import 'package:monitoring_hafalan_app/screens/profile_screen.dart'; // Import the new unified profile screen
import 'package:monitoring_hafalan_app/screens/rekam_hafalan_screen.dart'; // Import halaman rekam hafalan baru
// Import global navigatorKey
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoring_hafalan_app/screens/kemajuan_hafalan_screen.dart';
import '../api_config.dart';

class DashboardScreen extends StatefulWidget {
  final String userType;
  final String credential;
  final String displayName;

  const DashboardScreen({super.key, required this.userType, required this.credential, required this.displayName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _initializeWidgetOptions();
  }

  void _initializeWidgetOptions() {
    if (widget.userType == 'Guru') {
      _widgetOptions = <Widget>[
        _buildHomeScreen(),
        PilihSantriUntukPenilaian(),
        ProfileScreen(userType: widget.userType, credential: widget.credential, displayName: widget.displayName),
      ];
    } else { // Santri and Orang Tua Santri
      _widgetOptions = <Widget>[
        _buildHomeScreen(),
        KemajuanHafalanScreen(kodeSantri: widget.credential),
        ProfileScreen(userType: widget.userType, credential: widget.credential, displayName: widget.displayName),
      ];
    }
  }

  Widget _buildHomeScreen() {
    if (widget.userType == 'Santri') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat datang di halaman utama santri!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RekamHafalanScreen(kodeSantri: widget.credential)));
              },
              child: const Text('Rekam Hafalan'),
            ),
          ],
        ),
      );
    } else {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
        ],
      ),
    );
    }
  }

  // Add a helper method for the generic profile screen for other users (if needed)
  Widget _buildProfileScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Profil Screen',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildAnimatedIcon(IconData iconData, int itemIndex) {
    final bool isSelected = _selectedIndex == itemIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.translationValues(
        0, // X-axis translation
        isSelected ? -5.0 : 0.0, // Y-axis translation (moves up when selected)
        0, // Z-axis translation
      ),
      child: Icon(iconData),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavBarItems() {
    if (widget.userType == 'Guru') {
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.home, 0),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.analytics, 1),
          label: 'Form Penilaian',
        ),
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.person, 2),
          label: 'Profil',
        ),
      ];
    } else { // Santri and Orang Tua Santri
      return <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.home, 0),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.book, 1),
          label: 'Kemajuan Hafalan',
        ),
        BottomNavigationBarItem(
          icon: _buildAnimatedIcon(Icons.person, 2),
          label: 'Profil',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Selamat datang, ${widget.displayName}!',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 26, 144, 11),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _getBottomNavBarItems(), // Use the dynamic list of items
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 26, 144, 11),
        selectedIconTheme: const IconThemeData(size: 30),
        onTap: _onItemTapped,
      ),
    );
  }
}

// Widget baru untuk memilih santri sebelum penilaian
class PilihSantriUntukPenilaian extends StatefulWidget {
  @override
  State<PilihSantriUntukPenilaian> createState() => _PilihSantriUntukPenilaianState();
}

class _PilihSantriUntukPenilaianState extends State<PilihSantriUntukPenilaian> {
  List<dynamic> _santriList = [];
  bool _isLoading = true;
  String? _selectedKodeSantri;

  @override
  void initState() {
    super.initState();
    _fetchSantriList();
  }

  Future<void> _fetchSantriList() async {
    final apiUrl = '${ApiConfig.baseUrl}/api/daftar_santri';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _santriList = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_selectedKodeSantri != null) {
      return PenilaianHafalanFormScreen(kodeSantri: _selectedKodeSantri!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Pilih Santri untuk Penilaian', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Santri',
            border: OutlineInputBorder(),
          ),
          value: _selectedKodeSantri,
          hint: const Text('Pilih santri'),
          onChanged: (String? newValue) {
            setState(() {
              _selectedKodeSantri = newValue;
            });
          },
          items: _santriList.map<DropdownMenuItem<String>>((santri) {
            return DropdownMenuItem<String>(
              value: santri['kode_santri'],
              child: Text('${santri['nama_lengkap']} (${santri['kode_santri']})'),
            );
          }).toList(),
        ),
      ],
    );
  }
}