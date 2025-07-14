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
  String? _errorMessage;
  bool _isLoading = true;
  bool _isLoadingPredictions = false; // New loading state for predictions

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    if (widget.userType == 'Santri') {
      _fetchPredictionResults();
    }
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String apiUrl = '';
    if (widget.userType == 'Santri') {
      // apiUrl = 'http://10.95.121.11:5000/api/santri_profile/${widget.credential}';
      apiUrl = 'http://192.18.20.236:5000/api/santri_profile/${widget.credential}';
    } else if (widget.userType == 'Guru') {
      // TODO: Implement API for Guru profile when data is available
      _errorMessage = 'Profil Guru belum tersedia.';
      _isLoading = false;
      return;
    } else if (widget.userType == 'Orang Tua Santri') {
      // TODO: Implement API for Orang Tua Santri profile when data is available
      _errorMessage = 'Profil Orang Tua Santri belum tersedia.';
      _isLoading = false;
      return;
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

    // final String apiUrl = 'http://10.95.121.11:5000/api/santri/${widget.credential}/predictions';
    final String apiUrl = 'http://192.18.20.236:5000/api/santri/${widget.credential}/predictions';

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
                  ProfileMenu(text: "Nama Lengkap: ${_profileData!['nama_lengkap']}", icon: "assets/icons/User Icon.svg", press: () {}),
                  ProfileMenu(text: "NIS: ${_profileData!['nis']}", icon: "assets/icons/User Icon.svg", press: () {}),
                  ProfileMenu(text: "Kelas: ${_profileData!['kelas']}", icon: "assets/icons/User Icon.svg", press: () {}),
                  ProfileMenu(text: "Alamat: ${_profileData!['alamat']}", icon: "assets/icons/User Icon.svg", press: () {}),
                  ProfileMenu(text: "Nama Orang Tua: ${_profileData!['nama_orang_tua']}", icon: "assets/icons/User Icon.svg", press: () {}),
                  const SizedBox(height: 20),
                  const Text(
                    'Riwayat Prediksi Hafalan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _isLoadingPredictions
                      ? const CircularProgressIndicator() // Show loading indicator for predictions
                      : (_predictionResults == null || _predictionResults!.isEmpty)
                          ? const Text('Tidak ada riwayat prediksi.')
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _predictionResults!.length,
                              itemBuilder: (context, index) {
                                final prediction = _predictionResults![index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  elevation: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
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
                                  ),
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
    // final uri = Uri.parse('http://10.95.121.11:5000/api/upload_profile_picture');
    final uri = Uri.parse('http://192.18.20.236:5000/api/upload_profile_picture');
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
        // ? 'http://10.95.121.11:5000/static/profile_pics/${widget.currentImageUrl}' // Full URL for server image
        // : "https://i.postimg.cc/0jqKB6mS/Profile-Image.png"; // Default image
        ? 'http://192.18.20.236:5000/static/profile_pics/${widget.currentImageUrl}' // Full URL for server image
        : "https://i.postimg.cc/0jqKB6mS/Profile-Image.png"; // Default image

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