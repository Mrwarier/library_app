// GENERATED FILE — normally produced by `flutterfire configure`.
// Android values below are taken directly from the google-services.json
// you provided (project: librarymobileapp). iOS and web are NOT in that
// file, so they're left as placeholders — see the TODOs.
//
// To regenerate properly once you have the CLI installed locally:
//   dart pub global activate flutterfire_cli
//   flutterfire configure --project=librarymobileapp

import 'package:firebase_core/firebase_core.dart';
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
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBR4_fAqrnmS_96RsANYKdtsPDh9zuSkZA',
    appId: '1:487966813069:android:a7ac8e3f05bcca349c6bc4',
    messagingSenderId: '487966813069',
    projectId: 'librarymobileapp',
    storageBucket: 'librarymobileapp.firebasestorage.app',
  );


  // has an Android client). Add an iOS app in the Firebase console, download
  // GoogleService-Info.plist, and replace these values — or run
  // `flutterfire configure` to fill this in automatically.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '487966813069',
    projectId: 'librarymobileapp',
    storageBucket: 'librarymobileapp.firebasestorage.app',
    iosBundleId: 'com.library.app',
  );

  
  // these values, or run `flutterfire configure`.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_WEB_API_KEY',
    appId: 'REPLACE_WITH_WEB_APP_ID',
    messagingSenderId: '487966813069',
    projectId: 'librarymobileapp',
    storageBucket: 'librarymobileapp.firebasestorage.app',
  );
}
