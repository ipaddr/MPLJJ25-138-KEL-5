import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        backgroundColor: Colors.orange[700],
      ),
      body: const Center(
        child: Text(
          'Selamat Datang di NutriTrack',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class PelaporanPage extends StatefulWidget {
  const PelaporanPage({super.key});

  @override
  State<PelaporanPage> createState() => _PelaporanPageState();
}

class _PelaporanPageState extends State<PelaporanPage> {
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  DateTime? selectedDate;

  String kualitasMakanan = '';
  String waktu = '';
  String rating = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget buildButton(
    String text,
    String groupValue,
    Function(String) onChanged,
  ) {
    final isSelected = groupValue == text;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.orange[700] : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        side: const BorderSide(color: Colors.orange),
      ),
      onPressed: () => onChanged(text),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pelaporan'),
        backgroundColor: Colors.orange[700],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Jumlah Makanan:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan jumlah makanan',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Kualitas Makanan:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [
                  buildButton("Baik", kualitasMakanan, (val) {
                    setState(() => kualitasMakanan = val);
                  }),
                  buildButton("Buruk", kualitasMakanan, (val) {
                    setState(() => kualitasMakanan = val);
                  }),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Waktu:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [
                  buildButton("Tepat Waktu", waktu, (val) {
                    setState(() => waktu = val);
                  }),
                  buildButton("Terlambat", waktu, (val) {
                    setState(() => waktu = val);
                  }),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Tanggal:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText:
                      selectedDate == null
                          ? 'mm/dd/yyyy'
                          : '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Deskripsi:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: deskripsiController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tambahkan deskripsi tambahan...',
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Rating:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [
                  buildButton("Sangat Buruk", rating, (val) {
                    setState(() => rating = val);
                  }),
                  buildButton("Buruk", rating, (val) {
                    setState(() => rating = val);
                  }),
                  buildButton("Biasa", rating, (val) {
                    setState(() => rating = val);
                  }),
                  buildButton("Baik", rating, (val) {
                    setState(() => rating = val);
                  }),
                  buildButton("Sangat Baik", rating, (val) {
                    setState(() => rating = val);
                  }),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[800],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    // Contoh proses simpan data pelaporan
                    print("Jumlah: ${jumlahController.text}");
                    print("Kualitas: $kualitasMakanan");
                    print("Waktu: $waktu");
                    print("Tanggal: $selectedDate");
                    print("Deskripsi: ${deskripsiController.text}");
                    print("Rating: $rating");

                    // Tampilkan dialog atau snackbar setelah submit
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pelaporan berhasil dikirim'),
                      ),
                    );
                  },
                  child: const Text(
                    "Kirim",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataPenerimaPage extends StatelessWidget {
  const DataPenerimaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Penerima'),
        backgroundColor: Colors.orange[700],
      ),
      body: const Center(
        child: Text(
          'Daftar Data Penerima Makanan',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        backgroundColor: Colors.orange[700],
      ),
      body: const Center(
        child: Text(
          'Profil Pengguna & Pengaturan',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
