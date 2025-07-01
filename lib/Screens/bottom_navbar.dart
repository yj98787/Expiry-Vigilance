import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:expiry_vigilance/Screens/add_product_screen.dart';
import 'package:expiry_vigilance/Screens/favourite_product_screen.dart';
import 'package:expiry_vigilance/Screens/profile_screen.dart';
import 'package:flutter/material.dart';

// Import your screen widgets here
import 'expiry_product_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expiry_vigilance/Models/user_model.dart';

class MainNavigation extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MainNavigation({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser),
      ExpiredProductsScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser),
      AddProductScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser),
      FavouritesScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: Colors.transparent,
        color: Colors.green,
        animationDuration: Duration(milliseconds: 300),
        items: const [
          Icon(Icons.home, color: Colors.white),
          Icon(Icons.warning_amber, color: Colors.white),
          Icon(Icons.add, color: Colors.white),
          Icon(Icons.favorite, color: Colors.white),
          Icon(Icons.person, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
