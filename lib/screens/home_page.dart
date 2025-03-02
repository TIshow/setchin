library home_page;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

// packages
import '../components/templates/swipe_up_menu.dart';
import '../components/templates/floating_buttons.dart';
import '../components/templates/map_view.dart';
import '../components/organisms/search_bar.dart';

// services
import '../services/firestore_service.dart';
import '../services/location_service.dart';

// utils
import '../utils/location_utils.dart';

// widgets
import '../components/organisms/toilet_details_dialog.dart';

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
  double _currentZoomLevel = 15;
  bool _isExpanded = false;

  // チェックボックスの状態
  final bool _female = false;
  final bool _male = false;
  final bool _multipurpose = false;
  final bool _washlet = false;
  final bool _ostomate = false;
  final bool _diaperChange = false;
  final bool _babyChair = false;
  final bool _wheelchair = false;

  // サービスのインスタンスを生成
  static final LocationService _locationService = LocationService.instance;
  static final FirebaseService _firebaseService = FirebaseService.instance;

  // 現在地を取得
  Future<void> _getCurrentLocation() async {
    _locationService.getCurrentLocationAndUpdateState(
      (position) {
        setState(() {
          _currentPosition = position;
        });
        _filterNearbyToilets();
      },
      (errorMessage) {
        debugPrint("現在地の取得中にエラー: $errorMessage");
      },
    );
  }

  // Firestoreからトイレ情報を取得し、Markerを作成
  Future<void> _loadToilets() async {
    _firebaseService.loadToiletsAndUpdateState(
      context,
      mapController,
      (position) {
        setState(() {
          _currentPosition = position;
        });
      },
      (toilets, markers) {
        setState(() {
          _markers.addAll(markers);
          _nearbyToilets = toilets;
        });
      },
      (errorMessage) {
        debugPrint(errorMessage);
      },
    );
  }

//   Firestoreからトイレ情報を取得し、Markerを作成
//   Future<void> _loadToilets() async {
//     try {
//       final position = await _locationService.getCurrentLocation();
//       setState(() {
//         _currentPosition = position;
//       });

//       // 現在地を中心にカメラを移動
//       mapController.animateCamera(
//         CameraUpdate.newLatLng(
//           LatLng(position.latitude, position.longitude),
//         ),
//       );

//       _filterNearbyToilets();

//       final toilets = await _firebaseService.loadToilets();
//       final Set<Marker> markers = {};

//       for (var toiletData in toilets) {
//         final GeoPoint location = toiletData['location'] as GeoPoint;

//         markers.add(Marker(
//           markerId: MarkerId(toiletData['id']),
//           position: LatLng(location.latitude, location.longitude),
//           infoWindow: InfoWindow(
//             title: toiletData['name'],
//             snippet: '満足度: ${toiletData['rating']}',
//           ),
//           onTap: () {
//             _showToiletDetails(toiletData);
//           },
//         ));
//       }

//       setState(() {
//         _markers.addAll(markers);
//         _nearbyToilets = toilets;
//       });
//     } catch (e) {
//       debugPrint('トイレ情報の取得中にエラーが発生しました: $e');
//     }
//   }

// // トイレ情報をダイアログで表示
//   void _showToiletDetails(Map<String, dynamic> data) {
//     final String name = data['name'] ?? '名前未設定';
//     final String rating = data['rating']?.toString() ?? '情報なし';
//     final GeoPoint? location = data['location'] as GeoPoint?;
//     final Map<String, dynamic> type = data['type'] ?? {};
//     final Map<String, dynamic> facilities = data['facilities'] ?? {};

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(name),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('満足度: $rating'),
//               const SizedBox(height: 10),
//               Text('種類: ${_formatToiletType(type)}'),
//               const SizedBox(height: 10),
//               Text('設備: ${_formatFacilities(facilities)}'),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('閉じる'),
//             ),
//           ],
//         );
//       },
//     );
//   }

  // 現在地から一定距離内のトイレをフィルタリング
  void _filterNearbyToilets([List<Map<String, dynamic>>? toilets]) {
    setState(() {
      _nearbyToilets = LocationUtils.filterNearbyToilets(
          toilets ?? _nearbyToilets, _currentPosition);
    });
  }

  // トイレ情報をダイアログで表示
  void _showToiletDetails(Map<String, dynamic> data) {
    ToiletDetailsDialog.show(context, data);
  }

  // 現在地へ移動するカメラ操作
  Future<void> _moveToCurrentLocation() async {
    _locationService.moveToCurrentLocation(mapController, _currentPosition);
  }

  // スワイプメニュー開閉
  void _toggleContainer() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 地図
        MapView(
          markers: _markers,
          onMapCreated: (controller) async {
            mapController = controller;
            await _moveToCurrentLocation();
            await _loadToilets();
          },
        ),
        // フローティングボタン
        FloatingButtons(
          onCurrentLocationPressed: _moveToCurrentLocation,
          onReloadPressed: _loadToilets,
          onZoomInPressed: () {
            _currentZoomLevel++;
            mapController.animateCamera(CameraUpdate.zoomTo(_currentZoomLevel));
          },
          onZoomOutPressed: () {
            _currentZoomLevel--;
            mapController.animateCamera(CameraUpdate.zoomTo(_currentZoomLevel));
          },
        ),
        // 検索バー
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: CustomSearchBar(
            onSearchChanged: (text) {
              debugPrint("検索キーワード: $text");
              // 検索キーワードを使った処理を追加するならここ
            },
          ),
        ),
        // 下からのスワイプメニュー（AnimatedContainer）
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
            child: SwipeUpMenu(
              isExpanded: _isExpanded,
              toggleMenu: _toggleContainer, // 分割先メソッド
              nearbyToilets: _nearbyToilets,
              showToiletDetails: _showToiletDetails, // 分割先メソッド
              female: _female,
              male: _male,
              multipurpose: _multipurpose,
              washlet: _washlet,
              ostomate: _ostomate,
              diaperChange: _diaperChange,
              babyChair: _babyChair,
              wheelchair: _wheelchair,
              onFilterChange: (bool value) {
                setState(() {
                  // フィルターの状態を更新する処理を追加
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
