import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:velock_app/components/widget_tree.dart';
import 'package:velock_app/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    loadSplash();
  }

  Future<Timer> loadSplash() async {
    return Timer(
      const Duration(seconds: 5),
      onDoneLoading,
    );
  }

  onDoneLoading() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => const WidgetTree())));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyApp.backgroundColor,
      child: Center(
        child: Lottie.asset("assets/lottie/velock_intro.json",
            fit: BoxFit.cover, width: 500),
      ),
    );
  }
}
