import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // Add this import
import 'dart:io'; // Add this import

class ProfileScreen extends StatefulWidget {
  final String userType;
  final String credential;
  final String displayName;

  const ProfileScreen({super.key, required this.userType, required this.credential, required this.displayName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;
  List<dynamic>? _predictionResults; // New state variable for prediction results
  List<dynamic>? _penilaianResults; // State untuk riwayat penilaian hafalan
  String? _errorMessage;
  bool _isLoading = true;
  bool _isLoadingPredictions = false; // New loading state for predictions
  bool _isLoadingPenilaian = false; // Loading state untuk penilaian
  String? _selectedSuratFilter;
  final List<String> _daftarSurat = [
    'Semua',
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

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    if (widget.userType == 'Santri') {
      _fetchPredictionResults();
      _fetchPenilaianResults();
    }
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String apiUrl = '';
    if (widget.userType == 'Santri') {
      apiUrl = 'http://10.123.201.11:5000/api/santri_profile/${widget.credential}';
      // apiUrl = 'http://192.18.20.236:5000/api/santri_profile/${widget.credential}';
    } else if (widget.userType == 'Guru') {
      apiUrl = 'http://10.123.201.11:5000/api/guru_profile/${widget.credential}';
    } else if (widget.userType == 'Orang Tua Santri') {
      apiUrl = 'http://10.123.201.11:5000/api/orangtua_profile/${widget.credential}';
    }

    if (apiUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Tipe pengguna tidak didukung atau URL API kosong.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          _profileData = jsonDecode(response.body);
        });
      } else {
        final errorBody = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorBody['message'] ?? 'Gagal memuat profil.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server. Error: $e';
      });
      print('Error fetching profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPredictionResults() async {
    setState(() {
      _isLoadingPredictions = true;
    });

    final String apiUrl = 'http://10.123.201.11:5000/api/santri/${widget.credential}/predictions';
    // final String apiUrl = 'http://192.18.20.236:5000/api/santri/${widget.credential}/predictions';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          _predictionResults = jsonDecode(response.body);
        });
      } else {
        // Handle error, maybe set a specific error message for predictions
        print('Failed to load predictions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching predictions: $e');
    } finally {
      setState(() {
        _isLoadingPredictions = false;
      });
    }
  }

  Future<void> _fetchPenilaianResults() async {
    setState(() {
      _isLoadingPenilaian = true;
    });
    final String apiUrl = 'http://10.123.201.11:5000/api/santri/${widget.credential}/penilaian';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _penilaianResults = jsonDecode(response.body);
        });
      }
    } catch (e) {
      // ignore error
    } finally {
      setState(() {
        _isLoadingPenilaian = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Profil"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            ProfilePic(
              userType: widget.userType,
              credential: widget.credential,
              currentImageUrl: _profileData?['profile_picture'], // Pass current image URL
              onImageUploaded: _fetchProfileData, // Callback to refresh data
            ),
            const SizedBox(height: 20),
            if (widget.userType == 'Santri' && _profileData != null)
              Column(
                children: [
                  ProfileMenu(
                    text: "Profil",
                    icon: "assets/icons/User Icon.svg",
                    press: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Detail Santri'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Nama Lengkap: "+(_profileData!["nama_lengkap"] ?? "")),
                                Text("NIS: "+(_profileData!["nis"] ?? "")),
                                Text("Kelas: "+(_profileData!["kelas"] ?? "")),
                                Text("Alamat: "+(_profileData!["alamat"] ?? "")),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Tutup'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  ProfileMenu(
                    text: "Lihat Hasil Prediksi",
                    icon: "assets/icons/Chart.svg",
                    press: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Riwayat Prediksi Hafalan'),
                            content: _isLoadingPredictions
                                ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
                                : (_predictionResults == null || _predictionResults!.isEmpty)
                                    ? const Text('Tidak ada riwayat prediksi.')
                                    : SizedBox(
                                        width: 300,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _predictionResults!.length,
                                          itemBuilder: (context, index) {
                                            final prediction = _predictionResults![index];
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Tanggal: ${prediction['predicted_at'] != null ? prediction['predicted_at'].split('T')[0] : 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                  Text('Tingkat Hafalan: ${prediction['tingkat_hafalan']}'),
                                                  Text('Jumlah Setoran: ${prediction['jumlah_setoran']}'),
                                                  Text('Kehadiran: ${prediction['kehadiran']}%'),
                                                  Text('Hasil Prediksi: ${prediction['hasil_prediksi']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Tutup'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  ProfileMenu(
                    text: "Lihat Riwayat Penilaian Hafalan",
                    icon: "assets/icons/Chart.svg",
                    press: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final filteredPenilaian = _selectedSuratFilter == null || _selectedSuratFilter == 'Semua'
                              ? _penilaianResults
                              : _penilaianResults?.where((p) => p['surat'] == _selectedSuratFilter).toList();
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: const Text('Riwayat Penilaian Hafalan'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Filter Surat',
                                          border: OutlineInputBorder(),
                                        ),
                                        value: _selectedSuratFilter ?? 'Semua',
                                        items: _daftarSurat.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                        onChanged: (val) {
                                          setState(() {
                                            _selectedSuratFilter = val;
                                          });
                                        },
                                      ),
                                      const SizedBox(height: 15),
                                      _isLoadingPenilaian
                                          ? const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()))
                                          : (filteredPenilaian == null || filteredPenilaian.isEmpty)
                                              ? const Text('Tidak ada riwayat penilaian.')
                                              : SizedBox(
                                                  width: 300,
                                                  height: 300,
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    itemCount: filteredPenilaian.length,
                                                    itemBuilder: (context, index) {
                                                      final penilaian = filteredPenilaian[index];
                                                      return Padding(
                                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text('Tanggal: ${penilaian['tanggal_penilaian'] != null ? penilaian['tanggal_penilaian'].split('T')[0] : 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                            Text('Surat: ${penilaian['surat']}'),
                                                            Text('Ayat: ${penilaian['dari_ayat']} - ${penilaian['sampai_ayat']}'),
                                                            Text('Tajwid: ${penilaian['penilaian_tajwid']}'),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Tutup'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            else if (widget.userType == 'Guru' && _profileData != null)
              Column(
                children: [
                  ProfileMenu(
                    text: "Profil Guru",
                    icon: "assets/icons/User Icon.svg",
                    press: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Detail Guru'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Nama Lengkap: "+(_profileData!["nama_lengkap"] ?? "")),
                                Text("NIP: "+(_profileData!["nip"] ?? "")),
                                Text("Pendidikan Terakhir: "+(_profileData!["pendidikan_terakhir"] ?? "")),
                                Text("No. Telepon: "+(_profileData!["nomor_telepon"] ?? "")),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Tutup'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            else if (widget.userType == 'Orang Tua Santri' && _profileData != null)
              Column(
                children: [
                  ProfileMenu(
                    text: "Profil Orang Tua Santri",
                    icon: "assets/icons/User Icon.svg",
                    press: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Detail Orang Tua Santri'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Nama: "+(_profileData!["nama"] ?? "")),
                                Text("Nama Santri: "+(_profileData!["nama_santri"] ?? "")),
                                Text("Alamat: "+(_profileData!["alamat"] ?? "")),
                                Text("No. Telepon: "+(_profileData!["nomor_telepon"] ?? "")),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Tutup'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            else if (widget.userType == 'Guru' || widget.userType == 'Orang Tua Santri')
              // Placeholder for Guru/Orang Tua Santri profile
              ProfileMenu(
                text: "Selamat datang, ${widget.displayName}",
                icon: "assets/icons/User Icon.svg",
                press: () {},
              ),
            ProfileMenu(
              text: "Log Out",
              icon: "assets/icons/Log out.svg",
              press: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePic extends StatefulWidget { // Change to StatefulWidget
  final String userType;
  final String credential;
  final String? currentImageUrl; // New parameter for current profile picture
  final VoidCallback onImageUploaded; // Callback to notify parent on upload success

  const ProfilePic({
    Key? key,
    required this.userType,
    required this.credential,
    this.currentImageUrl,
    required this.onImageUploaded,
  }) : super(key: key);

  @override
  State<ProfilePic> createState() => _ProfilePicState();
}

class _ProfilePicState extends State<ProfilePic> {
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isUploading = true;
      });

      // Upload image to Flask backend
      await _uploadImage(_imageFile!);

      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _uploadImage(File image) async {
    final uri = Uri.parse('http://10.123.201.11:5000/api/upload_profile_picture');
    // final uri = Uri.parse('http://192.18.20.236:5000/api/upload_profile_picture');
    final request = http.MultipartRequest('POST', uri)
      ..fields['user_type'] = widget.userType
      ..fields['credential'] = widget.credential
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);
        print('Upload success: ${data['message']}');
        widget.onImageUploaded(); // Notify parent to refresh data
      } else {
        final errorBody = await response.stream.bytesToString();
        print('Upload failed with status ${response.statusCode}: $errorBody');
        // Handle error, e.g., show a snackbar
      }
    } catch (e) {
      print('Error uploading image: $e');
      // Handle error, e.g., show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty
        ? 'http://10.123.201.11:5000/static/profile_pics/${widget.currentImageUrl}' // Full URL for server image
        : "https://i.postimg.cc/0jqKB6mS/Profile-Image.png"; // Default image
        // ? 'http://192.18.20.236:5000/static/profile_pics/${widget.currentImageUrl}' // Full URL for server image
        // : "https://i.postimg.cc/0jqKB6mS/Profile-Image.png"; // Default image

    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(imageUrl),
          ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: _isUploading ? null : _pickAndUploadImage, // Disable button during upload
                child: _isUploading
                    ? const CircularProgressIndicator(color: Color(0xFFFF7643)) // Show loading indicator
                    : SvgPicture.asset("assets/icons/Camera Icon.svg"),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    required this.press,
  }) : super(key: key);

  final String text, icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: press,
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn), // Ensure icon color is visible
              width: 22,
            ),
            const SizedBox(width: 20),
            Expanded(child: Text(text)),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
} 