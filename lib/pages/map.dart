import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:velock_app/components/custom_marker.dart';
import 'package:velock_app/pages/home_page.dart';
import 'package:velock_app/util/location_service.dart';
import 'package:velock_app/schema/lock.dart';
import 'package:velock_app/util/lock_service.dart';
import '../components/lock_details.dart';
import '../main.dart';

class MapPage extends StatefulWidget {
  final LatLng zoomPosition;
  final List<String> userLockIDs;

  const MapPage(
      {super.key, required this.zoomPosition, required this.userLockIDs});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentPosition;
  final LockService _lockService = LockService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
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

  void _showLockDetails(Lock lock) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return LockDetails(
            lock: lock,
            lockService: _lockService,
            userLockIDs: widget.userLockIDs);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          MapWidget(
            currentPosition: _currentPosition,
            lockService: _lockService,
            onLockTap: _showLockDetails,
            zoomPosition: widget.zoomPosition,
            userLockIDs: widget.userLockIDs,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return const HomePage();
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
        child: const Icon(Icons.home, color: Colors.white),
      ),
    );
  }
}

class MapWidget extends StatelessWidget {
  final LatLng? currentPosition;
  final LockService lockService;
  final Function(Lock) onLockTap;
  final LatLng zoomPosition;
  final List<String> userLockIDs;

  const MapWidget({
    super.key,
    required this.currentPosition,
    required this.lockService,
    required this.onLockTap,
    required this.zoomPosition,
    required this.userLockIDs,
  });

  @override
  Widget build(BuildContext context) {
    String mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    String mapboxStyle = dotenv.env['MAPBOX_STYLE'] ?? '';

    return FlutterMap(
      options: MapOptions(
        initialCenter: zoomPosition,
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
        StreamBuilder<List<Lock>>(
          stream: lockService.listenToLocksByIds(userLockIDs),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No locks available'));
            }
            final locks = snapshot.data!;
            List<Marker> lockMarkers = locks.map((lock) {
              return Marker(
                point: LatLng(lock.latitude, lock.longitude),
                child: GestureDetector(
                  onTap: () => onLockTap(lock),
                  child: CustomMarker(locked: lock.locked),
                ),
              );
            }).toList();
            return MarkerLayer(markers: lockMarkers);
          },
        ),
      ],
    );
  }
}
