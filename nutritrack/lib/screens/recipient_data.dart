import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RecipientDataPage extends StatefulWidget {
  const RecipientDataPage({super.key});

  @override
  State<RecipientDataPage> createState() => _RecipientDataPageState();
}

class _RecipientDataPageState extends State<RecipientDataPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsersWithRoles();
  }

  Future<void> _loadUsersWithRoles() async {
    try {
      // Mendapatkan semua user dari Realtime Database yang memiliki role sekolah atau distributor
      final snapshot = await _dbRef.child('users').once();
      
      if (snapshot.snapshot.value != null) {
        final Map<dynamic, dynamic> usersMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final List<Map<String, dynamic>> filteredUsers = [];
        
        usersMap.forEach((key, value) {
          final userData = Map<String, dynamic>.from(value);
          if (userData['role'] == 'sekolah' || userData['role'] == 'distributor') {
            filteredUsers.add({
              'id': key,
              ...userData,
            });
          }
        });

        setState(() {
          _users = filteredUsers;
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
          SnackBar(content: Text('Failed to load data: ${e.toString()}')),
        );
      }
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
            const Text(
              "Data Penerima",
              style: TextStyle(color: Colors.brown),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No recipient data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Card(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(
                                label: Text(
                                  'No',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Nama',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Role',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Alamat',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                            rows: _users.asMap().entries.map((entry) {
                              final index = entry.key + 1;
                              final user = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text(index.toString())),
                                  DataCell(Text(user['nama']?.toString() ?? 'N/A')),
                                  DataCell(Text(user['email']?.toString() ?? 'N/A')),
                                  DataCell(Text(
                                    user['role']?.toString().toUpperCase() ?? 'N/A',
                                    style: TextStyle(
                                      color: user['role'] == 'sekolah' 
                                          ? Colors.blue 
                                          : Colors.green,
                                    ),
                                  )),
                                  DataCell(Text(user['alamat']?.toString() ?? 'N/A')),
                                  DataCell(
                                    Chip(
                                      label: Text(
                                        user['status']?.toString().toUpperCase() ?? 'N/A',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: user['status'] == 'active'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}