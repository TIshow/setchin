import 'package:flutter/material.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 仮データ
    final List<Map<String, String>> postedToilets = [
      {"name": "新宿駅 トイレ", "location": "東京都新宿区"},
      {"name": "渋谷駅 トイレ", "location": "東京都渋谷区"},
      {"name": "東京駅 トイレ", "location": "東京都千代田区"},
    ];

    final List<Map<String, String>> favoriteToilets = [
      {"name": "六本木ヒルズ トイレ", "location": "東京都港区"},
      {"name": "上野動物園 トイレ", "location": "東京都台東区"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
        backgroundColor: const Color(0xFFE6E0E9),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Text(
                    "A", // 頭文字（仮）
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  "ユーザー名",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "投稿したトイレ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: postedToilets
                  .take(3)
                  .map((toilet) => ListTile(
                        title: Text(toilet["name"]!),
                        subtitle: Text(toilet["location"]!),
                        leading: const Icon(Icons.location_pin),
                      ))
                  .toList(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // 一覧ページへの遷移を実装（予定）
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Placeholder(), // 一覧ページを実装予定
                    ),
                  );
                },
                child: const Text("一覧を見る"),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "お気に入りをしたトイレ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Column(
              children: favoriteToilets
                  .take(3)
                  .map((toilet) => ListTile(
                        title: Text(toilet["name"]!),
                        subtitle: Text(toilet["location"]!),
                        leading: const Icon(Icons.favorite, color: Colors.red),
                      ))
                  .toList(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // 一覧ページへの遷移を実装（予定）
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Placeholder(), // 一覧ページを実装予定
                    ),
                  );
                },
                child: const Text("一覧を見る"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
