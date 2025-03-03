import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  // メールアドレス & パスワード入力用
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // ログイン状態を監視
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // 1) 通信中はローディング表示
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2) ユーザー情報がある → ログイン済みなので HomePage へ
        if (snapshot.hasData) {
          return const HomePage();
        }

        // 3) 未ログインならログイン画面を表示
        return Scaffold(
          appBar: AppBar(
            title: const Text('ログイン'),
          ),
          body: Center(
            child: Container (
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
              child: Column(
                children: [
                  // メールアドレス入力
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'メールアドレス',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // パスワード入力
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'パスワード',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  // メールアドレスでログイン
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () async {
                      try {
                        await _authService.signInWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      } catch (e) {
                        // エラーハンドリング: ダイアログ表示など
                        debugPrint('$e');
                      }
                    },
                    child: const Text('メールアドレスでログイン'),
                  ),
                  const SizedBox(height: 8),
                  // メールアドレスで新規登録
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () async {
                      try {
                        await _authService.signUpWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      } catch (e) {
                        debugPrint('$e');
                      }
                    },
                    child: const Text('メールアドレスで新規登録'),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  // Googleログイン
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () async {
                      try {
                        await _authService.signInWithGoogle();
                      } catch (e) {
                        debugPrint('$e');
                      }
                    },
                    child: const Text('Googleアカウントで登録・ログイン'),
                  ),
                ],
              ),
            ),
            ),
          ),
          ),
        );
      },
    );
  }
}