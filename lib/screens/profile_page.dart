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
  String _username = "ユーザー名";
  bool _isLoading = true;
  String? _profileImageUrl;
  List<Map<String, dynamic>> _postedToilets = [];
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// 🔄 ユーザーデータを更新
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true; // ✅ ローディング開始
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("👤 ユーザーID: ${user.uid}");

        String? username = await _authService.getUsername(user.uid);
        String? profileImageUrl = await _authService.getProfileImageUrl(user.uid);
        List<Map<String, dynamic>> toilets = await _authService.getUserToilets(user.uid);
        List<Map<String, dynamic>> favorites = await _authService.getUserFavorites(user.uid);

        print("📝 投稿データ取得結果: ${toilets.length} 件");
        print("⭐ お気に入り取得結果: ${favorites.length} 件");

        setState(() {
          _username = username ?? "未設定";
          _profileImageUrl = profileImageUrl;
          _postedToilets = toilets;
          _favorites = favorites;
          _isLoading = false; // ✅ ローディング終了
        });
      } else {
        setState(() {
          _isLoading = false; // ✅ ユーザーがいない場合もローディング終了
        });
      }
    } catch (e) {
      print("🔥 ユーザーデータ取得エラー: $e");
      setState(() {
        _isLoading = false; // ✅ エラー時もローディング終了
      });
    }
  }

  /// 🔄 更新ボタンを押したときの処理
  Future<void> _refreshUserData() async {
    await _fetchUserData();
    if (!mounted) return; // 🔄 画面が破棄されていたら処理を中断
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('プロフィール情報を更新しました')),
    );
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
              // 🔄 更新ボタン
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "更新",
                onPressed: _refreshUserData,
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const SettingsPage(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String? newImageUrl = await _authService.uploadProfileImage();
                        if (newImageUrl != null) {
                          setState(() {
                            _profileImageUrl = newImageUrl;
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _profileImageUrl == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
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
                          onPressed: () async {
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
                          },
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
                _buildToiletList(_favorites),
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