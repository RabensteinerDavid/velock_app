import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velock_app/main.dart';

class OpenGoogleMapsButton extends StatelessWidget {
  final double latitude;
  final double longitude;
  final bool locked;

  const OpenGoogleMapsButton({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locked,
  });

  Future<void> _openGoogleMaps() async {
    final Uri googleMapsUrl =
        Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openGoogleMaps,
        icon: const Icon(Icons.map, color: Colors.white),
        label: const Text('Open in Google Maps'),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              locked ? MyApp.primaryColor.withOpacity(.4) : MyApp.accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
