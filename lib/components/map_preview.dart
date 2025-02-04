import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import '../components/custom_marker.dart';
import '../schema/lock.dart';

class MapPreview extends StatefulWidget {
  final LatLng currentPosition;
  final List<Lock> locks;
  final VoidCallback onTap;

  const MapPreview({
    super.key,
    required this.currentPosition,
    required this.locks,
    required this.onTap,
  });

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  late final MapController _mapController;
  final double _currentZoom = 12;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(MapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPosition != widget.currentPosition) {
      _mapController.move(widget.currentPosition, _currentZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    String mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    String mapboxStyle = dotenv.env['MAPBOX_STYLE'] ?? '';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: IgnorePointer(
            ignoring: true,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.currentPosition,
                initialZoom: _currentZoom,
                minZoom: 1,
                maxZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/$mapboxStyle/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken',
                ),
                CurrentLocationLayer(),
                MarkerLayer(
                  markers: widget.locks.map((lock) {
                    return Marker(
                      point: LatLng(lock.latitude, lock.longitude),
                      child: CustomMarker(locked: lock.locked),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
