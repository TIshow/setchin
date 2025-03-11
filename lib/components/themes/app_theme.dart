import 'package:flutter/material.dart';


class AppTheme {
  static ThemeData get lightTheme {
    // メインカラーを #5BBCCC に設定
    const primaryColor = Color(0xFF5BBCCC);

    return ThemeData(
      fontFamily: 'NotoSansJP',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
      ).copyWith(
        primary: primaryColor,
        secondary: primaryColor,
      ),
      useMaterial3: false, // 必要に応じて変更
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // テキストテーマ
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );
  }
}