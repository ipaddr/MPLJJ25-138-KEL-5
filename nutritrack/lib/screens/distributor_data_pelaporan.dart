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
  Map<String, String> _schools = {}; // Stores schoolId: schoolName pairs
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
      // Validate inputs
      if (_jumlahController.text.isEmpty ||
          _tanggalController.text.isEmpty ||
          _selectedSchoolId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua field harus diisi')),
        );
        return;
      }

      // Get school name from selected ID
      final schoolName = _schools[_selectedSchoolId] ?? '';

      // Create a unique key for the new distribution report
      final newReportKey = _databaseRef.child('distribusi').push().key;

      // Prepare data to save
      final reportData = {
        'jumlah_makanan': _jumlahController.text,
        'tanggal': _tanggalController.text,
        'sekolah_id': _selectedSchoolId,
        'sekolah_nama': schoolName,
        'timestamp': ServerValue.timestamp,
      };

      // Save to Firebase
      await _databaseRef.child('distribusi/$newReportKey').set(reportData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim!')),
      );

      // Clear form
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
      appBar: _buildAppBar(),
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
            _inputField(
              label: "Jumlah Makanan :",
              hint: "Masukkan jumlah",
              controller: _jumlahController,
            ),
            _inputField(
              label: "Tanggal :",
              hint: "mm/dd/yy",
              controller: _tanggalController,
              isDateField: true,
              onTap: () => _selectDate(context),
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
      bottomNavigationBar: _bottomNavBar(0),
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

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFDF3E4),
      elevation: 0,
      title: Row(children: [Image.asset('assets/logo.png', height: 40)]),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(Icons.person, color: Colors.orange[800]),
        ),
      ],
    );
  }

  Widget _inputField({
    required String label,
    required String hint,
    TextEditingController? controller,
    bool isDateField = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.brown)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          readOnly: isDateField,
          onTap: onTap,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _bottomNavBar(int selectedIndex) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      backgroundColor: const Color(0xFFF05E23),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: ''),
      ],
    );
  }
}