import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/user_model.dart';
import 'description_screen.dart';

class FavouritesScreen extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const FavouritesScreen({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Favourite Products",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(firebaseUser.uid)
            .collection('products')
            .where('favourite', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No favourite products found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final product = snapshot.data!.docs[index];
              final data = product.data() as Map<String, dynamic>;
              final productName = data['productName'] ?? 'Unnamed';
              final productImage = data['productImage'] ?? '';
              final expiryDate = (data['expiryDate'] as Timestamp).toDate();
              final createdOn = (data['createdOnDate'] as Timestamp);
              final category = data['category'] ?? '';
              final description = data['description'] ?? '';
              final daysLeft = expiryDate.difference(DateTime.now()).inDays;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDescriptionScreen(
                        userModel: userModel,
                        firebaseUser: firebaseUser,
                        productName: productName,
                        expiryDate: expiryDate,
                        selectValue: category,
                        description: description,
                        imageUrl: productImage,
                        createdOn: createdOn,
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  color: Colors.white,
                  elevation: 3,
                  child: ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: productImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => CircularProgressIndicator(),
                      errorWidget: (_, __, ___) => Icon(Icons.broken_image),
                    ),
                    title: Text(
                      productName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (daysLeft <= 10)
                            ? Colors.red
                            : (daysLeft >= 15)
                            ? Colors.green
                            : Colors.amber,
                      ),
                    ),
                    subtitle: Text(
                      (daysLeft <= 0)
                          ? "Expired"
                          : "$daysLeft Days Left",
                      style: TextStyle(
                        color: (daysLeft <= 10)
                            ? Colors.red
                            : (daysLeft >= 15)
                            ? Colors.green
                            : Colors.amber,
                      ),
                    ),
                    trailing: Icon(Icons.favorite, color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
