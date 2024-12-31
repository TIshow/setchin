import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 仮の通知データ
    final List<Map<String, String>> notifications = [
      {"name": "山田太郎", "message": "あなたが登録したトイレが利用されました！ありがとう！"},
      {"name": "鈴木花子", "message": "感謝します！トイレがとても助かりました！"},
      {"name": "田中一郎", "message": "清潔で助かりました。ありがとう！"},
    ];

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
  }
}
