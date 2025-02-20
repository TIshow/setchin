import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatelessWidget {
  final Set<Marker> markers;
  final Function(GoogleMapController) onMapCreated;

  const MapView({
    super.key,
    required this.markers,
    required this.onMapCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(35.6895, 139.6917), // Tokyo coordinates
        zoom: 15,
      ),
      onMapCreated: onMapCreated,
      markers: markers,
      zoomControlsEnabled: false,
    );
  }
}