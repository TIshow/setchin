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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    appId: '1:1052657362861:ios:dbc4e0fc08f89ca76ee324',
    messagingSenderId: '1052657362861',
    projectId: 'setchin-d750a',
    storageBucket: 'setchin-d750a.firebasestorage.app',
    iosBundleId: 'com.coiai.setchin',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_-dCLczNbwgYDnus7ViQ2_Ps3MCETJWI',
    appId: '1:1052657362861:web:b16e3edce179934a6ee324',
    messagingSenderId: '1052657362861',
    projectId: 'setchin-d750a',
    authDomain: 'setchin-d750a.firebaseapp.com',
    storageBucket: 'setchin-d750a.firebasestorage.app',
    measurementId: 'G-F1VF5GVDMJ',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDpWA-ZoVQfuqcfviiwjOa23-Z9cWz7YTo',
    appId: '1:1052657362861:ios:397c714b3312e7cf6ee324',
    messagingSenderId: '1052657362861',
    projectId: 'setchin-d750a',
    storageBucket: 'setchin-d750a.firebasestorage.app',
    iosBundleId: 'com.example.setchin',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCi5gxQwvkYpt4iyGbu5nZ6CGmQomw52KY',
    appId: '1:1052657362861:android:2fe2ce9513dcf3fc6ee324',
    messagingSenderId: '1052657362861',
    projectId: 'setchin-d750a',
    storageBucket: 'setchin-d750a.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC_-dCLczNbwgYDnus7ViQ2_Ps3MCETJWI',
    appId: '1:1052657362861:web:52a0f3e631c7ef966ee324',
    messagingSenderId: '1052657362861',
    projectId: 'setchin-d750a',
    authDomain: 'setchin-d750a.firebaseapp.com',
    storageBucket: 'setchin-d750a.firebasestorage.app',
    measurementId: 'G-WHQH8F4FWG',
  );

}