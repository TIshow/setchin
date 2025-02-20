// 
// Summary: このファイルは、位置情報を取得するためのLocationServiceクラスを定義します。
// Date: 2025/02/20
// Author: Coiai
// 

import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }
}