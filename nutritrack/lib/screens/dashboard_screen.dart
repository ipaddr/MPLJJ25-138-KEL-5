import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final dbRef = FirebaseDatabase.instance.ref();
  DateTime selectedDate = DateTime.now();
  int totalDikirim = 0;
  int totalDiterima = 0;

  @override
  void initState() {
    super.initState();
    _fetchDataForDate(selectedDate);
  }

  void _fetchDataForDate(DateTime date) async {
    String tanggal = DateFormat('dd/MM/yyyy').format(date);

    final distribusiSnap = await dbRef.child('distribusi').get();
    final feedbackSnap = await dbRef.child('feedback').get();

    int dikirim = 0;
    int diterima = 0;

    if (distribusiSnap.exists) {
      final data = distribusiSnap.value as Map;
      data.forEach((key, value) {
        if (value['tanggal'] == tanggal) {
          dikirim += int.tryParse(value['jumlah'].toString()) ?? 0;
        }
      });
    }

    if (feedbackSnap.exists) {
      final data = feedbackSnap.value as Map;
      data.forEach((key, value) {
        if (value['date'] == DateFormat('yyyy-MM-dd').format(date)) {
          diterima += int.tryParse(value['foodQuantity'].toString()) ?? 0;
        }
      });
    }

    setState(() {
      totalDikirim = dikirim;
      totalDiterima = diterima;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _fetchDataForDate(picked);
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
            Text(
              'Dashboard Sekolah',
              style: TextStyle(
                color: Colors.orange[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.orange),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              "Data tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate)}",
              style: const TextStyle(color: Colors.brown, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statCard("Dikirim", totalDikirim),
                _statCard("Diterima", totalDiterima),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Statistik Distribusi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (totalDikirim > totalDiterima ? totalDikirim : totalDiterima).toDouble() + 100,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(toY: totalDikirim.toDouble(), color: Colors.orange),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(toY: totalDiterima.toDouble(), color: Colors.green),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          switch (value.toInt()) {
                            case 0:
                              return const Text('Dikirim');
                            case 1:
                              return const Text('Diterima');
                            default:
                              return const Text('');
                          }
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, int value) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
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
            value.toString(),
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
