// 
// Summary: このファイルは、Firestoreからデータを取得するためのFirestoreServiceクラスを定義します。
// Date: 2025/02/20
// Author: Coiai
//

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  Future<List<Map<String, dynamic>>> loadToilets() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('toilets').get();

    final List<Map<String, dynamic>> toilets = [];

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint? location = data['location'] as GeoPoint?;
      if (location == null) {
        // 位置情報がない場合はスキップ
        continue;
      }
      final String name = data['buildingName'] ?? '名前未設定';
      final int rating = data['rating'] ?? 0;
      final Map<String, dynamic> type = data['type'] ?? {};
      final Map<String, dynamic> facilities = data['facilities'] ?? {};

      final toiletData = {
        "id": doc.id,
        "name": name,
        "location": location,
        "rating": rating,
        "type": type,
        "facilities": facilities,
      };

      toilets.add(toiletData);
    }
    return toilets;
  }
}