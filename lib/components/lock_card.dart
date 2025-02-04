import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:velock_app/main.dart';
import 'package:velock_app/schema/lock.dart';

import '../pages/map.dart';
import '../util/local_notifications.dart';

class LockCard extends StatefulWidget {
  final Lock lock;
  final List<String> userLockIDs;

  const LockCard({
    super.key,
    required this.lock,
    required this.userLockIDs,
  });

  @override
  State<LockCard> createState() => _LockCardState();
}

class _LockCardState extends State<LockCard> {
  String _address = "Loading address...";

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  @override
  void didUpdateWidget(covariant LockCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lock.latitude != widget.lock.latitude ||
        oldWidget.lock.longitude != widget.lock.longitude) {
      _fetchAddress();
    }
    if (oldWidget.lock.locked && !widget.lock.locked) {
      showNotification("Your lock ${widget.lock.id} has been unlocked.");
    }
  }

  void showNotification(var message) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id', 'your_channel_name',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    const darwinNotificationDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: darwinNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
        0, 'Velock', message, notificationDetails,
        payload: 'lock_status_change');
  }

  Future<void> _fetchAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.lock.latitude,
        widget.lock.longitude,
      );

      if (mounted) {
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
          setState(() {
            _address = addressParts.isNotEmpty
                ? addressParts.join(', ')
                : "Address not available.";
          });
        } else {
          setState(() {
            _address = "Address not found.";
          });
        }
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(
              zoomPosition: LatLng(widget.lock.latitude, widget.lock.longitude),
              userLockIDs: widget.userLockIDs,
            ),
          ),
        );
      },
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: widget.lock.locked
                        ? MyApp.primaryColor.withOpacity(.8)
                        : MyApp.accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Lock ID: ${widget.lock.id}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      Icon(
                        widget.lock.locked ? Icons.lock : Icons.lock_open,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
