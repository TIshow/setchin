import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '../screens/profile_page.dart';

class BottomNavLayout extends StatefulWidget {
  final int currentIndex;

  const BottomNavLayout({super.key, required this.currentIndex});

  @override
  State<BottomNavLayout> createState() => _BottomNavLayoutState();
}

class _BottomNavLayoutState extends State<BottomNavLayout> {
  final List<Widget> _pages = [
    const HomePage(),
    const Placeholder(), // 後ほど追加されるページ
    const Placeholder(), // 後ほど追加されるページ
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index != widget.currentIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BottomNavLayout(currentIndex: index),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[widget.currentIndex], // 現在のページを表示
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE6E0E9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFFE6E0E9),
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.location_pin, color: Color(0xFF1D1B20)),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, color: Color(0xFF1D1B20)),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, color: Color(0xFF1D1B20)),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle, color: Color(0xFF1D1B20)),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
