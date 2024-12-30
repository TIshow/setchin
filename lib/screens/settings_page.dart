import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController userInfoController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    void _updateSettings() {
      // 更新処理を仮実装
      print('ユーザー情報: ${userInfoController.text}');
      print('メール: ${emailController.text}');
      print('パスワード: ${passwordController.text}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定ページ'),
        backgroundColor: const Color(0xFFE6E0E9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ユーザー情報
            const Text(
              'ユーザー情報',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: userInfoController,
              decoration: const InputDecoration(
                hintText: 'ユーザー名を入力してください',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // ログイン情報
            const Text(
              'ログイン情報',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'メールアドレスを入力してください',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                hintText: 'パスワードを入力してください',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // パスワードを非表示
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: _updateSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1D1B20),
                  minimumSize: const Size(150, 50),
                ),
                child: const Text(
                  '更新',
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
