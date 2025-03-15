import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class RegisterToiletPage extends StatefulWidget {
  const RegisterToiletPage({super.key});

  @override
  State<RegisterToiletPage> createState() => _RegisterToiletPageState();
}

class _RegisterToiletPageState extends State<RegisterToiletPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _buildingNameController = TextEditingController();

  // 現在地の緯度と経度
  double? _latitude;
  double? _longitude;

  // 種類のチェックボックス管理
  bool _female = false;
  bool _male = false;
  bool _multipurpose = false;
  bool _other = false;

  // 設備のチェックボックス管理
  bool _washlet = false;
  bool _ostomate = false;
  bool _diaperChange = false;
  bool _babyChair = false;
  bool _wheelchair = false;

  // 星の満足度管理
  int _rating = 0;

  // 現在地を取得する処理
  Future<void> _getCurrentLocation() async {
    try {
      // 位置情報の許可をリクエスト
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('位置情報のアクセスが拒否されました。');
      }

      // 現在地を取得
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationController.text =
            '緯度: $_latitude, 経度: $_longitude'; // TextFieldに表示
      });

      print('現在地: 緯度: $_latitude, 経度: $_longitude');
    } catch (e) {
      print('現在地を取得中にエラーが発生しました: $e');
    }
  }

  void _updateRating(int value) {
    setState(() {
      _rating = value;
    });
  }

  void _submitForm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ログインが必要です")),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      print('位置情報が取得されていません。');
      return;
    }

    final toiletData = {
      'location': GeoPoint(_latitude!, _longitude!),
      "buildingName": _buildingNameController.text,
      "type": {
        "female": _female,
        "male": _male,
        "multipurpose": _multipurpose,
        "other": _other,
      },
      "rating": _rating,
      "facilities": {
        "washlet": _washlet,
        "ostomate": _ostomate,
        "diaperChange": _diaperChange,
        "babyChair": _babyChair,
        "wheelchair": _wheelchair,
      },
      "registeredBy": user.uid,
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('toilets').add(toiletData);
      print('トイレ情報が登録されました！');
      // フォームの内容をクリアする
      _clearForm();

      // 完了メッセージを表示
      _showSuccessDialog();
    } catch (e) {
      print('登録中にエラーが発生しました: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text(
                '登録が完了しました！',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // フォームをクリアする
  void _clearForm() {
    setState(() {
      _locationController.clear();
      _buildingNameController.clear();
      _latitude = null;
      _longitude = null;
      _rating = 0;
      _female = false;
      _male = false;
      _multipurpose = false;
      _other = false;
      _washlet = false;
      _ostomate = false;
      _diaperChange = false;
      _babyChair = false;
      _wheelchair = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔑 StreamBuilder を使ってログイン状態を監視
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ローディング中はぐるぐる表示
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 未ログインなら LoginPage へ
        if (!snapshot.hasData) {
          return const LoginPage();
        }

        // ログイン中ならトイレ登録フォームを表示
        return Scaffold(
          appBar: AppBar(
            title: const Text('トイレ情報を登録'),
            backgroundColor: const Color(0xFFE6E0E9),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('位置', style: TextStyle(fontSize: 16.0)),
                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: '位置を入力してください',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: const Text('現在地を取得して入力'),
                      ),
                      const SizedBox(height: 20),
                      const Text('建物名', style: TextStyle(fontSize: 16.0)),
                      TextField(
                        controller: _buildingNameController,
                        decoration: const InputDecoration(
                          hintText: '建物名を入力してください',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('種類', style: TextStyle(fontSize: 16.0)),
                      CheckboxListTile(
                        title: const Text('女性用'),
                        value: _female,
                        onChanged: (value) => setState(() => _female = value!),
                      ),
                      CheckboxListTile(
                        title: const Text('男性用'),
                        value: _male,
                        onChanged: (value) => setState(() => _male = value!),
                      ),
                      CheckboxListTile(
                        title: const Text('多目的'),
                        value: _multipurpose,
                        onChanged: (value) =>
                            setState(() => _multipurpose = value!),
                      ),
                      CheckboxListTile(
                        title: const Text('その他'),
                        value: _other,
                        onChanged: (value) => setState(() => _other = value!),
                      ),
                      const SizedBox(height: 20),
                      const Text('満足度', style: TextStyle(fontSize: 16.0)),
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            onPressed: () => _updateRating(index + 1),
                            icon: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      const Text('設備', style: TextStyle(fontSize: 16.0)),
                      CheckboxListTile(
                        title: const Text('ウォッシュレット'),
                        value: _washlet,
                        onChanged: (value) => setState(() => _washlet = value!),
                      ),
                      CheckboxListTile(
                        title: const Text('オストメイト'),
                        value: _ostomate,
                        onChanged: (value) => setState(() => _ostomate = value!),
                      ),
                      CheckboxListTile(
                        title: const Text('おむつ替えシート'),
                        value: _diaperChange,
                        onChanged: (value) =>
                            setState(() => _diaperChange = value!),
                      ),
                      CheckboxListTile(
                        title: const Text('ベビーチェア'),
                        value: _babyChair,
                        onChanged: (value) => setState(() => _babyChair = value!),
                      ),
                      CheckboxListTile(
                        title: const Text('車いす用手すり'),
                        value: _wheelchair,
                        onChanged: (value) => setState(() => _wheelchair = value!),
                      ),
                      const SizedBox(height: 80), // ボタンとの間隔
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1D1B20),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      '登録',
                      style: TextStyle(fontSize: 16.0, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}