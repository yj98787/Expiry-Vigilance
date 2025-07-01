import 'dart:async';

import 'package:expiry_vigilance/Screens/Signup_screen.dart';
import 'package:expiry_vigilance/global_colors.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 5),(){
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context)=>SignupScreen(),
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
