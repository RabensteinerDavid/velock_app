import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:velock_app/components/snackbar.dart';

class LocationService {
  bool _isRequestingPermission = false;

  Future<LatLng?> getCurrentLocation(BuildContext context) async {
    if (_isRequestingPermission) return null;
    _isRequestingPermission = true;

    try {
      var statusLocation = await Permission.location.status;
      if (statusLocation.isGranted) {
        return await _getCurrentLocation();
      }
      if (statusLocation.isDenied || statusLocation.isPermanentlyDenied) {
        final currentPermissionStatus = await Permission.location.status;

        if (currentPermissionStatus.isDenied) {
          var geolocatorPermission = await Geolocator.checkPermission();
          if (geolocatorPermission == LocationPermission.denied) {
            geolocatorPermission = await Geolocator.requestPermission();
          }
          if (geolocatorPermission == LocationPermission.deniedForever) {
            snackbar("To show your location, please allow location access.",
                context);
          } else {
            return await _getCurrentLocation();
          }
        } else {
          snackbar(
              "To show your location, please allow location access.", context);
        }
      }
    } catch (e) {
      snackbar("There is an error with the location $e", context);
    } finally {
      _isRequestingPermission = false;
    }

    return null;
  }

  Future<LatLng> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }
}
