import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class DataLaporan extends StatefulWidget {
  const DataLaporan({super.key});

  @override
  State<DataLaporan> createState() => _DataLaporanState();
}

class _DataLaporanState extends State<DataLaporan> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _feedbackList = [];
  List<Map<String, dynamic>> _distribusiList = [];
  String _searchQuery = '';
  String? _selectedDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final feedbackSnap = await _dbRef.child('feedback').once();
      final distribusiSnap = await _dbRef.child('distribusi').once();

      final feedbackRaw = feedbackSnap.snapshot.value as Map<dynamic, dynamic>?;
      final distribusiRaw = distribusiSnap.snapshot.value as Map<dynamic, dynamic>?;

      final feedbackList = feedbackRaw?.entries
          .where((e) => e.key.toString() != 'auto_generated_id_1')
          .map<Map<String, dynamic>>((e) {
            final value = Map<String, dynamic>.from(e.value);
            return {
              'id': e.key.toString(),
              ...value,
              'type': 'feedback',
            };
          })
          .toList() ?? [];

      final distribusiList = distribusiRaw?.entries
          .where((e) => e.key.toString() != 'auto_generated_id')
          .map<Map<String, dynamic>>((e) {
            final value = Map<String, dynamic>.from(e.value);
            return {
              'id': e.key.toString(),
              ...value,
              'type': 'distribusi',
            };
          })
          .toList() ?? [];

      setState(() {
        _feedbackList = feedbackList;
        _distribusiList = distribusiList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  List<Map<String, dynamic>> _getFilteredData() {
    final allData = [..._feedbackList, ..._distribusiList];
    
    return allData.where((item) {
      final date = item['type'] == 'feedback' ? item['date'] : item['tanggal'];
      final description = item['type'] == 'feedback' 
          ? item['description']?.toString().toLowerCase() ?? ''
          : item['keterangan']?.toString().toLowerCase() ?? '';
      
      // Convert dates to comparable format
      bool dateMatch = true;
      if (_selectedDate != null) {
        try {
          if (item['type'] == 'feedback') {
            final feedbackDate = DateFormat('yyyy-MM-dd').parse(item['date']);
            final selectedDate = DateFormat('dd/MM/yyyy').parse(_selectedDate!);
            dateMatch = DateFormat('yyyy-MM-dd').format(feedbackDate) == 
                       DateFormat('yyyy-MM-dd').format(selectedDate);
          } else {
            dateMatch = item['tanggal'] == _selectedDate;
          }
        } catch (e) {
          dateMatch = false;
        }
      }
      
      final searchMatch = _searchQuery.isEmpty || 
          description.contains(_searchQuery.toLowerCase());
      
      return dateMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = _getFilteredData();
    
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF3E4),
        elevation: 0,
        title: Row(children: [Image.asset('assets/logo.png', height: 40)]),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.orange),
            onPressed: _pickDate,
          ),
          if (_selectedDate != null) IconButton(
            icon: const Icon(Icons.clear, color: Colors.red),
            onPressed: () => setState(() => _selectedDate = null),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Data Laporan & Distribusi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari deskripsi...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.brown[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            if (_selectedDate != null) Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Menampilkan data untuk: $_selectedDate',
                style: const TextStyle(color: Colors.brown),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : filteredData.isEmpty
                      ? const Center(child: Text('Tidak ada data ditemukan'))
                      : ListView.builder(
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) {
                            final item = filteredData[index];
                            return item['type'] == 'feedback'
                                ? _buildFeedbackCard(item)
                                : _buildDistribusiCard(item);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchData,
        child: const Icon(Icons.refresh),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildFeedbackCard(Map<String, dynamic> data) {
    final rating = data['rating']?.toString() ?? '-';
    final quality = data['foodQuality']?.toString() ?? '-';
    final quantity = data['foodQuantity']?.toString() ?? '-';
    final time = data['time']?.toString() ?? '';
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _getFeedbackColor(data),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Feedback Makanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text('$rating/5', style: const TextStyle(color: Colors.white)),
                  backgroundColor: _getRatingColor(int.tryParse(rating) ?? 0),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              data['description'] ?? 'Tidak ada deskripsi',
              style: const TextStyle(color: Colors.brown),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDetailChip(Icons.fastfood, '$quantity porsi'),
                const SizedBox(width: 8),
                _buildDetailChip(Icons.star, quality),
                const Spacer(),
                Text(
                  '${data['date']} ${time.isNotEmpty ? '• $time' : ''}',
                  style: const TextStyle(color: Colors.brown, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistribusiCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribusi Makanan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown[800],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${data['jumlah']} porsi ke ${data['sekolah_nama']}',
              style: const TextStyle(color: Colors.brown),
            ),
            const SizedBox(height: 8),
            Text(
              data['keterangan'] ?? 'Tidak ada keterangan',
              style: const TextStyle(color: Colors.brown),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildDetailChip(Icons.location_on, data['sekolah_nama'] ?? '-'),
                const Spacer(),
                Text(
                  data['tanggal'] ?? '-',
                  style: const TextStyle(color: Colors.brown, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.orange),
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.orange[100],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return Colors.green;
    if (rating >= 3) return Colors.orange;
    return Colors.red;
  }

  Color _getFeedbackColor(Map<String, dynamic> data) {
    final rating = int.tryParse(data['rating']?.toString() ?? '0') ?? 0;
    final quality = data['foodQuality']?.toString().toLowerCase() ?? '';
    
    if (rating <= 2 || 
        quality.contains('tidak baik') || 
        quality.contains('kurang')) {
      return Colors.red[50]!;
    } else if (rating >= 4 || quality.contains('sangat baik')) {
      return Colors.green[50]!;
    }
    return Colors.orange[50]!;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2024),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
}