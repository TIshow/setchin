import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/format_utils.dart';

class ToiletDetailsDialog {
  static void show(BuildContext context, Map<String, dynamic> data, String toiletId) {
    final String name = data['name'] ?? '名前未設定';
    final String rating = data['rating']?.toString() ?? '情報なし';
    final GeoPoint? location = data['location'] as GeoPoint?;
    final Map<String, dynamic> type = data['type'] ?? {};
    final Map<String, dynamic> facilities = data['facilities'] ?? {};

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('満足度: $rating'),
              const SizedBox(height: 10),
              Text('種類: ${FormatUtils.formatToiletType(type)}'),
              const SizedBox(height: 10),
              Text('設備: ${FormatUtils.formatFacilities(facilities)}'),
            ],
          ),
          actions: [
            Row(children: [
              // ありがとうボタン
              ElevatedButton.icon(
                icon: const Icon(Icons.thumb_up),
                label: const Text('ありがとう'),
                onPressed: () async {
                  await _sendThanks(context, toiletId, data);
                },
              ),
              const SizedBox(width: 10),
              // お気に入りボタン
              ElevatedButton.icon(
                onPressed: () async {
                  await _addToFavorites(context, toiletId);
                },
                icon: const Icon(Icons.favorite, color: Colors.red),
                label: const Text('お気に入り'),
              ),
            ],),
            // 閉じるボタン
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _sendThanks(
    BuildContext context,
    String toiletId,
    Map<String, dynamic> data,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ログインが必要です")),
      );
      return;
    }

    try {
      final String? toUserId = data['registeredBy'];
      if (toUserId == null) {
        print("⚠️ 投稿者IDが見つかりません");
        return;
      }

      // 自分自身に送ろうとした場合の処理
      if (toUserId == user.uid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("あなた自身の投稿です")),
        );
        return;
      }

      // Firestore に「ありがとう」通知を追加
      await FirebaseFirestore.instance.collection('notifications').add({
        'toUserId': toUserId,
        'fromUserId': user.uid,
        'message': 'ありがとうボタンが押されました！',
        'createdAt': FieldValue.serverTimestamp(),
        'toiletId': toiletId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("「ありがとう」を送信しました")),
      );
    } catch (e) {
      print("🔥 ありがとう送信エラー: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("エラーが発生しました")),
      );
    }
  }

  static Future<void> _addToFavorites(BuildContext context, String toiletId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ログインが必要です")),
      );
      return;
    }

    try {
      final favoritesRef = FirebaseFirestore.instance.collection('favorites');
      
      // 既にお気に入りに登録されているか確認
      final querySnapshot = await favoritesRef
          .where('userId', isEqualTo: user.uid)
          .where('toiletId', isEqualTo: toiletId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("既にお気に入りに登録されています")),
        );
        return;
      }

      // Firestore にお気に入りを追加
      await favoritesRef.add({
        'userId': user.uid,
        'toiletId': toiletId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("お気に入りに追加しました")),
      );
    } catch (e) {
      print("🔥 お気に入り追加エラー: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("エラーが発生しました")),
      );
    }
  }
}