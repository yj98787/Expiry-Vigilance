import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_vigilance/Models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'description_screen.dart';

class ExpiredProductsScreen extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const ExpiredProductsScreen({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expired Products",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("user")
            .doc(firebaseUser.uid)
            .collection("products")
            .where("expiryDate", isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
            .orderBy("expiryDate")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No expired products."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              String productName = data['productName'] ?? "Unnamed";
              String productImage = data['productImage'] ?? "";
              String category = data['category'] ?? "";
              String description = data['description'] ?? "";
              Timestamp expiryTimestamp = data['expiryDate'];
              Timestamp createdOn = data['createdOnDate'];
              DateTime expiryDate = expiryTimestamp.toDate();
              int daysAgo = DateTime.now().difference(expiryDate).inDays;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDescriptionScreen(
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
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: productImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Expired $daysAgo day${daysAgo == 1 ? '' : 's'} ago",
                                style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
