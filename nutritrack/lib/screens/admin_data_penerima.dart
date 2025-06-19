import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DataPenerima extends StatefulWidget {
  const DataPenerima({super.key});

  @override
  State<DataPenerima> createState() => _DataPenerimaState();
}

class _DataPenerimaState extends State<DataPenerima> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users");
  List<Map<String, dynamic>> _userList = [];
  List<Map<String, dynamic>> _filteredUserList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchUsers() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      List<Map<String, dynamic>> loadedUsers = [];
      final users = snapshot.value as Map<dynamic, dynamic>;
      users.forEach((key, value) {
        final user = Map<String, dynamic>.from(value);
        if (user['role'] == 'sekolah' || user['role'] == 'distributor') {
          loadedUsers.add({...user, 'key': key});
        }
      });
      setState(() {
        _userList = loadedUsers;
        _filteredUserList = loadedUsers;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUserList = _userList
          .where((user) =>
              user['nama'].toString().toLowerCase().contains(query) ||
              user['alamat'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  void _deleteUser(String key) async {
    await _dbRef.child(key).remove();
    _fetchUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data berhasil dihapus"), backgroundColor: Colors.red),
    );
  }

  void _editUser(Map<String, dynamic> user) async {
    final nameController = TextEditingController(text: user['nama']);
    final addressController = TextEditingController(text: user['alamat']);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nama")),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "Alamat")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await _dbRef.child(user['key']).update({
                'nama': nameController.text,
                'alamat': addressController.text,
              });
              Navigator.pop(context);
              _fetchUsers();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data diperbarui"), backgroundColor: Colors.green),
              );
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTableHeader(),
            const SizedBox(height: 8),
            Expanded(child: _buildUserTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cari sekolah/distributor...',
        prefixIcon: const Icon(Icons.search),
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
        3: FlexColumnWidth(3),
      },
      children: const [
        TableRow(
          decoration: BoxDecoration(color: Colors.orange),
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text("No", style: TextStyle(color: Colors.white))),
            Padding(padding: EdgeInsets.all(8), child: Text("Nama", style: TextStyle(color: Colors.white))),
            Padding(padding: EdgeInsets.all(8), child: Text("Alamat", style: TextStyle(color: Colors.white))),
            Padding(padding: EdgeInsets.all(8), child: Text("Aksi", style: TextStyle(color: Colors.white))),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTable() {
    return ListView.builder(
      itemCount: _filteredUserList.length,
      itemBuilder: (context, index) {
        final user = _filteredUserList[index];
        return Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(4),
            3: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              children: [
                Padding(padding: const EdgeInsets.all(8), child: Text('${index + 1}')),
                Padding(padding: const EdgeInsets.all(8), child: Text(user['nama'] ?? '-')),
                Padding(padding: const EdgeInsets.all(8), child: Text(user['alamat'] ?? '-')),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editUser(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user['key']),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
