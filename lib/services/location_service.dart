import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

class LocationService {
  // シングルトンインスタンス
  static final LocationService instance = LocationService._internal();

  // プライベートコンストラクタ
  LocationService._internal();

  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  // 現在位置取得処理
  Future<void> getCurrentLocationAndUpdateState(
      Function(Position) onSuccess, Function(String) onError) async {
    try {
      final position = await getCurrentLocation();
      onSuccess(position);
    } catch (e) {
      onError("現在地の取得中にエラー: $e");
    }
  }

  // 現在地へ移動するカメラ操作
  Future<void> moveToCurrentLocation(
      GoogleMapController? mapController, Position? currentPosition) async {
    if (currentPosition == null) {
      debugPrint('現在地が取得できませんでした。');
      return;
    }
    LatLng latLng = LatLng(currentPosition.latitude, currentPosition.longitude);
    mapController?.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }
}
