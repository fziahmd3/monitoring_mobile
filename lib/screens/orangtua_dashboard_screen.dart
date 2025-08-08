import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import '../utils/surat_data.dart';
import 'dart:math';
import '../utils/kutipan.dart';
import '../utils/tips.dart';

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
                        _buildQuoteAndTips(),
                        const SizedBox(height: 24),
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

  Widget _buildQuoteAndTips() {
    final motivasi = kutipanMotivasi[Random().nextInt(kutipanMotivasi.length)];
    final tips = tipsHafalan[DateTime.now().day % tipsHafalan.length];
    return Column(
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
        const SizedBox(height: 12),
        Card(
          color: Colors.yellow[50],
          child: ListTile(
            leading: const Icon(Icons.lightbulb, color: Colors.orange, size: 36),
            title: const Text('Tips Hafalan Hari Ini'),
            subtitle: Text(tips),
          ),
        ),
      ],
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
    final recentPenilaian = _progressData['recent_penilaian'] ?? [];

    // Olah status terakhir tiap surat
    Map<String, Map<String, dynamic>> lastStatusPerSurat = {};
    for (var p in recentPenilaian) {
      final surat = p['surat'];
      if (!lastStatusPerSurat.containsKey(surat)) {
        lastStatusPerSurat[surat] = p;
      }
    }
    
    // Daftar surat yang sudah lulus
    List<String> suratLulus = lastStatusPerSurat.entries
        .where((e) => e.value['status'] == 'LULUS')
        .map((e) => e.key)
        .toList();

    // Hitung rata-rata nilai per surat
    Map<String, List<double>> nilaiPerSurat = {};
    for (var p in recentPenilaian) {
      final surat = p['surat'];
      final nilai = double.tryParse(p['nilai']?.toString() ?? '0') ?? 0;
      nilaiPerSurat.putIfAbsent(surat, () => []).add(nilai);
    }
    
    Map<String, double> rataRataPerSurat = {};
    for (var entry in nilaiPerSurat.entries) {
      final rataRata = entry.value.reduce((a, b) => a + b) / entry.value.length;
      rataRataPerSurat[entry.key] = rataRata;
    }

    // Tambahkan semua surat yang belum dihafalkan
    Map<String, Map<String, dynamic>> allSuratStatus = {};
    
    // Tambahkan surat yang sudah dihafalkan
    for (var entry in lastStatusPerSurat.entries) {
      allSuratStatus[entry.key] = entry.value;
    }
    
    // Tambahkan surat yang belum dihafalkan
    for (var suratData in daftarSurat) {
      if (!allSuratStatus.containsKey(suratData.nama)) {
        allSuratStatus[suratData.nama] = {
          'surat': suratData.nama,
          'status': 'BELUM DIHAFALKAN',
          'dari_ayat': 1,
          'sampai_ayat': suratData.jumlahAyat,
          'nilai': 0,
          'tanggal': null,
        };
      }
    }

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
              onTap: () => _showTotalPenilaianDetail(recentPenilaian),
            ),
            _buildStatCard(
              'Rata-rata Nilai',
              progressSummary['rata_rata_nilai']?.toString() ?? '0',
              Icons.analytics,
              Colors.green,
              onTap: () => _showRataRataNilaiDetail(rataRataPerSurat),
            ),
            _buildStatCard(
              'Status Terakhir',
              '${allSuratStatus.length} Surat',
              Icons.check_circle,
              _getStatusColor(progressSummary['status_terakhir']),
              onTap: () => _showStatusTerakhirDetail(allSuratStatus),
            ),
            _buildStatCard(
              'Surat Terakhir',
              '${suratLulus.length} Lulus',
              Icons.book,
              Colors.orange,
              onTap: () => _showSuratLulusDetail(suratLulus),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
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
      ),
    );
  }

  void _showTotalPenilaianDetail(List<dynamic> penilaianList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.assessment, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Detail Total Penilaian',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: penilaianList.length,
                  itemBuilder: (context, index) {
                    final penilaian = penilaianList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: penilaian['status'] == 'LULUS' ? Colors.green[100] : Colors.red[100],
                        child: Icon(
                          Icons.assessment,
                          color: penilaian['status'] == 'LULUS' ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text('${penilaian['surat']} (Ayat ${penilaian['dari_ayat']}-${penilaian['sampai_ayat']})'),
                      subtitle: Text('Nilai: ${penilaian['nilai']} - ${penilaian['status']}'),
                      trailing: Text(penilaian['tanggal'] ?? '-'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRataRataNilaiDetail(Map<String, double> rataRataPerSurat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.analytics, color: Colors.green),
                    const SizedBox(width: 8),
                    const Text(
                      'Rata-rata Nilai per Surat',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: rataRataPerSurat.length,
                  itemBuilder: (context, index) {
                    final entry = rataRataPerSurat.entries.elementAt(index);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green[100],
                        child: const Icon(Icons.analytics, color: Colors.green),
                      ),
                      title: Text(entry.key),
                      subtitle: LinearProgressIndicator(
                        value: entry.value / 100.0,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                      ),
                      trailing: Text(
                        entry.value.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusTerakhirDetail(Map<String, Map<String, dynamic>> allSuratStatus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Status Terakhir Semua Surat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allSuratStatus.length,
                  itemBuilder: (context, index) {
                    final suratName = allSuratStatus.keys.elementAt(index);
                    final suratData = allSuratStatus[suratName]!;
                    final status = suratData['status'] ?? 'BELUM DIHAFALKAN';
                    final dariAyat = suratData['dari_ayat'] ?? 1;
                    final sampaiAyat = suratData['sampai_ayat'] ?? 1;
                    final nilaiRaw = suratData['nilai'] ?? 0;
                    final nilai = nilaiRaw is String ? double.tryParse(nilaiRaw) ?? 0.0 : (nilaiRaw is num ? nilaiRaw.toDouble() : 0.0);
                    final tanggal = suratData['tanggal'];
                    
                    Color statusColor;
                    IconData statusIcon;
                    
                    switch (status) {
                      case 'LULUS':
                        statusColor = Colors.green;
                        statusIcon = Icons.check_circle;
                        break;
                      case 'TIDAK LULUS':
                        statusColor = Colors.red;
                        statusIcon = Icons.cancel;
                        break;
                      default:
                        statusColor = Colors.grey;
                        statusIcon = Icons.help;
                        break;
                    }
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(statusIcon, color: statusColor),
                        title: Text(
                          suratName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: $status'),
                            Text('Ayat: $dariAyat-$sampaiAyat'),
                            if (nilai > 0.0) Text('Nilai: ${nilai.toStringAsFixed(1)}'),
                            if (tanggal != null) Text('Tanggal: $tanggal'),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuratLulusDetail(List<String> suratLulus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.book, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Surat yang Sudah Lulus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: suratLulus.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada surat yang lulus',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: suratLulus.length,
                        itemBuilder: (context, index) {
                          final suratName = suratLulus[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.check_circle, color: Colors.green),
                              title: Text(
                                suratName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text('Status: LULUS'),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'LULUS',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
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
    switch (status) {
      case 'LULUS':
        return Colors.green;
      case 'TIDAK LULUS':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
} 