import 'package:flutter/material.dart';

class DataPenerima extends StatelessWidget {
  const DataPenerima({super.key});

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
              "Data Penerima",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTableHeader(),
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

  Widget _buildTableHeader() {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(4),
      },
      children: const [
        TableRow(
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text("No")),
            Padding(padding: EdgeInsets.all(8), child: Text("Nama Sekolah")),
            Padding(padding: EdgeInsets.all(8), child: Text("Alamat")),
          ],
        ),
      ],
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
