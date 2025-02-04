import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:velock_app/pages/history_map.dart';
import '../main.dart';
import '../schema/lock.dart';
import '../util/lock_service.dart';
import 'button_to_google_maps.dart';

class LockDetails extends StatefulWidget {
  final Lock lock;
  final LockService lockService;
  final List<String> userLockIDs;

  const LockDetails(
      {super.key,
      required this.lock,
      required this.lockService,
      required this.userLockIDs});

  @override
  _LockDetailsState createState() => _LockDetailsState();
}

class _LockDetailsState extends State<LockDetails> {
  String _address = "Loading address...";
  late Lock _currentLock;

  @override
  void initState() {
    super.initState();
    _currentLock = widget.lock;
    _fetchAddress(LatLng(_currentLock.latitude, _currentLock.longitude));
  }

  Future<void> _fetchAddress(LatLng position) async {
    setState(() {
      _address = "Loading address...";
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          if (placemarks.isNotEmpty) {
            final Placemark place = placemarks.first;
            List<String> addressParts = [];

            if (place.street != null && place.street!.isNotEmpty) {
              addressParts.add(place.street!);
            }
            if (place.locality != null && place.locality!.isNotEmpty) {
              addressParts.add(place.locality!);
            }
            if (place.postalCode != null && place.postalCode!.isNotEmpty) {
              addressParts.add(place.postalCode!);
            }
            if (place.country != null && place.country!.isNotEmpty) {
              addressParts.add(place.country!);
            }
            if (addressParts.isEmpty) {
              _address = "Address not available.";
            } else {
              _address = addressParts.join(', ');
            }
          } else {
            _address = "Address not found.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address = "Error retrieving address.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 350,
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<List<Lock>>(
        stream: widget.lockService.listenToLocks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SizedBox());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No locks available'));
          }

          final updatedLock = snapshot.data!.firstWhere(
            (lockItem) => lockItem.id == widget.lock.id,
            orElse: () => widget.lock,
          );

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_currentLock.latitude != updatedLock.latitude ||
                _currentLock.longitude != updatedLock.longitude) {
              _currentLock = updatedLock;
              _fetchAddress(
                  LatLng(updatedLock.latitude, updatedLock.longitude));
            }
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: updatedLock.locked
                            ? MyApp.defaultColor.withOpacity(.8)
                            : MyApp.accentColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text(
                            'Lock ID: ${widget.lock.id}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            updatedLock.locked ? Icons.lock : Icons.lock_open,
                            color: Colors.white,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _address,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: updatedLock.locked
                              ? MyApp.defaultColor.withOpacity(.8)
                              : MyApp.accentColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Latitude: ${updatedLock.latitude} Longitude: ${updatedLock.longitude}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    OpenGoogleMapsButton(
                      latitude: updatedLock.latitude,
                      longitude: updatedLock.longitude,
                      locked: updatedLock.locked,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.history, color: Colors.white),
                        label: const Text('Show History'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyApp.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HistoryMapPage(
                                zoomPosition: LatLng(
                                  widget.lock.latitude,
                                  widget.lock.longitude,
                                ),
                                userLockID: widget.lock.id,
                                userLockIDs: widget.userLockIDs,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
