import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_config.dart';
import 'summary_hafalan_screen.dart';
import 'kemajuan_hafalan_screen.dart';

class FilterSortScreen extends StatefulWidget {
  final String kodeSantri;
  final String namaSantri;
  
  const FilterSortScreen({
    super.key, 
    required this.kodeSantri,
    required this.namaSantri,
  });

  @override
  State<FilterSortScreen> createState() => _FilterSortScreenState();
}

class _FilterSortScreenState extends State<FilterSortScreen> {
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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSuratList();
    _loadDefaultFilters();
  }

  Future<void> _fetchSuratList() async {
    try {
      final url = '${ApiConfig.baseUrl}/api/santri/${widget.kodeSantri}/penilaian';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suratSet = <String>{};
        
        for (var item in data) {
          if (item['surat'] != null) {
            suratSet.add(item['surat']);
          }
        }
        
        setState(() {
          _suratList = ['Semua', ...suratSet.toList()..sort()];
        });
        
        // Setelah data surat berhasil diambil, terapkan filter
        _applyFilters();
      }
    } catch (e) {
      print('Error fetching surat list: $e');
      // Tetap coba terapkan filter meskipun ada error
      _applyFilters();
    }
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
      _errorMessage = null;
    });

    try {
      final url = '${ApiConfig.baseUrl}/api/santri/${widget.kodeSantri}/penilaian';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> filtered = data;

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
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
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
        title: Text('Filter & Sort - ${widget.namaSantri}'),
        backgroundColor: const Color.fromARGB(255, 26, 144, 11),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _applyFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          _buildFilterSection(),
          
          // Results Section
          Expanded(
            child: _isLoading
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
                              onPressed: _applyFilters,
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      )
                    : _buildResultsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(16.0),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _loadDefaultFilters,
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
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.search),
                label: const Text('Terapkan Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Column(
      children: [
        // Results Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.list, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Hasil (${_filteredData.length} data)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_filteredData.isNotEmpty)
                TextButton.icon(
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
                  label: const Text('Lihat Summary'),
                ),
            ],
          ),
        ),
        
        // Results List
        Expanded(
          child: _filteredData.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Tidak ada data yang sesuai dengan filter',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredData.length,
                  itemBuilder: (context, index) {
                    final item = _filteredData[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                ),
        ),
      ],
    );
  }
} 