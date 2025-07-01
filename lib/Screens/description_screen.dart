import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_vigilance/Models/user_model.dart';
import 'package:expiry_vigilance/Provider/add_product_screen_provider.dart';
import 'package:expiry_vigilance/components/add_product_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDescriptionScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final DateTime expiryDate;
  final String productName;
  final Timestamp createdOn;
  final String selectValue;
  final String description;
  final String imageUrl;

  const ProductDescriptionScreen({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
    required this.expiryDate,
    required this.productName, required this.selectValue, required this.description, required this.imageUrl, required this.createdOn,
  }) : super(key: key);

  @override
  State<ProductDescriptionScreen> createState() => _ProductDescriptionScreenState();
}

class _ProductDescriptionScreenState extends State<ProductDescriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddProductScreenProvider>(
      create: (_) {
        final provider = AddProductScreenProvider();
        provider.productNameController.text = widget.productName;
        provider.expiryDateController.text = widget.expiryDate.toString().split(' ')[0];
        provider.selectedValue = widget.selectValue;
        provider.descriptionController.text = widget.description;
        provider.imageUrl = widget.imageUrl;
        provider.selectedDate = widget.expiryDate;
        //provider.fetchProductId(widget.productName, widget.createdOn, widget.firebaseUser.uid);
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.productName, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
        body: Consumer<AddProductScreenProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(image: AssetImage("assets/loading.jpg"))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () => provider.showPhotoOption(context),
                              child: ClipRRect(

                                borderRadius: BorderRadius.circular(12),
                                child: (provider.productImage != null)
                                    ? Image.file(
                                  provider.productImage!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                                    : (provider.imageUrl != null)
                                    ? Image.network(
                                  provider.imageUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.broken_image, size: 60),
                                    );
                                  },
                                )
                                    : Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image, size: 60),
                                ),

                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Icon(Icons.image_outlined,size: 100,),),
                        Positioned(
                            right: 0,
                            bottom: 15,
                            child: SizedBox(child: Icon(Icons.edit),)),
                      ],
                    ),
                    SizedBox(height: 10),
                    AddProductTextField(
                      labelText: 'Product Name',
                      hintText: 'Bourbon',
                      controller: provider.productNameController,
                    ),
                    SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          labelText: "Category",
                        ),
                        items: provider.categoryList.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) => provider.selectedValue = value,
                        value: provider.selectedValue,
                      ),
                    ),
                    SizedBox(height: 6),
                    AddProductTextField(
                      labelText: 'Description',
                      hintText: '(optional)',
                      controller: provider.descriptionController,
                      maxLines: 3,
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => provider.selectDate(context),
                            child: AddProductTextField(
                              readOnly: true,
                              labelText: "Expiry Date",
                              hintText: "Tap to pick a date",
                              controller: provider.expiryDateController,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => provider.selectDate(context),
                            child: Icon(Icons.calendar_month, size: 30),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: ()async{
                          await provider.fetchProductId(widget.productName, widget.createdOn, widget.firebaseUser.uid);
                          provider.checkValuesForUpdate(context, widget.firebaseUser.uid, widget.userModel, widget.firebaseUser);
                        },
                        child: Text(
                            "Update Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                Container(
                  height: 40,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: ()async{
                      await provider.fetchProductId(widget.productName, widget.createdOn, widget.firebaseUser.uid);
                      provider.deleteData(context, widget.firebaseUser.uid,);
                      },
                    child: Text(
                        "Delete Product",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
