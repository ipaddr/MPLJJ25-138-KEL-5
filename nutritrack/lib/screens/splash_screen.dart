import 'package:flutter/material.dart';
import 'login_screen.dart'; // Ganti sesuai lokasi file login kamu

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFDF3E4,
      ), // warna latar belakang yang sama
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Spacer(),
          Center(child: Image.asset('assets/logo.png', height: 120)),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              '© 2025 NutriTrack by YourName', // Ganti dengan nama kamu / tim
              style: TextStyle(color: Colors.brown, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
