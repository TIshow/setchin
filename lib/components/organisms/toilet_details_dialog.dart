import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/format_utils.dart';

class ToiletDetailsDialog {
  static void show(BuildContext context, Map<String, dynamic> data) {
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
          ],
        );
      },
    );
  }
}
