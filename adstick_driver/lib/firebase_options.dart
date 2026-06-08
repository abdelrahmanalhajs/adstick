import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyCM6rwvSsXyK6fQAcHoEwTrlN9_yXZFvmk',
    appId:             '1:217851652919:web:ff6d6ce31e3fb0ec0b88b2',
    messagingSenderId: '217851652919',
    projectId:         'adstick-90329',
    authDomain:        'adstick-90329.firebaseapp.com',
    storageBucket:     'adstick-90329.firebasestorage.app',
    databaseURL:       'https://adstick-90329-default-rtdb.europe-west1.firebasedatabase.app',
  );
}
