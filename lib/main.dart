import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velock_app/firebase_options.dart';
import 'package:velock_app/pages/splash_screen.dart';
import 'package:velock_app/util/local_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeLocalNotifications();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color primaryColor = Color(0xff1F3A46);
  static const Color accentColor = Color(0xffD1411F);
  static const Color neutralColor = Color(0xff000000);
  static const Color backgroundColor = Color(0xffffffff);
  static const Color warningColor = Color(0xffF20505);
  static const Color defaultColor = Color(0xff79A637);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Velock',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)),
      home: const SplashScreen(),
    );
  }
}
