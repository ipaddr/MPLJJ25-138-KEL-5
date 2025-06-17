import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class PelaporanDistribusi extends StatefulWidget {
  const PelaporanDistribusi({super.key});

  @override
  State<PelaporanDistribusi> createState() => _PelaporanDistribusiState();
}

class _PelaporanDistribusiState extends State<PelaporanDistribusi> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  String? _selectedSchoolId;
  Map<String, String> _schools = {};
  bool _isLoadingSchools = true;

  @override
  void initState() {
    super.initState();
    _fetchSchools();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _fetchSchools() async {
    try {
      final snapshot = await _databaseRef.child('users').get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;
        final Map<String, String> schools = {};
        
        users.forEach((key, value) {
          if (value['role'] == 'sekolah' && value['status'] == 'active') {
            schools[key] = value['nama'] ?? 'Nama tidak tersedia';
          }
        });

        setState(() {
          _schools = schools;
          _isLoadingSchools = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSchools = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar sekolah: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitData() async {
    try {
      if (_jumlahController.text.isEmpty ||
          _tanggalController.text.isEmpty ||
          _selectedSchoolId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field harus diisi')),
        );
        return;
      }

      final schoolName = _schools[_selectedSchoolId] ?? '';

      final newReportKey = _databaseRef.child('distribusi').push().key;

      final reportData = {
        'jumlah_makanan': _jumlahController.text,
        'tanggal': _tanggalController.text,
        'sekolah_id': _selectedSchoolId,
        'sekolah_nama': schoolName,
        'timestamp': ServerValue.timestamp,
      };

      await _databaseRef.child('distribusi/$newReportKey').set(reportData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim!')),
      );

      _jumlahController.clear();
      _tanggalController.clear();
      setState(() {
        _selectedSchoolId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('MM/dd/yy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF3E4),
        elevation: 0,
        title: Row(children: [Image.asset('assets/logo.png', height: 40)]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.person, color: Colors.orange[800]),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Pelaporan Distribusi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Jumlah Makanan :", style: TextStyle(color: Colors.brown)),
                const SizedBox(height: 4),
                TextField(
                  controller: _jumlahController,
                  decoration: const InputDecoration(
                    hintText: "Masukkan jumlah",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tanggal :", style: TextStyle(color: Colors.brown)),
                const SizedBox(height: 4),
                TextField(
                  controller: _tanggalController,
                  decoration: const InputDecoration(
                    hintText: "mm/dd/yy",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 12),
              ],
            ),
            _schoolDropdown(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF05E23),
                elevation: 4,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text("Kirim"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _schoolDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nama Sekolah :",
          style: TextStyle(color: Colors.brown),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: _isLoadingSchools
                  ? const Text('Memuat daftar sekolah...')
                  : const Text('Pilih sekolah'),
              value: _selectedSchoolId,
              items: _schools.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSchoolId = newValue;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}