import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import 'summary_hafalan_screen.dart';
import 'kemajuan_hafalan_screen.dart';

class OverviewSantriScreen extends StatefulWidget {
  final String kodeSantri;
  final String namaSantri;
  
  const OverviewSantriScreen({
    super.key, 
    required this.kodeSantri,
    required this.namaSantri,
  });

  @override
  State<OverviewSantriScreen> createState() => _OverviewSantriScreenState();
}

class _OverviewSantriScreenState extends State<OverviewSantriScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _overviewData = {};
  List<dynamic> _recentPenilaian = [];

  @override
  void initState() {
    super.initState();
    _fetchOverviewData();
  }

  Future<void> _fetchOverviewData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch overview data
      final overviewUrl = '${ApiConfig.baseUrl}/api/santri/${widget.kodeSantri}/overview';
      final overviewResponse = await http.get(Uri.parse(overviewUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (overviewResponse.statusCode == 200) {
        final overviewData = jsonDecode(overviewResponse.body);
        setState(() {
          _overviewData = overviewData;
        });
      }

      // Fetch recent penilaian for quick stats
      final penilaianUrl = '${ApiConfig.baseUrl}/api/santri/${widget.kodeSantri}/penilaian';
      final penilaianResponse = await http.get(Uri.parse(penilaianUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (penilaianResponse.statusCode == 200) {
        final penilaianData = jsonDecode(penilaianResponse.body);
        setState(() {
          _recentPenilaian = penilaianData.take(5).toList();
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  bool _isLulus(dynamic hasilPrediksi) {
    const kkm = 75;
    try {
      if (hasilPrediksi is String) {
        final nilai = int.tryParse(hasilPrediksi);
        return nilai != null && nilai >= kkm;
      } else if (hasilPrediksi is int) {
        return hasilPrediksi >= kkm;
      } else if (hasilPrediksi is double) {
        return hasilPrediksi >= kkm;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Overview ${widget.namaSantri}'),
        backgroundColor: const Color.fromARGB(255, 26, 144, 11),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchOverviewData,
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
                        onPressed: _fetchOverviewData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchOverviewData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header dengan foto profil
                        _buildHeader(),
                        const SizedBox(height: 24),
                        
                        // Quick Stats
                        _buildQuickStats(),
                        const SizedBox(height: 24),
                        
                        // Progress Overview
                        _buildProgressOverview(),
                        const SizedBox(height: 24),
                        
                        // Recent Activity
                        _buildRecentActivity(),
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
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
                widget.namaSantri.isNotEmpty ? widget.namaSantri[0].toUpperCase() : 'S',
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
                    widget.namaSantri,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kode: ${widget.kodeSantri}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Status terakhir
                  if (_recentPenilaian.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isLulus(_recentPenilaian.first['hasil_naive_bayes']) 
                            ? Colors.green[100] 
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isLulus(_recentPenilaian.first['hasil_naive_bayes']) 
                              ? Colors.green 
                              : Colors.red,
                        ),
                      ),
                      child: Text(
                        _isLulus(_recentPenilaian.first['hasil_naive_bayes']) 
                            ? 'LULUS' 
                            : 'TIDAK LULUS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isLulus(_recentPenilaian.first['hasil_naive_bayes']) 
                              ? Colors.green[800] 
                              : Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistik Cepat',
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
              'Total Surat',
              _overviewData['total_surat']?.toString() ?? '0',
              Icons.book,
              Colors.blue,
            ),
            _buildStatCard(
              'Total Ayat',
              _overviewData['total_ayat']?.toString() ?? '0',
              Icons.text_snippet,
              Colors.green,
            ),
            _buildStatCard(
              'Rata-rata Nilai',
              _overviewData['rata_nilai']?.toString() ?? '0',
              Icons.analytics,
              Colors.orange,
            ),
            _buildStatCard(
              'Sesi Hari Ini',
              _overviewData['sesi_hari_ini']?.toString() ?? '0',
              Icons.today,
              Colors.purple,
            ),
          ],
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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

  Widget _buildProgressOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Hafalan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Progress Bar
                Row(
                  children: [
                    const Text('Target: '),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _overviewData['progress_percentage'] ?? 0.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${((_overviewData['progress_percentage'] ?? 0.0) * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Info tambahan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressInfo('Juz Terakhir', _overviewData['juz_terakhir'] ?? '-'),
                    _buildProgressInfo('Surat Terakhir', _overviewData['surat_terakhir'] ?? '-'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentPenilaian.length,
            itemBuilder: (context, index) {
              final penilaian = _recentPenilaian[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _isLulus(penilaian['hasil_naive_bayes']) 
                      ? Colors.green[100] 
                      : Colors.red[100],
                  child: Icon(
                    Icons.assessment,
                    color: _isLulus(penilaian['hasil_naive_bayes']) 
                        ? Colors.green 
                        : Colors.red,
                  ),
                ),
                title: Text('${penilaian['surat']} (Ayat ${penilaian['dari_ayat']}-${penilaian['sampai_ayat']})'),
                subtitle: Text(
                  'Nilai: ${penilaian['hasil_naive_bayes']} - ${_isLulus(penilaian['hasil_naive_bayes']) ? 'LULUS' : 'TIDAK LULUS'}',
                ),
                trailing: Text(
                  penilaian['tanggal_penilaian'] ?? '-',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SummaryHafalanScreen(
                  kodeSantri: widget.kodeSantri,
                  namaSantri: widget.namaSantri,
                ),
              ),
            );
          },
          icon: const Icon(Icons.analytics),
          label: const Text('Lihat Summary Lengkap'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => KemajuanHafalanScreen(
                  kodeSantri: widget.kodeSantri,
                ),
              ),
            );
          },
          icon: const Icon(Icons.trending_up),
          label: const Text('Lihat Progress Detail'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
} 