import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Selamat Datang di NutriTrack'));
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
    if (picked != null && picked != selectedDate) {
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
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: groupValue == text ? Colors.orange[700] : Colors.white,
        foregroundColor: groupValue == text ? Colors.white : Colors.black,
      ),
      onPressed: () => onChanged(text),
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Jumlah Makanan:"),
          TextField(
            controller: jumlahController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          Text("Kualitas Makanan:"),
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
          Text("Waktu:"),
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
          Text("Tanggal:"),
          TextField(
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText:
                  selectedDate == null
                      ? 'mm/dd/yy'
                      : '${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}',
            ),
          ),
          const SizedBox(height: 10),
          Text("Deskripsi:"),
          TextField(
            controller: deskripsiController,
            maxLines: 5,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          const Text("Rating:"),
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
                // TODO: Simpan data pelaporan
                print("Jumlah: ${jumlahController.text}");
                print("Kualitas: $kualitasMakanan");
                print("Waktu: $waktu");
                print("Tanggal: $selectedDate");
                print("Deskripsi: ${deskripsiController.text}");
                print("Rating: $rating");
              },
              child: const Text("Kirim"),
            ),
          ),
        ],
      ),
    );
  }
}

class DataPenerimaPage extends StatelessWidget {
  const DataPenerimaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Daftar Data Penerima Makanan'));
  }
}

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Profil Pengguna & Pengaturan'));
  }
}
