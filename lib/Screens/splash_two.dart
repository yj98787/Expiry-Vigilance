import 'dart:async';

import 'package:expiry_vigilance/Models/user_model.dart';
import 'package:expiry_vigilance/Screens/Signup_screen.dart';
import 'package:expiry_vigilance/Screens/bottom_navbar.dart';
import 'package:expiry_vigilance/Screens/home_screen.dart';
import 'package:expiry_vigilance/Services/notification_services.dart';
import 'package:expiry_vigilance/global_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreenTwo extends StatefulWidget {
  final User firebaseUser;
  final UserModel userModel;
  const SplashScreenTwo({super.key, required this.firebaseUser, required this.userModel});

  @override
  State<SplashScreenTwo> createState() => _SplashScreenTwoState();
}


class _SplashScreenTwoState extends State<SplashScreenTwo> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NotificationServices.checkAndScheduleExpiryNotifications(widget.firebaseUser.uid);
    Timer(Duration(seconds: 3),(){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context)=>MainNavigation(userModel: widget.userModel, firebaseUser: widget.firebaseUser),
        ),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColor.scaffoldColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 70,
              child: Image(
                image: AssetImage(
                  "assets/logo.png",
                ),
              ),
            ),
            SizedBox(height: 5,),
            Text("Expiry Vigilance",
              style: TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
