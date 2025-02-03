import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'widgets/bottom_nav_layout.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // プラットフォーム判定用

// Web専用のdart:htmlを条件付きインポート
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. まず環境変数を読み込む
  await dotenv.load(fileName: ".env");

  // 2. 環境変数がロードされた後にFirebaseを初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Webプラットフォームの場合にGoogle Mapsスクリプトを追加
  if (kIsWeb) {
    addGoogleMapsScript(dotenv.env['GOOGLE_MAPS_API_KEY']!);
  }

  runApp(const MyApp());
}

// Webの場合のみGoogle Mapsのスクリプトを追加
void addGoogleMapsScript(String apiKey) {
  final script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initMap'
    ..type = 'text/javascript'
    ..async = true
    ..defer = true;
  html.document.body!.append(script);
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