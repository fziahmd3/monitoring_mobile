import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

class OrangTuaDashboardScreen extends StatefulWidget {
  final String kodeOrangTua;
  final String namaOrangTua;
  
  const OrangTuaDashboardScreen({
    super.key, 
    required this.kodeOrangTua,
    required this.namaOrangTua,
  });

  @override
  State<OrangTuaDashboardScreen> createState() => _OrangTuaDashboardScreenState();
}

class _OrangTuaDashboardScreenState extends State<OrangTuaDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _progressData = {};

  @override
  void initState() {
    super.initState();
    _fetchProgressAnak();
  }

  Future<void> _fetchProgressAnak() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('=== Fetching Progress Anak ===');
      print('Kode Orang Tua: ${widget.kodeOrangTua}');
      print('URL: ${ApiConfig.baseUrl}/api/orangtua/${widget.kodeOrangTua}/progress_anak');
      
      final url = '${ApiConfig.baseUrl}/api/orangtua/${widget.kodeOrangTua}/progress_anak';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );
      
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _progressData = data;
          _isLoading = false;
        });
        print('Data loaded successfully');
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Data orang tua tidak ditemukan. Silakan hubungi admin.';
          _isLoading = false;
        });
        print('Error: Data orang tua tidak ditemukan');
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorData['error'] ?? 'Gagal memuat data progress anak (Status: ${response.statusCode})';
          _isLoading = false;
        });
        print('Error: ${errorData['error']}');
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Progress Anak - ${widget.namaOrangTua}'),
        backgroundColor: const Color.fromARGB(255, 26, 144, 11),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProgressAnak,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchProgressAnak,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchProgressAnak,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header dengan info santri
                        _buildSantriHeader(),
                        const SizedBox(height: 24),
                        
                        // Progress Summary
                        _buildProgressSummary(),
                        const SizedBox(height: 24),
                        
                        // Recent Activity
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSantriHeader() {
    final santriInfo = _progressData['santri_info'] ?? {};
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green[100],
              child: Text(
                (santriInfo['nama'] ?? 'A')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info Santri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    santriInfo['nama'] ?? 'Nama Santri',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kode: ${santriInfo['kode_santri'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tingkatan: ${santriInfo['tingkatan'] ?? '-'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary() {
    final progressSummary = _progressData['progress_summary'] ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Progress',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Penilaian',
              progressSummary['total_penilaian']?.toString() ?? '0',
              Icons.assessment,
              Colors.blue,
            ),
            _buildStatCard(
              'Rata-rata Nilai',
              progressSummary['rata_rata_nilai']?.toString() ?? '0',
              Icons.analytics,
              Colors.green,
            ),
            _buildStatCard(
              'Status Terakhir',
              progressSummary['status_terakhir']?.toString() ?? '-',
              Icons.check_circle,
              _getStatusColor(progressSummary['status_terakhir']),
            ),
            _buildStatCard(
              'Surat Terakhir',
              progressSummary['surat_terakhir']?.toString() ?? '-',
              Icons.book,
              Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Terakhir',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Tanggal: ${progressSummary['tanggal_terakhir'] ?? '-'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.book, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Surat: ${progressSummary['surat_terakhir'] ?? '-'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentPenilaian = _progressData['recent_penilaian'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (recentPenilaian.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada aktivitas penilaian',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentPenilaian.length,
              itemBuilder: (context, index) {
                final penilaian = recentPenilaian[index];
                final isLulus = penilaian['status'] == 'LULUS';
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLulus ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      Icons.assessment,
                      color: isLulus ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text('${penilaian['surat']} (Ayat ${penilaian['dari_ayat']}-${penilaian['sampai_ayat']})'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nilai: ${penilaian['nilai']} - ${penilaian['status']}'),
                      if (penilaian['catatan'] != null && penilaian['catatan'].toString().isNotEmpty)
                        Text(
                          'Catatan: ${penilaian['catatan']}',
                          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.orange),
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        penilaian['tanggal'] ?? '-',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isLulus ? Colors.green[100] : Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isLulus ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Text(
                          penilaian['status'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isLulus ? Colors.green[800] : Colors.red[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    if (status == 'LULUS') {
      return Colors.green;
    } else if (status == 'TIDAK LULUS') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
} 