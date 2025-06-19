import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DistribusiDataPelaporan extends StatefulWidget {
  const DistribusiDataPelaporan({super.key});

  @override
  State<DistribusiDataPelaporan> createState() =>
      _DistribusiDataPelaporanState();
}

class _DistribusiDataPelaporanState extends State<DistribusiDataPelaporan> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();

  String? _selectedSchoolId;
  Map<String, String> _schools = {};
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      await _fetchSchools();
    } catch (e) {
      _showError('Gagal memulai aplikasi: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSchools() async {
    try {
      final snapshot =
          await _databaseRef
              .child('users')
              .orderByChild('role')
              .equalTo('sekolah')
              .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final Map<String, String> schools = {};

        data.forEach((key, value) {
          if (value['status'] == 'active' && value['nama'] != null) {
            schools[key] = value['nama'].toString();
          }
        });

        setState(() => _schools = schools);
      }
    } catch (e) {
      _showError('Gagal memuat sekolah: ${e.toString()}');
    }
  }

  Future<void> _submitData() async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      final distribusiData = {
        'sekolah_id': _selectedSchoolId,
        'sekolah_nama': _schools[_selectedSchoolId],
        'jumlah': _jumlahController.text,
        'tanggal': _tanggalController.text,
        'keterangan': _keteranganController.text,
        'created_at': ServerValue.timestamp,
        'created_by': _auth.currentUser?.uid,
      };

      final newKey = _databaseRef.child('distribusi').push().key;
      await _databaseRef.child('distribusi/$newKey').set(distribusiData);

      _showSuccess('Data distribusi berhasil disimpan!');
      _resetForm();
    } catch (e) {
      _showError('Gagal menyimpan data: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  bool _validateForm() {
    if (_selectedSchoolId == null) {
      _showError('Harap pilih sekolah');
      return false;
    }
    if (_jumlahController.text.isEmpty) {
      _showError('Harap isi jumlah');
      return false;
    }
    if (_tanggalController.text.isEmpty) {
      _showError('Harap pilih tanggal');
      return false;
    }
    return true;
  }

  void _resetForm() {
    _jumlahController.clear();
    _tanggalController.clear();
    _keteranganController.clear();
    setState(() => _selectedSchoolId = null);
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _tanggalController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _tanggalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3E4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF3E4),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 8),
            const Text(
              "Laporan Distributor",
              style: TextStyle(color: Colors.brown),
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Form Pelaporan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSchoolDropdown(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Jumlah Makanan',
                          hint: 'Masukkan jumlah makanan',
                          controller: _jumlahController,
                          keyboardType: TextInputType.number,
                          icon: Icons.fastfood,
                        ),
                        const SizedBox(height: 16),
                        _buildDateField(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Keterangan (Opsional)',
                          hint: 'Masukkan catatan tambahan',
                          controller: _keteranganController,
                          icon: Icons.note_alt_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildSchoolDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Sekolah Tujuan',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.school),
      ),
      value: _selectedSchoolId,
      hint: const Text('Pilih sekolah'),
      items:
          _schools.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
      onChanged: (value) => setState(() => _selectedSchoolId = value),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _tanggalController,
      readOnly: true,
      onTap: () => _selectDate(context),
      decoration: const InputDecoration(
        labelText: 'Tanggal Distribusi',
        hintText: 'Pilih tanggal',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _submitData,
      icon: const Icon(Icons.send),
      label:
          _isSubmitting
              ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
              : const Text('KIRIM'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFF05E23),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
