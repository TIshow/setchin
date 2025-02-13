import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {}; // 地図上のMarkerのセット
  List<Map<String, dynamic>> _nearbyToilets = []; // 近くのトイレ
  Position? _currentPosition; // 現在地

  bool _isExpanded = false;

  // PageView のコントローラー。この付近のトイレで選択されたトイレの表示用
  final PageController _pageController = PageController();

  // チェックボックスの状態
  bool _female = false;
  bool _male = false;
  bool _multipurpose = false;
  bool _washlet = false;
  bool _ostomate = false;
  bool _diaperChange = false;
  bool _babyChair = false;
  bool _wheelchair = false;

  @override
  void initState() {
    super.initState();
    _loadToilets(); // トイレ情報を読み込む
    _getCurrentLocation(); // 現在地を読み込む
  }

  // 現在地を取得
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _currentPosition = position;
      });
      _filterNearbyToilets();
    } catch (e) {
      print("現在地の取得中にエラー: $e");
    }
  }

  // Firestoreからトイレ情報を取得し、Markerを作成
  // 🔥[Provisional] トイレ数増えたら読み取り数が毎回えぐいことになるので、limitかけるべき。
  Future<void> _loadToilets() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

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

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('toilets').get();

      final List<Map<String, dynamic>> toilets = [];
      final Set<Marker> markers = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final GeoPoint? location = data['location'] as GeoPoint?;
        final String name = data['buildingName'] ?? '名前未設定';
        final int rating = data['rating'] ?? 0;
        final Map<String, dynamic> type = data['type'] ?? {};
        final Map<String, dynamic> facilities = data['facilities'] ?? {};

        // locationがnullの場合はスキップ
        if (location == null) {
          print('Warning: トイレデータに位置情報がありません。ドキュメントID: ${doc.id}');
          continue;
        }

        // トイレデータの構造を統一してリストに追加
        final toiletData = {
          "id": doc.id,
          "name": name,
          "location": location,
          "rating": rating,
          "type": type,
          "facilities": facilities,
        };

        toilets.add(toiletData);

        // Marker の作成
        markers.add(Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: data['buildingName'],
            snippet: '満足度: ${data['rating']}',
          ),
          onTap: () {
            _showToiletDetails(data);
          },
        ));
      }

      setState(() {
        _markers.addAll(markers);
        _nearbyToilets = toilets; // 近くのトイレリスト用に設定
      });
    } catch (e) {
      print('トイレ情報の取得中にエラーが発生しました: $e');
    }
  }

  // 現在地から一定距離内のトイレをフィルタリング
  void _filterNearbyToilets([List<Map<String, dynamic>>? toilets]) {
    if (_currentPosition == null) return;

    final userLat = _currentPosition!.latitude;
    final userLng = _currentPosition!.longitude;
    const double maxDistance = 10000.0;

    final nearbyToilets = (toilets ?? []).where((toilet) {
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
            sin(dLng / 2) *
            sin(dLng / 2);
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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    print("Google Map has been loaded successfully.");
  }

  void _toggleContainer() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  double _currentZoomLevel = 15;

void _zoomIn() {
  _currentZoomLevel++;
  mapController.animateCamera(
    CameraUpdate.zoomTo(_currentZoomLevel),
  );
}

void _zoomOut() {
  _currentZoomLevel--;
  mapController.animateCamera(
    CameraUpdate.zoomTo(_currentZoomLevel),
  );
}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(35.6895, 139.6917), // Tokyo coordinates
            zoom: 15,
          ),
          onMapCreated: _onMapCreated,
          markers: _markers, // マーカーを地図に追加
          zoomControlsEnabled: false, // デフォルトのズームボタンを非表示にする
        ),
        // ズームボタンの位置
        Positioned(
          top: 120,
          left: 16,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FloatingActionButton(
                heroTag: "zoom_in",
                mini: true,
                onPressed: _zoomIn,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: "zoom_out",
                mini: true,
                onPressed: _zoomOut,
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "絞り込み検索",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), // アニメーションの時間
            height: _isExpanded
                ? MediaQuery.of(context).size.height * 0.6 // 展開時の高さ
                : 60, // 通常時の高さ
            decoration: BoxDecoration(
              color: const Color(0xFFE6E0E9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: _toggleContainer,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: !_isExpanded ? 0 : 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'この付近のトイレ',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      )),
                  if (_isExpanded)
                    Expanded(
                      child: ListView(
                        children: [
                          const SizedBox(height: 16),
                          // 一段目のチェックボックス
                          const Text(
                            "種類",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _female,
                                onChanged: (value) =>
                                    setState(() => _female = value!),
                              ),
                              const Text("女性用"),
                              Checkbox(
                                value: _male,
                                onChanged: (value) =>
                                    setState(() => _male = value!),
                              ),
                              const Text("男性用"),
                              Checkbox(
                                value: _multipurpose,
                                onChanged: (value) =>
                                    setState(() => _multipurpose = value!),
                              ),
                              const Text("多目的"),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // 二段目のチェックボックス
                          const Text(
                            "設備",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Wrap(
                            spacing: 10,
                            runSpacing: 5,
                            children: [
                              FilterChip(
                                label: const Text("ウォッシュレット"),
                                selected: _washlet,
                                onSelected: (value) =>
                                    setState(() => _washlet = value),
                              ),
                              FilterChip(
                                label: const Text("オストメイト"),
                                selected: _ostomate,
                                onSelected: (value) =>
                                    setState(() => _ostomate = value),
                              ),
                              FilterChip(
                                label: const Text("おむつ替えシート"),
                                selected: _diaperChange,
                                onSelected: (value) =>
                                    setState(() => _diaperChange = value),
                              ),
                              FilterChip(
                                label: const Text("ベビーチェア"),
                                selected: _babyChair,
                                onSelected: (value) =>
                                    setState(() => _babyChair = value),
                              ),
                              FilterChip(
                                label: const Text("車いす用手すり"),
                                selected: _wheelchair,
                                onSelected: (value) =>
                                    setState(() => _wheelchair = value),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // トイレリスト
                          const Text(
                            "この付近のトイレ一覧",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ..._nearbyToilets.map((toilet) => ListTile(
                                title: Text(toilet["name"]!),
                                leading: const Icon(Icons.location_pin),
                                onTap: () {
                                  print(toilet); // ここでデバッグログを確認
                                  _showToiletDetails(toilet);
                                },
                              )),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
