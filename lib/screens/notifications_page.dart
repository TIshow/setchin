import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ローディング中はぐるぐる表示
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 未ログインの場合は LoginPage へ
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // 仮の通知データ
        final List<Map<String, String>> notifications = [
          {"name": "山田太郎", "message": "あなたが登録したトイレが利用されました！ありがとう！"},
          {"name": "鈴木花子", "message": "感謝します！トイレがとても助かりました！"},
          {"name": "田中一郎", "message": "清潔で助かりました。ありがとう！"},
        ];

        // ログイン中なら通知画面を表示
        return Scaffold(
          appBar: AppBar(
            title: const Text('通知'),
            backgroundColor: const Color(0xFFE6E0E9),
          ),
          body: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE6E0E9),
                    child: Text(notification["name"]![0]),
                  ),
                  title: Text(notification["name"]!),
                  subtitle: Text(notification["message"]!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}