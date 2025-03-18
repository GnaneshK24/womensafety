import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for ${defaultTargetPlatform.name}.',
        );
    }
  }

  // TODO: Replace these values with your Firebase web configuration
  // You can find these values in your Firebase Console:
  // 1. Go to Project Settings
  // 2. Under "Your apps", find your web app
  // 3. Copy the values from the firebaseConfig object
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC3UJ31w4QTWa53-VLypgedaa0TZMroRMg',
    appId: '1:427334871623:android:5f949e35c6e76976199f62',
    messagingSenderId: '427334871623',
    projectId: 'women-safety-4269b',
    storageBucket: 'women-safety-4269b.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3UJ31w4QTWa53-VLypgedaa0TZMroRMg',
    appId: '1:427334871623:web:5f949e35c6e76976199f62',
    messagingSenderId: '427334871623',
    projectId: 'women-safety-4269b',
    authDomain: 'women-safety-4269b.firebaseapp.com',
    storageBucket: 'women-safety-4269b.firebasestorage.app',
    measurementId: 'G-G1EVJD5ZLH',
  );
} 