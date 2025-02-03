// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;  // ここでWebの設定を返す
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDpWA-ZoVQfuqcfviiwjOa23-Z9cWz7YTo',
    appId: '1:1052657362861:ios:397c714b3312e7cf6ee324',
    messagingSenderId: '1052657362861',
    projectId: 'setchin-d750a',
    storageBucket: 'setchin-d750a.firebasestorage.app',
    iosBundleId: 'com.example.setchin',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyC_-dCLczNbwgYDnus7ViQ2_Ps3MCETJWI",
    authDomain: "setchin-d750a.firebaseapp.com",
    projectId: "setchin-d750a",
    storageBucket: "setchin-d750a.firebasestorage.app",
    messagingSenderId: "1052657362861",
    appId: "1:1052657362861:web:b16e3edce179934a6ee324",
    measurementId: "G-F1VF5GVDMJ"
  );

}