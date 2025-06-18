import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DistribusiDataPelaporan extends StatefulWidget {
  const DistribusiDataPelaporan({super.key});

  @override
  State<DistribusiDataPelaporan> createState() => _DistribusiDataPelaporanState();
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
      // Pastikan user terautentikasi
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
      await _fetchSchools();
    } catch (e) {
      _showError('Gagal memulai aplikasi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchSchools() async {
    try {
      final snapshot = await _databaseRef.child('users')
        .orderByChild('role')
        .equalTo('sekolah')
        .get();

      if (snapshot.exists) {
        final Map<String, String> schools = {};
        final data = snapshot.value as Map<dynamic, dynamic>;
        
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
      setState(() {
        _tanggalController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Tutup',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
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
      appBar: AppBar(
        title: const Text('Pelaporan Distribusi'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSchoolDropdown(),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    label: 'Jumlah Makanan',
                    controller: _jumlahController,
                    hint: 'Masukkan jumlah',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Keterangan (Opsional)',
                    controller: _keteranganController,
                    hint: 'Masukkan keterangan tambahan',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildSchoolDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sekolah Tujuan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Pilih sekolah'),
              value: _selectedSchoolId,
              items: _schools.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSchoolId = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Distribusi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _tanggalController,
          decoration: const InputDecoration(
            hintText: 'Pilih tanggal',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _selectDate(context),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          maxLines: maxLines,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitData,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).primaryColor,
        disabledBackgroundColor: Colors.grey,
      ),
      child: _isSubmitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'SIMPAN DATA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}