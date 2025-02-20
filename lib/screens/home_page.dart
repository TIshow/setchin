library home_page;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

// my packages
import '../components/templates/swipe_up_menu.dart';
import '../components/templates/floating_buttons.dart';
import '../components/templates/map_view.dart';
import '../components/organisms/search_bar.dart';

// my services
import '../services/firestore_service.dart';
import '../services/location_service.dart';

// 分割先のファイルを指定
part 'home_page_methods.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {};       // 地図上のMarkerのセット
  List<Map<String, dynamic>> _nearbyToilets = []; // 近くのトイレ
  Position? _currentPosition;            // 現在地
  double _currentZoomLevel = 15;
  bool _isExpanded = false;

  // PageView のコントローラー（例：近くのトイレで選択されたトイレの表示用）
  final PageController _pageController = PageController();

  // チェックボックスの状態
  final bool _female = false;
  final bool _male = false;
  final bool _multipurpose = false;
  final bool _washlet = false;
  final bool _ostomate = false;
  final bool _diaperChange = false;
  final bool _babyChair = false;
  final bool _wheelchair = false;

  // ==================================

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
              toggleMenu: _toggleContainer,  // 分割先メソッド
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