import 'package:flutter/material.dart';

class DataLaporan extends StatelessWidget {
  const DataLaporan({super.key});

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Data Laporan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildReportCard("Makanan Baik...."),
            _buildReportCard("Makanan Baik...."),
            _buildReportCard("Makanan Diantar"),
            _buildReportCard("Makanan Baik...."),
            _buildReportCard("Makanan Baik...."),
          ],
        ),
      ),
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Cari...',
        prefixIcon: Icon(Icons.search),
        filled: true,
        fillColor: Colors.brown[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildReportCard(String title) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.brown)),
        tileColor: Colors.white,
      ),
    );
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.orange,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: ''),
      ],
    );
  }
}
