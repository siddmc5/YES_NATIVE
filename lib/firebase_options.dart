// Generated Firebase options for the Yes Native Vendor app.
//
// This file provides platform-specific Firebase configuration.
// For web, the Firebase JS SDK is loaded automatically by the
// firebase_core_web plugin — no manual <script> tags needed.
//
// To regenerate using the CLI:
//   dart pub global activate flutterfire_cli
//   flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for the current platform.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // Android & iOS use google-services.json / GoogleService-Info.plist
    // so no manual options are needed.
    throw UnsupportedError(
      'DefaultFirebaseOptions are not available for this platform.\n'
      'Android/iOS: ensure you have placed google-services.json / '
      'GoogleService-Info.plist in the correct directory.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD8B2JeNIn--eNB3N8MZ218of-T_jHbit8',
    appId: '1:141513367277:web:f11f62a45dc7ea640ab6e4',
    messagingSenderId: '141513367277',
    projectId: 'native-app-26',
    authDomain: 'native-app-26.firebaseapp.com',
    storageBucket: 'native-app-26.firebasestorage.app',
    measurementId: 'G-Z06G7LR6HB',
  );
}
