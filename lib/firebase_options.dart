import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for android.');
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for macos.');
      case TargetPlatform.windows:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for windows.');
      case TargetPlatform.linux:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for linux.');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_IOS_API_KEY']!,
    appId: dotenv.env['FIREBASE_IOS_APP_ID']!,
    messagingSenderId: dotenv.env['FIREBASE_IOS_MESSAGING_SENDER_ID']!,
    projectId: dotenv.env['FIREBASE_IOS_PROJECT_ID']!,
    storageBucket: dotenv.env['FIREBASE_IOS_STORAGE_BUCKET']!,
    iosBundleId: dotenv.env['FIREBASE_IOS_BUNDLE_ID']!,
  );

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_WEB_API_KEY']!,
    authDomain: dotenv.env['FIREBASE_WEB_AUTH_DOMAIN']!,
    projectId: dotenv.env['FIREBASE_WEB_PROJECT_ID']!,
    storageBucket: dotenv.env['FIREBASE_WEB_STORAGE_BUCKET']!,
    messagingSenderId: dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID']!,
    appId: dotenv.env['FIREBASE_WEB_APP_ID']!,
    measurementId: dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'],
  );
}