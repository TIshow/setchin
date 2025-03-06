// 
// sign_up_page.dart
// 新規登録画面用のページ
//

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'set_username_page.dart';
import '../components/templates/bottom_nav_layout.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _errorMessage = '';

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'パスワードが一致しません';
      });
      return;
    }

    try {
      final user = await _authService.signUpWithEmail(email, password);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                SetUsernamePage(userId: user.uid),
            transitionDuration: Duration.zero, // スライドなし
            reverseTransitionDuration: Duration.zero, // 戻るときもスライドなし
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新規登録'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
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
                  const SizedBox(height: 16),

                  // パスワード確認
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'パスワード（確認）',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  // エラーメッセージ表示
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // メールアドレスで新規登録
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: _signUp,
                    child: const Text('メールアドレスで登録'),
                  ),
                  const SizedBox(height: 24),

                  // 仕切り線
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
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const BottomNavLayout(currentIndex: 0), // HomePage ではなく BottomNavLayout
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      } catch (e) {
                        setState(() {
                          _errorMessage = e.toString();
                        });
                      }
                    },
                    child: const Text('Googleアカウントで登録'),
                  ),
                  const SizedBox(height: 24),

                  // ログイン画面へ
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              const LoginPage(),
                          transitionDuration: Duration.zero, // スライドなし
                          reverseTransitionDuration: Duration.zero, // 戻るときもスライドなし
                        ),
                      );
                    },
                    child: const Text('すでにアカウントをお持ちの方はこちら'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}