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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const HomePage(); // Navigate to HomePage if logged in
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Anonymous Login'),
            ),
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await _authService.signInAnonymously();
                  } catch (e) {
                    print(e); // Handle error properly in a real app
                  }
                },
                child: const Text('Sign in Anonymously'),
              ),
            ),
          );
        }
      },
    );
  }
}
