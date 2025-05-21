import 'package:flutter/material.dart';

class PelaporanDistribusi extends StatelessWidget {
  const PelaporanDistribusi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3E4),
      appBar: AppBar(),
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
            _inputField(label: "Jumlah Makanan :", hint: "Masukkan jumlah"),
            _inputField(label: "Tanggal :", hint: "mm/dd/yy"),
            _inputField(label: "Nama Sekolah :", hint: "Masukkan nama sekolah"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
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

  Widget _buildAppBar() {
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

  Widget _inputField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.brown)),
        const SizedBox(height: 4),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _bottomNavBar(int selectedIndex) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      backgroundColor: Colors.orange,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: ''),
      ],
    );
  }
}
