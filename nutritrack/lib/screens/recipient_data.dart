import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecipientDataPage extends StatefulWidget {
  const RecipientDataPage({super.key});

  @override
  State<RecipientDataPage> createState() => _RecipientDataPageState();
}

class _RecipientDataPageState extends State<RecipientDataPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<User> _users = []; // Changed from UserInfo to User
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthUsers();
  }

  Future<void> _loadAuthUsers() async {
    try {
      // In a real app, you would use Admin SDK or Cloud Function to get all users
      // This example only shows the current user
      User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        setState(() {
          _users = [currentUser];
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
      appBar: AppBar(title: const Text('Recipient Data')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text('No recipient data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NutriTrack',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Recipient Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
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
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Provider',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Verified',
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
                                  DataCell(Text(user.email ?? 'N/A')),
                                  DataCell(Text(
                                    user.providerData
                                        .map((info) => info.providerId)
                                        .join(', '),
                                  )),
                                  DataCell(Icon(
                                    user.emailVerified
                                        ? Icons.verified
                                        : Icons.warning,
                                    color: user.emailVerified
                                        ? Colors.green
                                        : Colors.orange,
                                  )),
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