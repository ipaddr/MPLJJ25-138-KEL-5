import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    appId: "1:1234567890:android:abc123def456",
    messagingSenderId: "1234567890",
    projectId: "nutritrack-app-89707",
    storageBucket: "nutritrack-app-89707.appspot.com",
  );
}