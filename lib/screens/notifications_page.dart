import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // ★ 追加：intlをインポート
import 'login_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // 通知リスト格納用
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // ページ読み込み時に通知を取得
  }

  /// Firestore から「自分宛の通知」を取得
  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('notifications')
          .where('toUserId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> tempList = [];
      for (var doc in query.docs) {
        final data = doc.data();
        tempList.add({
          'id': doc.id,
          'fromUserId': data['fromUserId'] ?? '',
          'message': data['message'] ?? '',
          'createdAt': data['createdAt'], // Timestamp
        });
      }

      setState(() {
        _notifications = tempList;
        _isLoading = false;
      });
    } catch (e) {
      // print("🔥 通知取得エラー: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ログイン状態をチェック
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const LoginPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text("通知がありません"))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final message = notification['message'] as String;
                    final fromUserId = notification['fromUserId'] as String;
                    final createdAt = notification['createdAt'];

                    // createdAt は Timestamp かもしれない
                    String timeText = '';
                    if (createdAt != null) {
                      final dateTime = (createdAt as Timestamp).toDate();
                      // ★ 秒を省略したフォーマット (yyyy-MM-dd HH:mm)
                      timeText = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 16.0),
                      child: ListTile(
                        title: Text(message),
                        subtitle: Text(timeText), // フォーマット済み日時表示
                      ),
                    );
                  },
                ),
    );
  }
}