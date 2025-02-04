import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:velock_app/components/lock_card.dart';
import 'package:velock_app/main.dart';
import 'package:velock_app/pages/lock_setting.dart';
import 'package:velock_app/pages/map.dart';
import 'package:velock_app/schema/lock.dart';
import 'package:velock_app/util/auth.dart';
import 'package:velock_app/util/firebase_service.dart';
import 'package:velock_app/util/lock_service.dart';
import '../components/map_preview.dart';
import '../util/location_service.dart';
import 'login_register_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LockService _lockService = LockService();
  final LocationService _locationService = LocationService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<int> _currentLockIndexNotifier = ValueNotifier<int>(0);
  final FirebaseService _firebaseService = FirebaseService();
  LatLng? _currentPosition;
  List<Lock> locks = [];
  List<String> userLockIDs = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserLocks();
  }

  Future<void> _getCurrentLocation() async {
    final location = await _locationService.getCurrentLocation(context);
    if (location != null) {
      setState(() {
        _currentPosition = location;
      });
    }
  }

  Future<void> _fetchLocksForUser(List<String> lockIDs) async {
    try {
      final allLocks = await _lockService.fetchLocksByIds(lockIDs);
      setState(() {
        locks = allLocks.toList();
      });
    } catch (e) {
      print("Error fetching locks: $e");
    }
  }

  Future<void> _loadUserLocks() async {
    try {
      final userUID = Auth().getUserUid()!;
      final lockIDs = await _firebaseService.loadLockID(userUID);
      _fetchLocksForUser(lockIDs);
      setState(() {
        userLockIDs = lockIDs;
      });
    } catch (e) {
      print("Error loading user locks: $e");
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await Auth().signOut();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthenticationPage(),
      ),
    );
  }

  @override
  void dispose() {
    _currentLockIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("User email:"),
              accountEmail: Text(Auth().getUserEmail() ?? "No email"),
              decoration: const BoxDecoration(
                color: MyApp.accentColor,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Lottie.asset("assets/lottie/profile.json",
                    fit: BoxFit.fitHeight),
              ),
            ),
            ListTile(
              title: const Text('Lock Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LockSetting(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                _signOut(context);
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [MyApp.neutralColor, MyApp.primaryColor],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Nearby Locks',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            userLockIDs.isNotEmpty
                ? StreamBuilder<List<Lock>>(
                    stream: _lockService.listenToLocksByIds(userLockIDs),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text("Error loading locks"));
                      }

                      if (snapshot.hasData) {
                        locks = snapshot.data!;
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            ValueListenableBuilder<int>(
                              valueListenable: _currentLockIndexNotifier,
                              builder: (context, currentLockIndex, child) {
                                return MapPreview(
                                  currentPosition: locks.isNotEmpty
                                      ? LatLng(
                                          locks[currentLockIndex].latitude,
                                          locks[currentLockIndex].longitude,
                                        )
                                      : _currentPosition ??
                                          const LatLng(48.366251, 14.53699),
                                  locks: locks,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MapPage(
                                          zoomPosition: LatLng(
                                            locks[currentLockIndex].latitude,
                                            locks[currentLockIndex].longitude,
                                          ),
                                          userLockIDs: userLockIDs,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CarouselSlider(
                              options: CarouselOptions(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                enlargeCenterPage: true,
                                enableInfiniteScroll:
                                    locks.length == 1 ? false : true,
                                viewportFraction: locks.length == 1 ? 1 : 0.6,
                                onPageChanged: (index, reason) {
                                  _currentLockIndexNotifier.value = index;
                                },
                              ),
                              items: locks.map((lock) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return LockCard(
                                        lock: lock, userLockIDs: userLockIDs);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      } else {
                        return const Center(child: Text("No locks available"));
                      }
                    },
                  )
                : GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return const LockSetting();
                          },
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            const begin = Offset(-1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                                position: offsetAnimation, child: child);
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 190.0, bottom: 190.0),
                      child: Column(
                        children: [
                          Lottie.asset(
                            "assets/lottie/loader.json",
                            fit: BoxFit.cover,
                            width: 120,
                          ),
                          const Center(
                            child: Text(
                              'No locks found. Add a lock ID to load your locks.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
