import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../api_config.dart';

class KemajuanHafalanScreen extends StatefulWidget {
  final String kodeSantri;
  const KemajuanHafalanScreen({super.key, required this.kodeSantri});

  @override
  State<KemajuanHafalanScreen> createState() => _KemajuanHafalanScreenState();
}

class _KemajuanHafalanScreenState extends State<KemajuanHafalanScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _penilaian = [];
  Map<String, double> _rataRataNilai = {}; // Ubah untuk menyimpan rata-rata nilai akhir
  
  // Filter states
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedSurat;
  String? _selectedStatus;
  String? _selectedSortBy;
  
  // Data for dropdowns
  List<String> _suratList = [];
  List<String> _statusList = ['Semua', 'LULUS', 'TIDAK LULUS'];
  List<String> _sortOptions = ['Tanggal Terbaru', 'Tanggal Terlama', 'Nilai Tertinggi', 'Nilai Terendah'];
  
  // Filter results
  List<dynamic> _filteredData = [];
  bool _showFilter = false; // Toggle untuk menampilkan/menyembunyikan filter

  @override
  void initState() {
    super.initState();
    _fetchPenilaian();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data setiap kali halaman dibuka
    _fetchPenilaian();
  }

  Future<void> _fetchPenilaian() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final apiUrl = '${ApiConfig.baseUrl}/api/santri/${widget.kodeSantri}/penilaian';
    
    print('=== Fetch Penilaian ===');
    print('Kode Santri: ${widget.kodeSantri}');
    print('API URL: $apiUrl');
    print('Base URL: ${ApiConfig.baseUrl}');
    
    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded data: $data');
        if (!mounted) return;
        setState(() {
          _penilaian = data;
          _hitungRataRata();
          _loadDefaultFilters();
          _fetchSuratList();
          _isLoading = false;
        });
      } else {
        print('Error response: ${response.body}');
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Gagal memuat data penilaian (status: ${response.statusCode}): ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error in _fetchPenilaian: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchSuratList() async {
    try {
      final suratSet = <String>{};
      
      for (var item in _penilaian) {
        if (item['surat'] != null) {
          suratSet.add(item['surat']);
        }
      }
      
      setState(() {
        _suratList = ['Semua', ...suratSet.toList()..sort()];
      });
    } catch (e) {
      print('Error fetching surat list: $e');
    }
  }

  void _hitungRataRata() {
    Map<String, List<double>> temp = {};
    for (var p in _penilaian) {
      final surat = p['surat'];
      // Gunakan nilai akhir (hasil_naive_bayes) bukan tajwid
      final nilai = double.tryParse(p['hasil_naive_bayes']?.toString() ?? '0') ?? 0;
      temp.putIfAbsent(surat, () => []).add(nilai);
    }
    _rataRataNilai = {
      for (var entry in temp.entries)
        entry.key: entry.value.isNotEmpty ? entry.value.reduce((a, b) => a + b) / entry.value.length : 0
    };
  }

  void _loadDefaultFilters() {
    setState(() {
      _selectedSurat = 'Semua';
      _selectedStatus = 'Semua';
      _selectedSortBy = 'Tanggal Terbaru';
      _startDate = DateTime.now().subtract(const Duration(days: 30));
      _endDate = DateTime.now();
    });
  }

  Future<void> _applyFilters() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> filtered = _penilaian;

      // Apply date filter
      if (_startDate != null && _endDate != null) {
        filtered = filtered.where((item) {
          if (item['tanggal_penilaian'] == null) return false;
          final itemDate = DateTime.parse(item['tanggal_penilaian']);
          return itemDate.isAfter(_startDate!.subtract(const Duration(days: 1))) &&
                 itemDate.isBefore(_endDate!.add(const Duration(days: 1)));
        }).toList();
      }

      // Apply surat filter
      if (_selectedSurat != null && _selectedSurat != 'Semua') {
        filtered = filtered.where((item) => item['surat'] == _selectedSurat).toList();
      }

      // Apply status filter
      if (_selectedStatus != null && _selectedStatus != 'Semua') {
        filtered = filtered.where((item) {
          final nilai = int.tryParse(item['hasil_naive_bayes']?.toString() ?? '0') ?? 0;
          final isLulus = nilai >= 75;
          return (_selectedStatus == 'LULUS' && isLulus) || 
                 (_selectedStatus == 'TIDAK LULUS' && !isLulus);
        }).toList();
      }

      // Apply sorting
      switch (_selectedSortBy) {
        case 'Tanggal Terbaru':
          filtered.sort((a, b) => DateTime.parse(b['tanggal_penilaian'] ?? '1970-01-01')
              .compareTo(DateTime.parse(a['tanggal_penilaian'] ?? '1970-01-01')));
          break;
        case 'Tanggal Terlama':
          filtered.sort((a, b) => DateTime.parse(a['tanggal_penilaian'] ?? '1970-01-01')
              .compareTo(DateTime.parse(b['tanggal_penilaian'] ?? '1970-01-01')));
          break;
        case 'Nilai Tertinggi':
          filtered.sort((a, b) {
            final nilaiA = int.tryParse(a['hasil_naive_bayes']?.toString() ?? '0') ?? 0;
            final nilaiB = int.tryParse(b['hasil_naive_bayes']?.toString() ?? '0') ?? 0;
            return nilaiB.compareTo(nilaiA);
          });
          break;
        case 'Nilai Terendah':
          filtered.sort((a, b) {
            final nilaiA = int.tryParse(a['hasil_naive_bayes']?.toString() ?? '0') ?? 0;
            final nilaiB = int.tryParse(b['hasil_naive_bayes']?.toString() ?? '0') ?? 0;
            return nilaiA.compareTo(nilaiB);
          });
          break;
      }

      setState(() {
        _filteredData = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isLulus(dynamic hasilPrediksi) {
    // KKM = 75
    const kkm = 75;
    try {
      // Jika hasil prediksi adalah string numerik, konversi ke int
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
    final sortedRataRata = _rataRataNilai.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sortedRataRata.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kemajuan Hafalan'),
        backgroundColor: const Color.fromARGB(255, 26, 144, 11),
        actions: [
          IconButton(
            icon: Icon(_showFilter ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilter = !_showFilter;
                if (_showFilter) {
                  _applyFilters();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPenilaian,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _rataRataNilai.isEmpty
                  ? const Center(child: Text('Belum ada data penilaian.'))
                                     : Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: SingleChildScrollView(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.stretch,
                           children: [
                             // Filter Section (Collapsible)
                             if (_showFilter) _buildFilterSection(),
                             
                             const Text(
                               'Rata-rata Nilai Akhir per Surat (Top 5)',
                               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                               textAlign: TextAlign.center,
                             ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 250,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: 100,
                                  minY: 0,
                                  barTouchData: BarTouchData(enabled: true),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 10,
                                        getTitlesWidget: (value, meta) {
                                          return Text(value.toInt().toString());
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
                                  gridData: FlGridData(show: true, horizontalInterval: 10),
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
                                      value: entry.value / 100.0,
                                      minHeight: 12,
                                      backgroundColor: Colors.grey[300],
                                      color: Colors.green,
                                    ),
                                    trailing: Text(entry.value.toStringAsFixed(2)),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Riwayat Penilaian Terbaru',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _penilaian.take(5).length,
                              itemBuilder: (context, index) {
                                final penilaian = _penilaian[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${penilaian['surat']} (Ayat ${penilaian['dari_ayat']}-${penilaian['sampai_ayat']})',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('Tanggal: ${penilaian['tanggal_penilaian'] != null ? penilaian['tanggal_penilaian'].split('T')[0] : 'N/A'}'),
                                        Row(
                                          children: [
                                            Text('Hasil: ${penilaian['hasil_naive_bayes']}'),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _isLulus(penilaian['hasil_naive_bayes']) ? Colors.green[100] : Colors.red[100],
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: _isLulus(penilaian['hasil_naive_bayes']) ? Colors.green : Colors.red,
                                                ),
                                              ),
                                              child: Text(
                                                _isLulus(penilaian['hasil_naive_bayes']) ? 'LULUS' : 'TIDAK LULUS',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: _isLulus(penilaian['hasil_naive_bayes']) ? Colors.green[800] : Colors.red[800],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (penilaian['catatan'] != null && penilaian['catatan'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Catatan: ${penilaian['catatan']}',
                                            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.orange),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                                                         ),
                           ],
                         ),
                       ),
                     ),
     );
   }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Filter & Sort',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _loadDefaultFilters();
                    _applyFilters();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date Range
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dari Tanggal'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _startDate = date;
                            });
                            _applyFilters();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(_startDate?.toString().split(' ')[0] ?? 'Pilih Tanggal'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sampai Tanggal'),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _endDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                            _applyFilters();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(_endDate?.toString().split(' ')[0] ?? 'Pilih Tanggal'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Surat Filter
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Surat'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSurat,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _suratList.map((surat) {
                    return DropdownMenuItem(
                      value: surat,
                      child: Text(surat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSurat = value;
                    });
                    _applyFilters();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Status Filter
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _statusList.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Urutkan'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedSortBy,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSortBy = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Results Header
            Row(
              children: [
                const Icon(Icons.list, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Hasil Filter (${_filteredData.length} data)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Filtered Results List
            if (_filteredData.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredData.length,
                itemBuilder: (context, index) {
                  final item = _filteredData[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _isLulus(item['hasil_naive_bayes']) 
                            ? Colors.green[100] 
                            : Colors.red[100],
                        child: Icon(
                          Icons.assessment,
                          color: _isLulus(item['hasil_naive_bayes']) 
                              ? Colors.green 
                              : Colors.red,
                        ),
                      ),
                      title: Text('${item['surat']} (Ayat ${item['dari_ayat']}-${item['sampai_ayat']})'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nilai: ${item['hasil_naive_bayes']} - ${_isLulus(item['hasil_naive_bayes']) ? 'LULUS' : 'TIDAK LULUS'}'),
                          if (item['catatan'] != null && item['catatan'].toString().isNotEmpty)
                            Text('Catatan: ${item['catatan']}'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['tanggal_penilaian'] ?? '-',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isLulus(item['hasil_naive_bayes']) 
                                  ? Colors.green[100] 
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isLulus(item['hasil_naive_bayes']) 
                                    ? Colors.green 
                                    : Colors.red,
                              ),
                            ),
                            child: Text(
                              _isLulus(item['hasil_naive_bayes']) ? 'LULUS' : 'TIDAK LULUS',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _isLulus(item['hasil_naive_bayes']) 
                                    ? Colors.green[800] 
                                    : Colors.red[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Tidak ada data yang sesuai dengan filter',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 