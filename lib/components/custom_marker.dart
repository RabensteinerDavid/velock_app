import 'package:flutter/material.dart';
import 'package:velock_app/main.dart';

class CustomMarker extends StatelessWidget {
  final bool locked;

  const CustomMarker({
    super.key,
    required this.locked,
  });

  @override
  Widget build(BuildContext context) {
    Color innerColor = locked ? MyApp.defaultColor : MyApp.accentColor;
    IconData icon = locked ? Icons.lock : Icons.lock_open;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 20,
          width: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          height: 18,
          width: 18,
          decoration: BoxDecoration(
            color: innerColor,
            shape: BoxShape.circle,
          ),
        ),
        Icon(
          icon,
          size: 15,
          color: Colors.white,
        ),
      ],
    );
  }
}
