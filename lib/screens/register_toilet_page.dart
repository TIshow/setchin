import 'package:flutter/material.dart';

class RegisterToiletPage extends StatefulWidget {
  const RegisterToiletPage({super.key});

  @override
  State<RegisterToiletPage> createState() => _RegisterToiletPageState();
}

class _RegisterToiletPageState extends State<RegisterToiletPage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _buildingNameController = TextEditingController();

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

  void _updateRating(int value) {
    setState(() {
      _rating = value;
    });
  }

  void _submitForm() {
    // 登録処理をここに実装
    print('位置: ${_locationController.text}');
    print('建物名: ${_buildingNameController.text}');
    print('種類: 女性用: $_female, 男性用: $_male, 多目的: $_multipurpose, その他: $_other');
    print('満足度: $_rating');
    print(
        '設備: ウォッシュレット: $_washlet, オストメイト: $_ostomate, おむつ替えシート: $_diaperChange, ベビーチェア: $_babyChair, 車いす用手すり: $_wheelchair');
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {
                      _locationController.text = '現在地を入力';
                    },
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
  }
}
