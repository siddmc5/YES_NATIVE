// File generated manually from google-services.json
// For web support, Firebase web config is needed from Firebase Console.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android config from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBCgVtD1g_pfSyHhrCydvX9vpNeZhGiE0',
    appId: '1:550789388423:android:c3d4317fe232b3d0030022',
    messagingSenderId: '550789388423',
    projectId: 'yesnativeuser',
    storageBucket: 'yesnativeuser.firebasestorage.app',
  );

  // Web config from Firebase Console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAAoNCDXFxGwuAMRx6sTXyHhQPq5lCSUkI',
    appId: '1:550789388423:web:3c36fbe61d80b087030022',
    messagingSenderId: '550789388423',
    projectId: 'yesnativeuser',
    storageBucket: 'yesnativeuser.firebasestorage.app',
    authDomain: 'yesnativeuser.firebaseapp.com',
    measurementId: 'G-9LKT3T54P7',
  );
}
