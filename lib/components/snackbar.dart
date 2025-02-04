import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:velock_app/main.dart';

void snackbar(String message, BuildContext context) {
  final snackbar = SnackBar(
    content: SizedBox(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
            },
            child: const Text(
              "To Settings",
              style: TextStyle(
                color: MyApp.accentColor,
              ),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: MyApp.accentColor,
    duration: const Duration(seconds: 5),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
