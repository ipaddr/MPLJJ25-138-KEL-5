import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ReportFeedbackPage extends StatefulWidget {
  const ReportFeedbackPage({super.key});

  @override
  State<ReportFeedbackPage> createState() => _ReportFeedbackPageState();
}

class _ReportFeedbackPageState extends State<ReportFeedbackPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('feedback');
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _foodQualityController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  int _rating = 0;
  int _foodQuantity = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _timeController.text = DateFormat('HH:mm').format(DateTime.now());
    _quantityController.text = _foodQuantity.toString();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _foodQualityController.dispose();
    _timeController.dispose();
    _dateController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_rating == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap berikan rating')),
      );
      return;
    }

    // Validate food quantity
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah makanan harus angka positif')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final newFeedbackRef = _databaseRef.push();
      await newFeedbackRef.set({
        'rating': _rating,
        'foodQuantity': quantity,
        'foodQuality': _foodQualityController.text,
        'time': _timeController.text,
        'date': _dateController.text,
        'description': _descriptionController.text,
        'timestamp': ServerValue.timestamp,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback berhasil dikirim!')),
      );

      // Reset form
      setState(() {
        _rating = 0;
        _foodQuantity = 1;
        _quantityController.text = '1';
      });
      _descriptionController.clear();
      _foodQualityController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF3E4),
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 8),
            const Text(
              "Laporan & Feedback",
              style: TextStyle(color: Colors.brown),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beri Penilaian Anda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Star Rating
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index + 1),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 40,
                      color: Colors.amber,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _rating == 0 ? 'Belum ada rating' : '$_rating bintang',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Divider(height: 40),

            // Food Quantity - Text Input
            const Text('Jumlah Makanan (porsi):'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Contoh: 5, 10, 100',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _foodQuantity = int.tryParse(value) ?? 1;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Food Quality
            const Text('Kualitas Makanan:'),
            TextFormField(
              controller: _foodQualityController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Baik, Cukup, Kurang',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Date and Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tanggal:'),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        onTap: _selectDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Waktu:'),
                      TextFormField(
                        controller: _timeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        onTap: _selectTime,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            const Text('Deskripsi:'),
            TextFormField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Masukkan feedback detail Anda...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Kirim Feedback',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}