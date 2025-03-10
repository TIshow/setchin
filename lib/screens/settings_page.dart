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
    void showMessageDialog(String message) {
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

    bool isValidEmail(String email) {
      return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
          .hasMatch(email);
    }

    bool isValidPassword(String password) {
      return password.length >= 6;
    }

    void updateSettings() async {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      if (!isValidEmail(email)) {
        showMessageDialog('正しいメールアドレスを入力してください');
        return;
      }
      if (!isValidPassword(password)) {
        showMessageDialog('パスワードは6文字以上で入力してください');
        return;
      }
      if (email.isEmpty || password.isEmpty) {
        showMessageDialog('メールアドレスとパスワードを入力してください');
        return;
      }

      // 🔥 メールとパスワードを Firebase に更新 🔥
      String? errorMessage =
          await _authService.updateEmailAndPassword(email, password);

      if (errorMessage == null) {
        showMessageDialog('認証メールを送信いたしました。');
      } else {
        showMessageDialog(errorMessage);
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
                onPressed: updateSettings,
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
