import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class DistributorDashboardPage extends StatefulWidget {
  const DistributorDashboardPage({super.key});

  @override
  State<DistributorDashboardPage> createState() => _DistributorDashboardPageState();
}

class _DistributorDashboardPageState extends State<DistributorDashboardPage> {
  final _auth = FirebaseAuth.instance;
  final _dbDistribusi = FirebaseDatabase.instance.ref().child('distribusi');

  int jumlahDikirim = 0;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchDataForDate(selectedDate);
  }

  void _fetchDataForDate(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _dbDistribusi.once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    int totalDikirim = 0;

    if (data != null) {
      data.forEach((key, value) {
        final distribusi = Map<String, dynamic>.from(value);
        if (distribusi['created_by'] == user.uid &&
            distribusi['tanggal'] == DateFormat('dd/MM/yyyy').format(date)) {
          final jumlahStr = distribusi['jumlah'] ?? '0';
          totalDikirim += int.tryParse(jumlahStr.toString()) ?? 0;
        }
      });
    }

    setState(() {
      jumlahDikirim = totalDikirim;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _fetchDataForDate(picked);
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
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 8),
            const Text('Distributor Dashboard',
                style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.orange),
            onPressed: () => _selectDate(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Distribusi pada: ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
              style: const TextStyle(fontSize: 16, color: Colors.brown),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statCard("Dikirim", jumlahDikirim.toString()),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildBarChart()),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.brown,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.brown,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            return const Text('Jumlah');
          })),
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: jumlahDikirim.toDouble(),
                color: Colors.orange,
                width: 30,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
