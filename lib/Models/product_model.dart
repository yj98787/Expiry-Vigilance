import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel{
  String? productImage;
  String? productName;
  String? description;
  Timestamp? expiryDate;
  String? category;
  Timestamp? createdOnDate;

  ProductModel({this.description,this.productImage,this.productName,this.expiryDate,this.category,this.createdOnDate});

  ProductModel.fromMap(Map<String,dynamic>map){
    productName = map['productName'];
    productImage = map['productImage'];
    description = map['description'];
    expiryDate = map['expiryDate'];
    category = map['category'];
    createdOnDate = map['createdOnDate'];
  }

  Map<String,dynamic> toMap(){
    return {
      "productImage":productImage,
      "productName":productName,
      "expiryDate":expiryDate,
      "description":description,
      "createdOnDate":createdOnDate,
      "category":category,
    };
  }
}