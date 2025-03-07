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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('閉じる'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                await _addToFavorites(context, toiletId);
              },
              icon: const Icon(Icons.favorite, color: Colors.red),
              label: const Text('お気に入りに追加'),
            ),
          ],
        );
      },
    );
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