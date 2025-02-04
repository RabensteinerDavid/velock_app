import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:velock_app/components/custom_marker.dart';
import 'package:velock_app/pages/map.dart';
import 'package:velock_app/schema/lock_history.dart';
import 'package:velock_app/util/location_service.dart';
import 'package:velock_app/util/lock_service.dart';
import '../components/lock_details.dart';
import '../main.dart';

class HistoryMapPage extends StatefulWidget {
  final LatLng zoomPosition;
  final String userLockID;
  final List<String> userLockIDs;

  const HistoryMapPage(
      {super.key,
      required this.zoomPosition,
      required this.userLockID,
      required this.userLockIDs});

  @override
  State<HistoryMapPage> createState() => _HistoryMapPageState();
}

class _HistoryMapPageState extends State<HistoryMapPage> {
  LatLng? _currentPosition;
  final LockService _lockService = LockService();
  final LocationService _locationService = LocationService();
  late Future<List<LockHistory>> locks;

  @override
  void initState() {
    super.initState();
    locks = _lockService.fetchHistoryById(widget.userLockID);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final location = await _locationService.getCurrentLocation(context);
    if (location != null) {
      setState(() {
        _currentPosition = location;
      });
    }
  }

  void _showLockDetails(LockHistory lockHistory) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return LockDetails(
            lock: lockHistory,
            lockService: _lockService,
            userLockIDs: widget.userLockIDs);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    String mapboxStyle = dotenv.env['MAPBOX_STYLE'] ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: MyApp.primaryColor.withOpacity(.3),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/velock.png',
              height: 30,
            ),
            const Spacer(),
            const Text(
              "History",
              style: TextStyle(
                color: MyApp.accentColor,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          FutureBuilder<List<LockHistory>>(
            future: locks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No history available'));
              }
              final lockHistories = snapshot.data!;
              List<Marker> lockMarkers = lockHistories.map((lockHistory) {
                return Marker(
                  point: LatLng(lockHistory.latitude, lockHistory.longitude),
                  child: GestureDetector(
                    onTap: () => _showLockDetails(lockHistory),
                    child: CustomMarker(locked: lockHistory.locked),
                  ),
                );
              }).toList();

              List<LatLng> lockPoints = lockHistories.map((lockHistory) {
                return LatLng(lockHistory.latitude, lockHistory.longitude);
              }).toList();

              return FlutterMap(
                options: MapOptions(
                  initialCenter: widget.zoomPosition,
                  initialZoom: 18,
                  minZoom: 1,
                  maxZoom: 19,
                ),
                children: [
                  TileLayer(
                    maxZoom: 19,
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/$mapboxStyle/tiles/{z}/{x}/{y}?access_token=$mapboxAccessToken',
                  ),
                  CurrentLocationLayer(),
                  MarkerLayer(markers: lockMarkers),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: lockPoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return MapPage(
                  zoomPosition: _currentPosition!,
                  userLockIDs: widget.userLockIDs);
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        ),
        shape: const CircleBorder(),
        backgroundColor: MyApp.accentColor,
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}
