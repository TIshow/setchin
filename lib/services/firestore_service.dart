//
// Summary: このファイルは、Firestoreからデータを取得するためのFirestoreServiceクラスを定義します。
// Date: 2025/02/20
// Author: Coiai
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

class FirebaseService {
  // シングルトンインスタンス
  static final FirebaseService instance = FirebaseService._internal();

  // プライベートコンストラクタ
  FirebaseService._internal();

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

  // Firestoreからトイレ情報を取得し、状態を更新
  Future<void> loadToiletsAndUpdateState(
      GoogleMapController? mapController,
      Function(Position) onLocationSuccess,
      Function(List<Map<String, dynamic>>, Set<Marker>) onDataSuccess,
      Function(String) onError) async {
    try {
      final position = await LocationService.instance.getCurrentLocation();
      onLocationSuccess(position);

      mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );

      final toilets = await loadToilets();
      final Set<Marker> markers = {};

      for (var toiletData in toilets) {
        final GeoPoint location = toiletData['location'] as GeoPoint;

        markers.add(Marker(
          markerId: MarkerId(toiletData['id']),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: toiletData['name'],
            snippet: '満足度: ${toiletData['rating']}',
          ),
        ));
      }

      onDataSuccess(toilets, markers);
    } catch (e) {
      onError('トイレ情報の取得中にエラーが発生しました: $e');
    }
  }
}
