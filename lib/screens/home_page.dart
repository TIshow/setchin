import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;

  bool _isExpanded = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    print("Google Map has been loaded successfully.");
  }

  void _toggleContainer() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(30),
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
                  Icon(Icons.search, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300), // アニメーションの時間
            height: _isExpanded
                ? MediaQuery.of(context).size.height * 0.6 // 展開時の高さ
                : 60, // 通常時の高さ
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: _toggleContainer,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: !_isExpanded ? 0 : 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'この付近のトイレ',
                              style: TextStyle(fontSize: 16.0),
                            ),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      )),
                  if (_isExpanded)
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expanded content goes here!',
                              style: TextStyle(fontSize: 14.0),
                            ),
                            SizedBox(height: 10),
                            Text('Additional content can be added.'),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
