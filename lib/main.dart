import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'components/templates/bottom_nav_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'components/themes/app_theme.dart';

// 条件付きインポート
import 'utils/web_utils.dart'
    if (dart.library.html) 'utils/web_utils.dart'
    if (dart.library.io) 'utils/stub_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // LOCALでのみ実行🔥
  await dotenv.load(fileName: ".env");

  // Firebaseの初期化
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("🔥 Firebase 初期化エラー: $e");
  }

  // LOCALでのみ実行🔥: Webの場合のみGoogle Mapsスクリプトを追加
  if (kIsWeb) {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      addGoogleMapsScript(apiKey);
    } else {
      print('Error: GOOGLE_MAPS_API_KEY is not set in the .env file.');
    }
  }

  // DEPLOY時に実行!🔥: Google Maps APIキーを取得
  // String? apiKey;
  // if (kIsWeb) {
  //   apiKey = const String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  //   if (apiKey.isNotEmpty) {
  //     addGoogleMapsScript(apiKey);
  //   } else {
  //     print('Error: GOOGLE_MAPS_API_KEY is not set.');
  //   }
  // } else {
  //   apiKey = Platform.environment['GOOGLE_MAPS_API_KEY'];
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anonymous Login Demo',
      theme: AppTheme.lightTheme,
      home: const BottomNavLayout(currentIndex: 0),
    );
  }
}
