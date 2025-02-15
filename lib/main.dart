import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'widgets/bottom_nav_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// 条件付きインポート
import 'utils/web_utils.dart'
    if (dart.library.html) 'utils/web_utils.dart'
    if (dart.library.io) 'utils/stub_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Firebaseの初期化
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("🔥 Firebase 初期化エラー: $e");
  }

  // Webの場合のみGoogle Mapsスクリプトを追加
  if (kIsWeb) {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      addGoogleMapsScript(apiKey);
    } else {
      print('Error: GOOGLE_MAPS_API_KEY is not set in the .env file.');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anonymous Login Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const BottomNavLayout(currentIndex: 0),
    );
  }
}
