import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final AuthService _authService = AuthService();

    // メッセージダイアログを表示する
    void _showMessageDialog(String message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    void _updateSettings() async {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        _showMessageDialog('メールアドレスとパスワードを入力してください');
        return;
      }

      // 🔥 メールとパスワードを Firebase に更新 🔥
      String? errorMessage =
          await _authService.updateEmailAndPassword(email, password);

      if (errorMessage == null) {
        _showMessageDialog('認証メールを送信いたしました。');
      } else {
        _showMessageDialog(errorMessage);
      }
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
