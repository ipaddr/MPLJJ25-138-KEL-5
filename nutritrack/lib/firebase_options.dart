import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDQpxm3xuL95ioMj42j65wn01l7vOtg_Pk",
    appId: "1:410853656795:android:d10897dc647eb40c98e4fe",
    messagingSenderId: "410853656795",
    projectId: "nutritrack-app-89707",
    storageBucket: "nutritrack-app-89707.appspot.com",
    databaseURL: "https://nutritrack-app-89707-default-rtdb.firebaseio.com",
  );
}
