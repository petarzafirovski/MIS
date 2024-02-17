import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lab3_main/models/exam_model.dart';

class MapScreen extends StatefulWidget {
  final List<Exam> exams;

  const MapScreen({Key? key, required this.exams}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  Set<Marker> _markers = {};

  void _initMarkers() {
    final Set<Marker> markers = {};
    for (final exam in widget.exams) {
      final coords = exam.laboratory.coordinates.split(',');
      if (coords.length == 2) {
        final lat = double.tryParse(coords[0]);
        final lng = double.tryParse(coords[1]);
        if (lat != null && lng != null) {
          final marker = Marker(
            markerId: MarkerId(exam.course),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: exam.course,
              snippet: 'Професор: ${exam.professor}',
            ),
          );
          markers.add(marker);
        }
      }
    }
    setState(() {
      _markers = markers;
    });
  }


  @override
  void initState() {
    super.initState();
    _initMarkers();
  }

  @override
  Widget build(BuildContext context) {
    LatLng initialCameraPosition = const LatLng(0, 0); // Default fallback
    if (_markers.isNotEmpty) {
      initialCameraPosition = _markers.first.position;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Exam Locations')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialCameraPosition,
          zoom: 14,
        ),
        markers: _markers,
      ),
    );
  }

}
