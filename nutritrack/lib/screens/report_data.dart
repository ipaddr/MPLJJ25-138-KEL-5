import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class ReportDataPage extends StatefulWidget {
  const ReportDataPage({super.key});

  @override
  State<ReportDataPage> createState() => _ReportDataPageState();
}

class _ReportDataPageState extends State<ReportDataPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('feedback');
  List<Map<dynamic, dynamic>> _feedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedbackData();
  }

  Future<void> _loadFeedbackData() async {
    try {
      DatabaseEvent event = await _databaseRef.once();
      DataSnapshot snapshot = event.snapshot;
      
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        List<Map<dynamic, dynamic>> feedbackList = [];
        
        values.forEach((key, value) {
          feedbackList.add({
            'id': key,
            ...value,
          });
        });

        // Sort by timestamp descending (newest first)
        feedbackList.sort((a, b) => (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0));
        
        setState(() {
          _feedbacks = feedbackList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40, width: 40),
            const SizedBox(width: 10),
            const Text('Data Laporan'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedbacks.isEmpty
              ? const Center(child: Text('Belum ada laporan feedback'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Data Laporan Feedback',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ..._feedbacks.map((feedback) => 
                                _buildFeedbackItem(context, feedback)
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

  Widget _buildFeedbackItem(BuildContext context, Map<dynamic, dynamic> feedback) {
    bool isPositive = feedback['rating'] >= 3;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(feedback['timestamp'] ?? DateTime.now().millisecondsSinceEpoch);
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        leading: Icon(
          isPositive ? Icons.check_circle : Icons.warning,
          color: isPositive ? Colors.green : Colors.orange,
        ),
        title: Text(
          'Feedback ${isPositive ? 'Positif' : 'Negatif'}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green : Colors.orange,
          ),
        ),
        subtitle: Text(formattedDate),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeedbackDetailRow('Rating', '${feedback['rating']}/5'),
                _buildFeedbackDetailRow('Jumlah Makanan', '${feedback['foodQuantity']} porsi'),
                _buildFeedbackDetailRow('Kualitas', feedback['foodQuality'] ?? '-'),
                _buildFeedbackDetailRow('Tanggal', feedback['date'] ?? '-'),
                _buildFeedbackDetailRow('Waktu', feedback['time'] ?? '-'),
                const SizedBox(height: 12),
                Text(
                  'Deskripsi:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feedback['description'] ?? 'Tidak ada deskripsi',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}