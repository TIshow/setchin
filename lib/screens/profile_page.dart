// 
// profile_page.dart
// プロフィール画面用のページ
//

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  String _username = "ユーザー名"; // 初期値
  bool _isLoading = true;
  // 投稿したトイレ
  List<Map<String, dynamic>> _postedToilets = [];
  // お気に入り登録したトイレ
  List<Map<String, dynamic>> _favorites = []; // お気に入りリスト

  @override
  void initState() {
    super.initState();
    _fetchUsername();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {

      String? username = await _authService.getUsername(user.uid);
      List<Map<String, dynamic>> toilets = await _authService.getUserToilets(user.uid);
      List<Map<String, dynamic>> favorites = await _authService.getUserFavorites(user.uid); // お気に入り取得

      setState(() {
        _username = username ?? "未設定";
        _postedToilets = toilets;
        _favorites = favorites;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? username = await _authService.getUsername(user.uid);
      setState(() {
        _username = username ?? "未設定"; // `null` の場合デフォルト値をセット
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? newUsername = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempUsername = _username;
        return AlertDialog(
          title: const Text("ユーザー名を変更"),
          content: TextField(
            onChanged: (value) {
              tempUsername = value;
            },
            decoration: const InputDecoration(hintText: "新しいユーザー名"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("キャンセル"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempUsername),
              child: const Text("変更"),
            ),
          ],
        );
      },
    );

    if (newUsername != null && newUsername.isNotEmpty) {
      await _authService.updateUsername(user.uid, newUsername);
      setState(() {
        _username = newUsername;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return const LoginPage();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('プロフィール'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SettingsPage(),
                      transitionDuration: Duration.zero, // スライドなし
                      reverseTransitionDuration: Duration.zero, // 戻るときもスライドなし
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Text(
                        "A", // 仮のアイコン
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: _changeUsername,
                          child: const Text("ユーザー名を変更"),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "投稿したトイレ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildToiletList(_postedToilets),
                const SizedBox(height: 30),
                const Text(
                  "お気に入りをしたトイレ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildToiletList(_favorites), // お気に入りリストを表示
                const SizedBox(height: 80),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    await _authService.signOut();
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

  Widget _buildToiletList(List<Map<String, dynamic>> toilets) {
    if (toilets.isEmpty) {
      return const Text("投稿がありません", style: TextStyle(color: Colors.grey));
    }
    return Column(
      children: toilets.map((toilet) {
        return ListTile(
          title: Text(toilet["name"] ?? "名称不明"),
          subtitle: Text(toilet["location"] ?? "場所不明"),
          trailing: Text("⭐️ ${toilet["rating"] ?? 0}"),
        );
      }).toList(),
    );
  }
}