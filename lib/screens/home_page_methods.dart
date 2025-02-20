part of home_page;

extension _HomePageStateExtension on _HomePageState {
  // サービスのインスタンスを生成
  static final LocationService _locationService = LocationService();
  static final FirebaseService _firebaseService = FirebaseService();

  // 現在地を取得
  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });
      _filterNearbyToilets();
    } catch (e) {
      debugPrint("現在地の取得中にエラー: $e");
    }
  }

  // Firestoreからトイレ情報を取得し、Markerを作成
  Future<void> _loadToilets() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });

      // 現在地を中心にカメラを移動
      mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );

      _filterNearbyToilets();

      final toilets = await _firebaseService.loadToilets();
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
          onTap: () {
            _showToiletDetails(toiletData);
          },
        ));
      }

      setState(() {
        _markers.addAll(markers);
        _nearbyToilets = toilets;
      });
    } catch (e) {
      debugPrint('トイレ情報の取得中にエラーが発生しました: $e');
    }
  }

  // 現在地から一定距離内のトイレをフィルタリング
  void _filterNearbyToilets([List<Map<String, dynamic>>? toilets]) {
    if (_currentPosition == null) return;

    final userLat = _currentPosition!.latitude;
    final userLng = _currentPosition!.longitude;
    const double maxDistance = 10000.0;

    // 引数があればそれを、なければ今あるリストを対象とする
    final nearbyToilets = (toilets ?? _nearbyToilets).where((toilet) {
      final GeoPoint location = toilet['location'] as GeoPoint;
      final double distance = _calculateDistance(
        userLat,
        userLng,
        location.latitude,
        location.longitude,
      );
      return distance <= maxDistance;
    }).toList();

    setState(() {
      _nearbyToilets = nearbyToilets;
    });
  }

  // 距離計算（Haversine formula）
  double _calculateDistance(
      double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371.0; // 地球の半径 (km)
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // トイレ情報をダイアログで表示
  void _showToiletDetails(Map<String, dynamic> data) {
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
              Text('種類: ${_formatToiletType(type)}'),
              const SizedBox(height: 10),
              Text('設備: ${_formatFacilities(facilities)}'),
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

  // 種類をフォーマット
  String _formatToiletType(Map<String, dynamic> type) {
    List<String> types = [];
    if (type['female'] == true) types.add('女性用');
    if (type['male'] == true) types.add('男性用');
    if (type['multipurpose'] == true) types.add('多目的');
    if (type['other'] == true) types.add('その他');
    return types.join(', ');
  }

  // 設備をフォーマット
  String _formatFacilities(Map<String, dynamic> facilities) {
    List<String> facilityList = [];
    if (facilities['washlet'] == true) facilityList.add('ウォッシュレット');
    if (facilities['ostomate'] == true) facilityList.add('オストメイト');
    if (facilities['diaperChange'] == true) facilityList.add('おむつ替えシート');
    if (facilities['babyChair'] == true) facilityList.add('ベビーチェア');
    if (facilities['wheelchair'] == true) facilityList.add('車いす用手すり');
    return facilityList.join(', ');
  }

  // スワイプメニュー開閉
  void _toggleContainer() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  // 現在地へ移動するカメラ操作
  Future<void> _moveToCurrentLocation() async {
    if (_currentPosition == null) {
      debugPrint('現在地が取得できませんでした。');
      return;
    }
    mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      ),
    );
  }
}