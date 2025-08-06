import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';

class SummaryHafalanScreen extends StatefulWidget {
  final String kodeSantri;
  final String namaSantri;
  
  const SummaryHafalanScreen({
    super.key, 
    required this.kodeSantri,
    required this.namaSantri,
  });

  @override
  State<SummaryHafalanScreen> createState() => _SummaryHafalanScreenState();
}

class _SummaryHafalanScreenState extends State<SummaryHafalanScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _summaryData = {};
  List<dynamic> _logHarian = [];
  List<dynamic> _recentPenilaian = [];

  @override
  void initState() {
    super.initState();
    _fetchSummaryData();
  }

  Future<void> _fetchSummaryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch summary data
      final summaryUrl = '${ApiConfig.baseUrl}/api/santri/${widget.kodeSantri}/summary';
      final summaryResponse = await http.get(Uri.parse(summaryUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (summaryResponse.statusCode == 200) {
        final summaryData = jsonDecode(summaryResponse.body);
        setState(() {
          _summaryData = summaryData;
        });
      }

      // Fetch log harian
      final logUrl = '${ApiConfig.baseUrl}/api/santri/${widget.kodeSantri}/log-harian';
      final logResponse = await http.get(Uri.parse(logUrl)).timeout(
        const Duration(seconds: 10),
      );

      if (logResponse.statusCode == 200) {
        final logData = jsonDecode(logResponse.body);
        setState(() {
          _logHarian = logData;
        });
      }

      // Fetch recent penilaian
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
        _errorMessage = 'Tidak dapat memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Summary Hafalan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Surat',
                    _summaryData['total_surat']?.toString() ?? '0',
                    Icons.book,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Ayat',
                    _summaryData['total_ayat']?.toString() ?? '0',
                    Icons.text_snippet,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Rata-rata Tajwid',
                    _summaryData['rata_tajwid']?.toString() ?? '0',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Sesi Hari Ini',
                    _summaryData['sesi_hari_ini']?.toString() ?? '0',
                    Icons.today,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLogHarianCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Log Harian',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_logHarian.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Belum ada log harian',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _logHarian.length,
                itemBuilder: (context, index) {
                  final log = _logHarian[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getLogIcon(log['jenis']),
                              color: _getLogColor(log['jenis']),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                log['aktivitas'] ?? 'Aktivitas tidak diketahui',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tanggal: ${log['tanggal'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (log['catatan'] != null && log['catatan'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Catatan: ${log['catatan']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPenilaianCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assessment, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Penilaian Terbaru',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentPenilaian.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Belum ada penilaian',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentPenilaian.length,
                itemBuilder: (context, index) {
                  final penilaian = _recentPenilaian[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPenilaianColor(penilaian['hasil_naive_bayes']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getPenilaianColor(penilaian['hasil_naive_bayes']).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getPenilaianIcon(penilaian['hasil_naive_bayes']),
                              color: _getPenilaianColor(penilaian['hasil_naive_bayes']),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${penilaian['surat']} (Ayat ${penilaian['dari_ayat']}-${penilaian['sampai_ayat']})',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tanggal: ${penilaian['tanggal_penilaian'] != null ? penilaian['tanggal_penilaian'].split('T')[0] : 'N/A'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Hasil: ${penilaian['hasil_naive_bayes']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getPenilaianColor(penilaian['hasil_naive_bayes']),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (penilaian['catatan'] != null && penilaian['catatan'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Catatan: ${penilaian['catatan']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _getLogIcon(String? jenis) {
    switch (jenis?.toLowerCase()) {
      case 'hafalan':
        return Icons.book;
      case 'penilaian':
        return Icons.assessment;
      case 'catatan':
        return Icons.note;
      default:
        return Icons.info;
    }
  }

  Color _getLogColor(String? jenis) {
    switch (jenis?.toLowerCase()) {
      case 'hafalan':
        return Colors.green;
      case 'penilaian':
        return Colors.blue;
      case 'catatan':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getPenilaianIcon(String? hasil) {
    switch (hasil?.toLowerCase()) {
      case 'baik':
        return Icons.check_circle;
      case 'cukup':
        return Icons.info;
      case 'kurang':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  Color _getPenilaianColor(String? hasil) {
    switch (hasil?.toLowerCase()) {
      case 'baik':
        return Colors.green;
      case 'cukup':
        return Colors.orange;
      case 'kurang':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Summary ${widget.namaSantri}'),
        backgroundColor: const Color.fromARGB(255, 26, 144, 11),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchSummaryData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchSummaryData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header dengan foto profil dan info santri
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 26, 144, 11),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    widget.namaSantri.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 26, 144, 11),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.namaSantri,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Kode: ${widget.kodeSantri}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSummaryCard(),
                        const SizedBox(height: 16),
                        _buildLogHarianCard(),
                        const SizedBox(height: 16),
                        _buildRecentPenilaianCard(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }
} 