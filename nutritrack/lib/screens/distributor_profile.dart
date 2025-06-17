import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DistributorProfile extends StatefulWidget {
  const DistributorProfile({super.key});

  @override
  State<DistributorProfile> createState() => _DistributorProfileState();
}

class _DistributorProfileState extends State<DistributorProfile> {
  late DatabaseReference _userRef;
  Map<dynamic, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    try {
      DatabaseEvent event = await _userRef.once();
      if (mounted) {
        setState(() {
          userData = event.snapshot.value as Map<dynamic, dynamic>?;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF3E4),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null || userData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF3E4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Distributor data not found'),
              TextButton(
                onPressed: () => _signOut(context),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3E4),
      appBar: AppBar(
        title: const Text('Distributor Profile'),
        backgroundColor: Color(0xFFF05E23),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditProfile(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 80, color: Color(0xFFF05E23)),
              const SizedBox(height: 16),
              Text(
                userData!['nama'] ?? 'No Name',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              Text(
                userData!['email'] ?? 'No Email',
                style: const TextStyle(color: Color(0xFFF05E23)),
              ),
              const SizedBox(height: 20),
              _profileField(userData!['alamat'] ?? 'Address not set'),
              _profileField(userData!['noTelp'] ?? 'Phone not set'),
              _profileField('Role: ${userData!['role'] ?? 'Distributor'}'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _signOut(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF05E23),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Logout',
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

  Widget _profileField(String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(value, style: const TextStyle(color: Colors.grey)),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, '/edit-distributor-profile', arguments: userData);
  }
}