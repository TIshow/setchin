import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.ios,
  );
  await dotenv.load(fileName: ".env"); // Load the .env
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
      home: const AuthWrapper(),
    );
  }
}

// A wrapper to handle redirection based on login state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return const HomePage(); // Navigate to HomePage if logged in
        } else {
          return const LoginPage(); // Show LoginPage if not logged in
        }
      },
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

  Future<void> anonymousSignIn() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      print("Failed to sign in anonymously: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonymous Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: anonymousSignIn,
          child: const Text('Sign in Anonymously'),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;

  // Check Google Maps has loaded properly
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    print("Google Map has been loaded successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(35.6895, 139.6917), // Tokyo coordinates
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
          ),
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "絞り込み検索",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.grey), // Search icon
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E0E9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'この付近のトイレ',
                          style: TextStyle(
                              fontSize: 16.0), // Customize font size if needed
                        ),
                        Icon(
                          Icons.keyboard_arrow_up, // Upwards arrow icon
                          color: Colors.grey, // Customize color if needed
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E0E9), // Background color
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2), // Shadow color
                        spreadRadius: 2, // Spread of the shadow
                        blurRadius: 8, // Blur effect
                        offset: const Offset(
                            0, -3), // Shadow position: slightly above
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: const Color(0xFFE6E0E9),
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    items: const [
                      BottomNavigationBarItem(
                        icon:
                            Icon(Icons.location_pin, color: Color(0xFF1D1B20)),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_circle, color: Color(0xFF1D1B20)),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon:
                            Icon(Icons.notifications, color: Color(0xFF1D1B20)),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.account_circle,
                            color: Color(0xFF1D1B20)),
                        label: '',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
