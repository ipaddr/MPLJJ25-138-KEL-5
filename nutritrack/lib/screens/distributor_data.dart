import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DistributorDataPage extends StatefulWidget {
  const DistributorDataPage({super.key});

  @override
  State<DistributorDataPage> createState() => _DistributorDataPageState();
}

class _DistributorDataPageState extends State<DistributorDataPage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('distribusi');
  List<Map<dynamic, dynamic>> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDistribusiData();
  }

  Future<void> _fetchDistribusiData() async {
    try {
      final snapshot = await _dbRef.orderByChild('created_at').get();
      if (snapshot.exists) {
        final dataList = <Map<dynamic, dynamic>>[];
        final rawData = snapshot.value as Map<dynamic, dynamic>;
        rawData.forEach((key, value) {
          final item = Map<String, dynamic>.from(value);
          item['key'] = key; // Tambahkan ID untuk keperluan update/hapus
          dataList.add(item);
        });
        setState(() {
          _data = dataList.reversed.toList(); // Terbaru di atas
          _loading = false;
        });
      } else {
        setState(() {
          _data = [];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data: $e")),
      );
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
            const Text("Distributor Data", style: TextStyle(color: Colors.brown)),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFFDF3E4),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data.isEmpty
              ? const Center(child: Text("Belum ada data distribusi."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _data.length,
                  itemBuilder: (context, index) {
                    final item = _data[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          item['sekolah_nama'] ?? 'Sekolah Tidak Diketahui',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text("Jumlah: ${item['jumlah'] ?? '-'}"),
                            Text("Tanggal: ${item['tanggal'] ?? '-'}"),
                            if ((item['keterangan'] ?? '').toString().isNotEmpty)
                              Text("Keterangan: ${item['keterangan']}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
