import 'package:flutter/material.dart';
import 'package:monitoring_hafalan_app/screens/penilaian_hafalan_form_screen.dart'; // Import baru
import 'package:monitoring_hafalan_app/screens/profile_screen.dart'; // Import the new unified profile screen
import 'package:monitoring_hafalan_app/screens/rekam_hafalan_screen.dart'; // Import halaman rekam hafalan baru
// Import global navigatorKey
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:monitoring_hafalan_app/screens/kemajuan_hafalan_screen.dart';
import 'package:monitoring_hafalan_app/screens/rekam_hafalan_screen.dart';
import '../api_config.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:monitoring_hafalan_app/utils/audio_helper.dart';
import 'dart:math';

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

  // Tambahan untuk fitur guru melihat rekaman santri
  final TextEditingController _kodeSantriController = TextEditingController();
  List<String> _rekamanFiles = [];
  bool _isLoadingRekaman = false;
  String? _errorRekaman;

  // Untuk progress hafalan santri
  List<dynamic> _penilaian = [];
  bool _isLoadingProgress = false;
  String? _progressError;

  // Tips harian/mingguan
  final List<String> _tipsHafalan = [
    'Ulangi hafalan setiap hari setelah shalat.',
    'Buat jadwal rutin dan konsisten.',
    'Dengarkan murattal untuk memperbaiki bacaan.',
    'Tulis ayat yang dihafal untuk memperkuat ingatan.',
    'Jangan lupa murojaah hafalan lama.',
    'Baca dengan tartil dan pahami maknanya.',
    'Mintalah doa dan dukungan orang tua.',
    'Hafalkan di waktu yang sama setiap hari.',
    'Jangan terburu-buru, utamakan kualitas.',
    'Ajak teman untuk saling menyetorkan hafalan.'
  ];

  // Kutipan motivasi
  final List<Map<String, String>> _kutipanMotivasi = [
    {
      'teks': 'Sebaik-baik kalian adalah yang belajar Al-Qur’an dan mengajarkannya.',
      'sumber': 'HR. Bukhari'
    },
    {
      'teks': 'Bacalah Al-Qur’an, karena ia akan datang pada hari kiamat sebagai pemberi syafaat bagi para pembacanya.',
      'sumber': 'HR. Muslim'
    },
    {
      'teks': 'Barangsiapa membaca satu huruf dari Kitab Allah, maka baginya satu kebaikan.',
      'sumber': 'HR. Tirmidzi'
    },
    {
      'teks': 'Sesungguhnya Allah memiliki keluarga di antara manusia, yaitu Ahlul Qur’an.',
      'sumber': 'HR. Ahmad'
    },
    {
      'teks': 'Pelajarilah Al-Qur’an dan bacalah, karena perumpamaan Al-Qur’an bagi orang yang mempelajarinya lalu membacanya dalam shalat adalah seperti kantong berisi minyak wangi yang baunya semerbak ke mana-mana.',
      'sumber': 'HR. Bukhari dan Muslim'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeWidgetOptions();
    if (widget.userType == 'Santri') {
      _fetchProgressHafalan();
    }
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

  Future<void> _fetchRekamanSantri(String kodeSantri) async {
    setState(() {
      _isLoadingRekaman = true;
      _errorRekaman = null;
      _rekamanFiles = [];
    });
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/rekaman_santri/$kodeSantri');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _rekamanFiles = List<String>.from(data['files']);
        });
      } else {
        setState(() {
          _errorRekaman = 'Gagal memuat rekaman (status: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorRekaman = 'Terjadi error: $e';
      });
    } finally {
      setState(() {
        _isLoadingRekaman = false;
      });
    }
  }

  Future<void> _playRemoteRecording(String filename) async {
    final url = '${ApiConfig.baseUrl}/static/recordings/$filename';
    try {
      await AudioHelper.initialize();
      await AudioHelper.stopAudio();
      await AudioHelper.playAudio(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memutar rekaman: $e')),
      );
    }
  }

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

  Widget _buildHomeScreen() {
    if (widget.userType == 'Santri') {
      final motivasi = _kutipanMotivasi[Random().nextInt(_kutipanMotivasi.length)];
      final tips = _tipsHafalan[DateTime.now().day % _tipsHafalan.length];
      final progress = _hitungProgress();
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.format_quote, color: Colors.green, size: 32),
                      Text(
                        '"${motivasi['teks']}"',
                        style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('- ${motivasi['sumber']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.auto_stories, color: Colors.blue, size: 36),
                  title: const Text('Progress Hafalan'),
                  subtitle: _isLoadingProgress
                      ? const LinearProgressIndicator()
                      : _progressError != null
                          ? Text(_progressError!, style: const TextStyle(color: Colors.red))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Total Juz: ${progress['totalJuz']}'),
                                    Text('Juz Terakhir: ${progress['juzTerakhir']}'),
                                  ],
                                ),
                                Text('${progress['persentase'].toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.yellow[50],
                child: ListTile(
                  leading: const Icon(Icons.lightbulb, color: Colors.orange, size: 36),
                  title: const Text('Tips Hafalan Hari Ini'),
                  subtitle: Text(tips),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Silakan rekam hafalan Anda:',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showRekamHafalanDialog();
                  },
                  icon: const Icon(Icons.mic),
                  label: const Text('Rekam Hafalan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (widget.userType == 'Guru') {
      return Center(
        child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Selamat datang, Guru ${widget.displayName}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
                'Masukkan kode santri untuk melihat rekaman yang diupload:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180,
                    child: TextField(
                      controller: _kodeSantriController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Santri',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
              onPressed: () {
                      final kode = _kodeSantriController.text.trim();
                      if (kode.isNotEmpty) {
                        _fetchRekamanSantri(kode);
                      }
                    },
                    child: const Text('Cari'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isLoadingRekaman)
                const CircularProgressIndicator(),
              if (_errorRekaman != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_errorRekaman!, style: const TextStyle(color: Colors.red)),
                ),
              if (_rekamanFiles.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Daftar Rekaman:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ..._rekamanFiles.map((file) => Card(
                          child: ListTile(
                            title: Text(file),
                            trailing: IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => _playRemoteRecording(file),
                            ),
                            subtitle: Text('${ApiConfig.baseUrl}/static/recordings/$file'),
                          ),
                        )),
                  ],
                ),
              if (!_isLoadingRekaman && _rekamanFiles.isEmpty && _kodeSantriController.text.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Tidak ada rekaman untuk kode santri ini.'),
            ),
          ],
          ),
        ),
      );
    } else if (widget.userType == 'Orang Tua Santri') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selamat datang, Orang Tua ${widget.displayName}!', // Personalized welcome
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Lihat kemajuan hafalan putra/putri Anda:',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to KemajuanHafalanScreen
                Navigator.push(context, MaterialPageRoute(builder: (context) => KemajuanHafalanScreen(kodeSantri: widget.credential)));
              },
              icon: const Icon(Icons.track_changes), // Icon for progress tracking
              label: const Text('Lihat Kemajuan Hafalan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gunakan navigasi di bawah untuk detail lebih lanjut.', // Placeholder
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      // Default fallback for unknown user types or initial empty state
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selamat datang!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Silakan pilih tipe pengguna Anda dari navigasi di bawah.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
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

  void _fetchProgressHafalan() async {
    setState(() {
      _isLoadingProgress = true;
      _progressError = null;
    });
    try {
      final apiUrl = '${ApiConfig.baseUrl}/api/santri/${widget.credential}/penilaian';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _penilaian = List.from(jsonDecode(response.body));
          _isLoadingProgress = false;
        });
      } else {
        setState(() {
          _progressError = 'Gagal memuat data progress.';
          _isLoadingProgress = false;
        });
      }
    } catch (e) {
      setState(() {
        _progressError = 'Tidak dapat terhubung ke server.';
        _isLoadingProgress = false;
      });
    }
  }

  Map<String, dynamic> _hitungProgress() {
    if (_penilaian.isEmpty) {
      return {
        'totalJuz': 0,
        'juzTerakhir': '-',
        'persentase': 0.0,
      };
    }
    // Asumsi: setiap penilaian punya field 'surat', dan juz bisa diambil dari nama surat
    // Untuk demo, kita asumsikan setiap 20 surat = 1 juz (bisa disesuaikan dengan mapping sebenarnya)
    final List<String> daftarSurat = [
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
    final juzMap = <int, List<String>>{};
    for (int i = 0; i < daftarSurat.length; i++) {
      final juz = (i ~/ 20) + 1;
      juzMap.putIfAbsent(juz, () => []).add(daftarSurat[i]);
    }
    Set<String> suratHafal = _penilaian.map((p) => p['surat'] as String).toSet();
    int totalJuz = 0;
    int juzTerakhir = 0;
    for (var entry in juzMap.entries) {
      if (entry.value.every((s) => suratHafal.contains(s))) {
        totalJuz++;
        juzTerakhir = entry.key;
      }
    }
    // Persentase kemajuan: jumlah surat yang sudah dihafal / total surat x 100
    double persentase = suratHafal.length / daftarSurat.length * 100;
    return {
      'totalJuz': totalJuz,
      'juzTerakhir': juzTerakhir == 0 ? '-' : 'Juz $juzTerakhir',
      'persentase': persentase,
    };
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