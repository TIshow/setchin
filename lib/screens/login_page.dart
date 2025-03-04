import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'sign_up_page.dart';
import 'set_username_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        // 通信中はローディング表示
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ユーザー情報がある = ログイン済み → HomePage に遷移
        if (snapshot.hasData) {
          final user = snapshot.data!;
          return FutureBuilder<String?>(
            future: _authService.getUsername(user.uid),
            builder: (context, usernameSnapshot) {
              if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (usernameSnapshot.data == null) {
                return SetUsernamePage(userId: user.uid);
              }
              return const HomePage();
            },
          );
        }

        // 未ログインの場合 → ログイン画面を表示
        return Scaffold(
          appBar: AppBar(
            title: const Text('ログイン'),
          ),
          body: Center(
            child: Container(
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
                            debugPrint('$e');
                          }
                        },
                        child: const Text('メールアドレスでログイン'),
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
                          } catch (e) {
                            debugPrint('$e');
                          }
                        },
                        child: const Text('Googleアカウントでログイン'),
                      ),
                      const SizedBox(height: 24),

                      // 新規登録画面へ
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text('アカウントをお持ちでない方はこちら'),
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