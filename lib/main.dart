import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mydose/welcome.dart';

import 'home/medicine/noti/mynotification.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  await NotificationService.initialize();
  tz.initializeTimeZones();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Log or handle Firebase initialization errors
    print('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WelcomeScrren(),
    );
  }
}

class FirebaseInitializedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Setup'),
      ),
      body: const Center(
        child: Text(
          'Firebase Initialized Successfully!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

