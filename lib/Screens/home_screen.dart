import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_vigilance/Models/user_model.dart';
import 'package:expiry_vigilance/Provider/add_product_screen_provider.dart';
import 'package:expiry_vigilance/Screens/login_screen.dart';
import 'package:expiry_vigilance/Screens/notification_scree.dart';
import 'package:expiry_vigilance/Services/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'description_screen.dart';

class HomeScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomeScreen({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Timer? notificationTimer;
  Set<String> notifiedProducts = {};

 /* Future<void> sendNotification(String productName, DateTime expiryDate) async {
    final androidDetails = AndroidNotificationDetails(
      'expiry_alerts',
      'Expiry Notifications',
      channelDescription: 'Alerts for expiring products',
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      expiryDate.hashCode, // unique ID per product/date
      'Product Expiry Alert',
      '$productName is expiring soon!',
      notificationDetails,
    );
  }


  Future<void> checkExpiringProducts(String userId) async {
    final now = DateTime.now();
    final fiveDaysFromNow = now.add(Duration(days: 5));

    final querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('products')
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final String productId = doc.id;
      final Timestamp expiryTimestamp = data['expiryDate'];
      final DateTime expiryDate = expiryTimestamp.toDate();

      final difference = expiryDate.difference(now).inDays;

      if (difference >= 0 && difference <= 5 && !notifiedProducts.contains(productId)) {
        await sendNotification(data['productName'], expiryDate);
        notifiedProducts.add(productId);
      }
    }
  }

  void startExpiryWatcher(String userId) {
    notificationTimer = Timer.periodic(Duration(minutes: 2), (_) {
      checkExpiringProducts(userId);
    });
  }*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseMessaging.onMessage.listen((message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification!.body.toString()),
          duration: Duration(seconds: 10),
          backgroundColor: Colors.green,
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("open by on Tap"),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  void dispose() {
    notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
        drawer: Drawer(

          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                        "assets/man.png",
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.userModel.fullName ?? "User Name",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.userModel.email ?? "Email",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
                onTap: () {
                  Navigator.pop(context);// Close the drawer
                  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text("Favourites"),
                onTap: () {
                  // TODO: Navigate to Favourites Screen
                  Navigator.pop(context);
                  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FavouritesScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
                },
              ),
              ListTile(
                leading: Icon(Icons.warning_amber),
                title: Text("Product History"),
                onTap: () {
                  // TODO: Navigate to Product History
                  Navigator.pop(context);
                 // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ExpiredProductsScreen(userModel: widget.userModel, firebaseUser: widget.firebaseUser)));
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("Settings"),
                onTap: () {
                  // TODO: Navigate to Settings
                  Navigator.pop(context);
                  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
                },
              ),
              Spacer(),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.popUntil(context, (route)=>route.isFirst);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen())); // Adjust route as needed
                },
              ),
            ],
          ),
        ),

      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text(
          'Expiry Vigilance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationScreen()));
            },
            icon: Icon(Icons.notifications),
            color: Colors.white,
          ),
        ],
      ),
      body: ChangeNotifierProvider<AddProductScreenProvider>(
          create: (context)=>AddProductScreenProvider(),
        builder: (context,child){
            final provider = Provider.of<AddProductScreenProvider>(context);
            return SafeArea(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        filterButton("All", null),
                        filterButton("Medicines", "Medicines"),
                        filterButton("Daily Use Products", "Daily Use Products"),
                        filterButton("Cosmetics", "Cosmetics"),
                        filterButton("Others", "Others"),
                      ],
                    ),
                  ),
                  /*SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(child: SearchBar()),
                  SizedBox(width: 8,),
                  Icon(Icons.filter_list_alt,size: 30,)
                ],
              ),
            ),*/
                  SizedBox(height: 10,),
                  Expanded(
                    child: StreamBuilder(
                      stream:
                      provider.getProductStream(widget.firebaseUser.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No products added yet."));
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var product = snapshot.data!.docs[index].data() as Map<String,dynamic>;
                            Timestamp createdOn = product['createdOnDate']??"";
                            String imageUrl = product['productImage']??"";
                            String category = product['category']??"";
                            String description = product['description']??"";
                            String productImage = product['productImage']??"";
                            String productName = product['productName'] ?? "Unnamed";
                            Timestamp expiryTimestamp = product['expiryDate']??"";
                            DateTime expiryDate = expiryTimestamp.toDate();
                            int daysLeft = expiryDate.difference(DateTime.now()).inDays;

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                  border: Border.all(
                                    width: 2,
                                    color:
                                    (daysLeft <= 10)
                                        ? Colors.red
                                        : (daysLeft >= 15)
                                        ? Colors.green
                                        : Colors.amber,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductDescriptionScreen(
                                                userModel: widget.userModel,
                                                firebaseUser: widget.firebaseUser,
                                                productName: productName,
                                                expiryDate: expiryDate,
                                                selectValue: category,
                                                description: description,
                                                imageUrl: imageUrl,
                                                createdOn: createdOn,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Container(
                                                height: 80,
                                                width: 80,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                    (daysLeft <= 10)
                                                        ? Colors.red
                                                        : (daysLeft >= 15)
                                                        ? Colors.green
                                                        : Colors.amber,
                                                    width: 2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: productImage,
                                                  fit: BoxFit.fill,
                                                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                )

                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 0.6,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          productName,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: (daysLeft <= 10)
                                                                ? Colors.red
                                                                : (daysLeft >= 15)
                                                                ? Colors.green
                                                                : Colors.amber,
                                                          ),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Spacer(),
                                                      CircleAvatar(
                                                        backgroundColor: Colors.green,
                                                        child: Center( // 👈 centers the IconButton
                                                          child: IconButton(
                                                            icon: Icon(
                                                              product['favourite'] == true
                                                                  ? Icons.favorite
                                                                  : Icons.favorite_border,
                                                              color: product['favourite'] == true ? Colors.red : Colors.white,
                                                            ),
                                                            onPressed: () async {
                                                              final productId = snapshot.data!.docs[index].id;
                                                              await FirebaseFirestore.instance
                                                                  .collection('user')
                                                                  .doc(widget.firebaseUser.uid)
                                                                  .collection('products')
                                                                  .doc(productId)
                                                                  .update({
                                                                'favourite': !(product['favourite'] ?? false),
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      )

                                                    ],
                                                  ),
                                                ),

                                                SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    const Text(
                                                      "Expiry Date :",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10,),
                                                    Text(
                                                      (daysLeft<=0)?"Expired":"$daysLeft Days Left",
                                                      style:  TextStyle(
                                                        color: (daysLeft <= 10)
                                                            ? Colors.red
                                                            : (daysLeft >= 15)
                                                            ? Colors.green
                                                            : Colors.amber,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    /* Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: (daysLeft<=30)?Colors.red:(daysLeft>=60)?Colors.green:Colors.yellow,
                                    border: Border.all(color: const Color(0xFF6A5ACD)),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3EC4B5),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "Expiry Date",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        "$daysLeft Days Left",
                                        style: const TextStyle(
                                          color: Color(0xFF3EC4B5),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    ],
                                  ),
                                )*/
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
        },
      )
    );
  }
  Widget filterButton(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Consumer<AddProductScreenProvider>(
        builder: (context, provider, _) {
          bool isSelected = provider.selectedCategory == value;

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) {
              provider.selectedCategory = value;
              provider.notifyListeners();
            },
          );
        },
      ),
    );
  }
}
