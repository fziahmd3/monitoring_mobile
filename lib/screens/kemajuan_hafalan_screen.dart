import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class KemajuanHafalanScreen extends StatefulWidget {
  final String nis;
  const KemajuanHafalanScreen({super.key, required this.nis});

  @override
  State<KemajuanHafalanScreen> createState() => _KemajuanHafalanScreenState();
}

class _KemajuanHafalanScreenState extends State<KemajuanHafalanScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _penilaian = [];
  Map<String, double> _rataRataTajwid = {};

  final List<String> _daftarTajwid = ['Kurang', 'Cukup', 'Baik', 'Sangat Baik'];
  final Map<String, double> _nilaiTajwid = {
    'Kurang': 1,
    'Cukup': 2,
    'Baik': 3,
    'Sangat Baik': 4,
  };

  @override
  void initState() {
    super.initState();
    _fetchPenilaian();
  }

  Future<void> _fetchPenilaian() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final apiUrl = 'http://10.123.201.11:5000/api/santri/${widget.nis}/penilaian';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _penilaian = data;
          _hitungRataRata();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data penilaian.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server.';
        _isLoading = false;
      });
    }
  }

  void _hitungRataRata() {
    Map<String, List<double>> temp = {};
    for (var p in _penilaian) {
      final surat = p['surat'];
      final nilai = _nilaiTajwid[p['penilaian_tajwid']] ?? 0;
      temp.putIfAbsent(surat, () => []).add(nilai);
    }
    _rataRataTajwid = {
      for (var entry in temp.entries)
        entry.key: entry.value.isNotEmpty ? entry.value.reduce((a, b) => a + b) / entry.value.length : 0
    };
  }

  @override
  Widget build(BuildContext context) {
    final sortedRataRata = _rataRataTajwid.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sortedRataRata.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kemajuan Hafalan'),
        backgroundColor: const Color.fromARGB(255, 26, 144, 11),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _rataRataTajwid.isEmpty
                  ? const Center(child: Text('Belum ada data penilaian.'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Rata-rata Penilaian Tajwid per Surat (Top 5)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 250,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 4,
                                  minY: 0,
                                  barTouchData: BarTouchData(enabled: true),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          if (value < 1 || value > 4) return const SizedBox();
                                          return Text(_daftarTajwid[value.toInt() - 1]);
                                        },
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final idx = value.toInt();
                                          if (idx < 0 || idx >= top5.length) return const SizedBox();
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(top5[idx].key, style: const TextStyle(fontSize: 10), overflow: TextOverflow.ellipsis),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(show: true, horizontalInterval: 1),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(top5.length, (i) {
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: top5[i].value,
                                          color: Colors.green,
                                          width: 22,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: top5.map((entry) {
                                return Card(
                                  child: ListTile(
                                    title: Text(entry.key),
                                    subtitle: LinearProgressIndicator(
                                      value: entry.value / 4.0,
                                      minHeight: 12,
                                      backgroundColor: Colors.grey[300],
                                      color: Colors.green,
                                    ),
                                    trailing: Text(entry.value.toStringAsFixed(2)),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
} 