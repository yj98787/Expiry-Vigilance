import 'dart:developer';
import 'package:expiry_vigilance/Screens/splash_two.dart';
import 'package:expiry_vigilance/Services/notification_services.dart';
import 'package:expiry_vigilance/Models/firebase_helper.dart';
import 'package:expiry_vigilance/Models/user_model.dart';
import 'package:expiry_vigilance/Screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp();
  await NotificationServices.initialize();

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    log("User already logged in");
    UserModel? thisUserModel = await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    } else {
      runApp(const MyApp());
    }
  } else {
    log("No logged-in user");
    runApp(const MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}

class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenTwo(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
