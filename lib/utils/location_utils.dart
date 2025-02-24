import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationUtils {
  // 現在地から一定距離内のトイレをフィルタリング
  static List<Map<String, dynamic>> filterNearbyToilets(
      List<Map<String, dynamic>> toilets, Position? currentPosition) {
    if (currentPosition == null) return [];

    final userLat = currentPosition.latitude;
    final userLng = currentPosition.longitude;
    const double maxDistance = 10000.0;

    return toilets.where((toilet) {
      final GeoPoint location = toilet['location'] as GeoPoint;
      final double distance = calculateDistance(
        userLat,
        userLng,
        location.latitude,
        location.longitude,
      );
      return distance <= maxDistance;
    }).toList();
  }

  // 距離計算（Haversine formula）
  static double calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371.0; // 地球の半径 (km)
    final double dLat = degreesToRadians(lat2 - lat1);
    final double dLng = degreesToRadians(lng2 - lng1);

    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
