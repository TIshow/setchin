import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anonymous Login Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  Future<void> anonymousSignIn() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      setState(() {
        user = userCredential.user;
      });
    } catch (e) {
      print("Failed to sign in anonymously: $e");
    }
  }

  Future<void> linkWithEmailAndPassword(String email, String password) async {
    try {
      if (user != null && user!.isAnonymous) {
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        UserCredential userCredential =
            await user!.linkWithCredential(credential);
        setState(() {
          user = userCredential.user;
        });
        print("Anonymous account linked with email and password.");
      }
    } catch (e) {
      print("Failed to link anonymous account: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonymous Login'),
      ),
      body: Center(
        child: user == null
            ? ElevatedButton(
                onPressed: anonymousSignIn,
                child: const Text('Sign in Anonymously'),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(user!.isAnonymous
                      ? 'Signed in anonymously'
                      : 'Signed in as ${user!.email}'),
                  const SizedBox(height: 20),
                  if (user!.isAnonymous) ...[
                    ElevatedButton(
                      onPressed: () async {
                        // Replace with actual email and password inputs
                        String email = "test@example.com";
                        String password = "password123";
                        await linkWithEmailAndPassword(email, password);
                      },
                      child: const Text('Link with Email/Password'),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
