// ────────────────────────────────────────────────────────────
//  Firebase configuration — AdStick shared project
//
//  HOW TO FILL THIS IN:
//  1. Go to https://console.firebase.google.com
//  2. Create a project (e.g. "adstick")
//  3. Enable Authentication → Email/Password
//  4. Enable Firestore Database (start in test mode)
//  5. Enable Realtime Database (start in test mode)
//  6. Click "+ Add app" → Web, register it
//  7. Copy the values from your firebaseConfig object below
//
//  All three apps (driver / advertiser / admin) share the SAME
//  Firebase project, so copy this file verbatim to all three.
// ────────────────────────────────────────────────────────────
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'REPLACE_WITH_YOUR_API_KEY',
    appId:             'REPLACE_WITH_YOUR_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId:         'REPLACE_WITH_YOUR_PROJECT_ID',
    authDomain:        'REPLACE_WITH_YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket:     'REPLACE_WITH_YOUR_PROJECT_ID.appspot.com',
    databaseURL:       'https://REPLACE_WITH_YOUR_PROJECT_ID-default-rtdb.firebaseio.com',
  );
}
