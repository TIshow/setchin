import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ToiletRepository {
  static Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      print("現在地の取得エラー: $e");
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchToilets() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('toilets').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final location = data['location'] as GeoPoint?;
        return {
          "id": doc.id,
          "name": data['buildingName'] ?? '名前未設定',
          "location": location,
          "rating": data['rating'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print("トイレ情報取得エラー: $e");
      return [];
    }
  }

  static Set<Marker> createMarkers(
      List<Map<String, dynamic>> toilets, Function(Map<String, dynamic>) onTap) {
    return toilets.map((toilet) {
      final location = toilet['location'] as GeoPoint;
      return Marker(
        markerId: MarkerId(toilet['id']),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(title: toilet['name']),
        onTap: () => onTap(toilet),
      );
    }).toSet();
  }
}