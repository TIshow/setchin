// 
//  set_username_page.dart
// このファイルは、ユーザー名を設定する画面を表示するためのファイルです。
//

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import '../components/templates/bottom_nav_layout.dart';

class SetUsernamePage extends StatefulWidget {
  final String userId;
  const SetUsernamePage({super.key, required this.userId});

  @override
  State<SetUsernamePage> createState() => _SetUsernamePageState();
}

class _SetUsernamePageState extends State<SetUsernamePage> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  String _errorMessage = '';

  Future<void> _saveUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() {
        _errorMessage = 'ユーザーネームを入力してください';
      });
      return;
    }

    try {
      await _authService.saveUsername(widget.userId, username);
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
        _errorMessage = '保存中にエラーが発生しました';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ユーザーネームを設定')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'ユーザーネーム')),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty) Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _saveUsername, child: const Text('保存して続行')),
          ],
        ),
      ),
    );
  }
}