import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  final Set<Marker> _markers = {}; // 地図上のMarkerのセット

  bool _isExpanded = false;

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
  }

  // Firestoreからトイレ情報を取得し、Markerを作成
  Future<void> _loadToilets() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('toilets').get();

      // FirestoreのデータをMarkerに変換
      final toilets = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final GeoPoint location = data['location'];
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: data['buildingName'],
            snippet: '満足度: ${data['rating']}',
          ),
          onTap: () => _showToiletDetails(data),
        );
      }).toSet();

      setState(() {
        _markers.addAll(toilets);
      });
    } catch (e) {
      print('トイレ情報の取得中にエラーが発生しました: $e');
    }
  }

  // トイレ情報をダイアログで表示
  void _showToiletDetails(Map<String, dynamic> data) {
    print(data);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data['buildingName']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('満足度: ${data['rating']}'),
              const SizedBox(height: 10),
              Text('種類: ${_formatToiletType(data['type'])}'),
              const SizedBox(height: 10),
              Text('設備: ${_formatFacilities(data['facilities'])}'),
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

  // 仮のこの付近のトイレ一覧データ
  final List<Map<String, String>> nearbyToilets = [
    {"name": "新宿駅 トイレ", "location": "東京都新宿区"},
    {"name": "渋谷駅 トイレ", "location": "東京都渋谷区"},
    {"name": "東京駅 トイレ", "location": "東京都千代田区"},
  ];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    print("Google Map has been loaded successfully.");
  }

  void _toggleContainer() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
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
                          ...nearbyToilets.map((toilet) => ListTile(
                                title: Text(toilet["name"]!),
                                subtitle: Text(toilet["location"]!),
                                leading: const Icon(Icons.location_pin),
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
