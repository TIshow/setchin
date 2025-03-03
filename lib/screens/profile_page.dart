import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ここで AuthService をインポート
import '../services/auth_service.dart';
import 'login_page.dart';
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

    final authService = AuthService();

    return StreamBuilder<User?>(
      // FirebaseAuthのログイン状態を監視
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 読み込み中（ログイン状態の判定中）はローディング表示
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          // ユーザーがnull = 未ログイン → ログインページへ
          return const LoginPage();
        }

        // ログイン中の場合 → プロフィール画面を表示
        return Scaffold(
          appBar: AppBar(
            title: const Text('プロフィール'),
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
                      .map(
                        (toilet) => ListTile(
                          title: Text(toilet["name"]!),
                          subtitle: Text(toilet["location"]!),
                          leading: const Icon(Icons.location_pin),
                        ),
                      )
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
                          builder: (context) => const Placeholder(), // 仮
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
                      .map(
                        (toilet) => ListTile(
                          title: Text(toilet["name"]!),
                          subtitle: Text(toilet["location"]!),
                          leading: const Icon(Icons.favorite),
                        ),
                      )
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
                          builder: (context) => const Placeholder(), // 仮
                        ),
                      );
                    },
                    child: const Text("一覧を見る"),
                  ),
                ),
                // spacer
                const SizedBox(height: 80),
                // ログアウトボタン
                ElevatedButton(
                  // 真ん中に
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    try {
                      await authService.signOut();
                    } catch (e) {
                      // エラーハンドリング: ダイアログ表示など
                      debugPrint('$e');
                    }
                  },
                  child: const Text('ログアウト'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}