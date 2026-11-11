import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapaChamado extends StatelessWidget {
  final double lat;
  final double lng;
  final String titulo;
  final double altura;

  const MapaChamado({
    super.key,
    required this.lat,
    required this.lng,
    required this.titulo,
    this.altura = 180,
  });

  @override
  Widget build(BuildContext context) {
    final pos = LatLng(lat, lng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: altura,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: pos, zoom: 15),
          markers: {
            Marker(
              markerId: const MarkerId('chamado'),
              position: pos,
              infoWindow: InfoWindow(title: titulo),
            ),
          },
          zoomControlsEnabled: false,
          liteModeEnabled: true,
          myLocationButtonEnabled: false,
        ),
      ),
    );
  }
}