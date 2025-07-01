import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_vigilance/Models/product_model.dart';
import 'package:expiry_vigilance/Models/ui_helper.dart';
import 'package:expiry_vigilance/Models/user_model.dart';
import 'package:expiry_vigilance/Screens/bottom_navbar.dart';
import 'package:expiry_vigilance/Screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddProductScreenProvider with ChangeNotifier{
  String? selectedCategory; // null means 'All'
  DateTime? selectedDate;
  File? productImage;
  late String productKiId;

  TextEditingController productNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  String? imageUrl;
  List<String> categoryList = ["Medicines", "Daily Use Products", "Cosmetics", "Others"];
  String? selectedValue;

  Stream<QuerySnapshot> getProductStream(String docId) {
    CollectionReference productRef = FirebaseFirestore.instance
        .collection("user")
        .doc(docId)
        .collection("products");

    if (selectedCategory != null) {
      return productRef.where("category", isEqualTo: selectedCategory).snapshots();
    } else {
      return productRef.snapshots(); // show all if no category selected
    }
  }

 /* Future<String?> showCategoryDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text("Medicines"),
                onTap: () => Navigator.pop(context, "Medicines"),
              ),
              ListTile(
                title: Text("Daily Use Products"),
                onTap: () => Navigator.pop(context, "Daily Use Products"),
              ),
              ListTile(
                title: Text("Cosmetics"),
                onTap: () => Navigator.pop(context, "Cosmetics"),
              ),
              ListTile(
                title: Text("Others"),
                onTap: () => Navigator.pop(context, "Others"),
              ),
            ],
          ),
        );
      },
    );
  }
  */

  void selectImage(ImageSource source) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      cropImage(pickedImage);
      notifyListeners();
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(sourcePath: file.path);
    if (croppedImage != null) {
        productImage = File(croppedImage.path);
        notifyListeners();
    }
  }

  void showPhotoOption(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Upload Product Image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.gallery);
                  notifyListeners();
                },
                leading: Icon(Icons.photo_album),
                title: Text("Select from Gallery"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                  notifyListeners();
                },
                leading: Icon(Icons.camera_alt),
                title: Text("Capture Image"),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );
      if (pickedDate != null) {
        selectedDate = pickedDate;
        expiryDateController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
        notifyListeners();
      }
  }

  void checkValues(BuildContext context,String docId,UserModel userModel,User firebaseUser) {
    String productName = productNameController.text.trim();
    if (productName == "" || selectedDate == null|| selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields.")),
      );
    } else {
      uploadData(context,docId,userModel,firebaseUser);
    }
  }

  void uploadData(BuildContext context, String docId,UserModel userModel,User firebaseUser) async {

    if(productImage!=null){
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      UiHelper.showLoadingDialogs(context, 'Uploading Image');
      UploadTask uploadTask = FirebaseStorage.instance.ref("ProfilePictures").child('${docId}_$timestamp.jpg').putFile(productImage!);
      TaskSnapshot snapshot = await uploadTask;

      imageUrl = await snapshot.ref.getDownloadURL();
    }else{
      imageUrl = "https://cdn1.iconfinder.com/data/icons/online-shopping-221/64/ONLINE_ORDER-shopping_bag-purchase-add_product-online_order-flat-512.png";
    }
    String productName = productNameController.text.trim();

    // TODO: Upload image to Firebase Storage and get the URL, if needed.
    ProductModel newProduct = ProductModel(
      productName: productName,
      description: descriptionController.text.trim(),
      productImage: imageUrl, // <-- Add Firebase image URL if you upload image
      expiryDate: Timestamp.fromDate(selectedDate!),
      category: selectedValue,
      createdOnDate: Timestamp.now(),
    );

    await FirebaseFirestore.instance
        .collection("user")
        .doc(docId)
        .collection('products')
        .add(newProduct.toMap()).then((value){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product added successfully!")),
      );
    });
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MainNavigation(userModel: userModel, firebaseUser: firebaseUser),
      ),
    );
    notifyListeners();
  }

  void checkValuesForUpdate(BuildContext context,String docId,UserModel userModel,User firebaseUser) {
    String productName = productNameController.text.trim();
    if (productName == "" || selectedDate == null||selectedValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all required fields.")),
      );
    } else {
      uploadDataForUpdate(context,docId,userModel,firebaseUser);
    }
  }

  Future<void> fetchProductId(String productName,Timestamp createdOnDate,String docID)async{
    final querySnapshot = await FirebaseFirestore.instance
        .collection("user")
        .doc(docID)
        .collection("products")
        .where("productName", isEqualTo: productName)
        .where('createdOnDate', isEqualTo: createdOnDate)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final productDoc = querySnapshot.docs.first;
      final productId = productDoc.id; // 🔑 This is the document ID
      productKiId = productId;
      print("Product ID: $productId");
      notifyListeners();
    }
  }

  void uploadDataForUpdate(BuildContext context, String docId,UserModel userModel,User firebaseUser) async {
    String updatedImageUrl;
    UiHelper.showLoadingDialogs(context, 'Creating Product');

    if(productImage!=null){
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      UploadTask uploadTask = FirebaseStorage.instance.ref("ProfilePictures").child('${docId}_$timestamp.jpg').putFile(productImage!);
      TaskSnapshot snapshot = await uploadTask;

      updatedImageUrl = await snapshot.ref.getDownloadURL();
    }else{
      updatedImageUrl = imageUrl!;
    }

    String productName = productNameController.text.trim();

    // TODO: Upload image to Firebase Storage and get the URL, if needed.
    ProductModel newProduct = ProductModel(
      productName: productName,
      description: descriptionController.text.trim(),
      productImage: updatedImageUrl, // <-- Add Firebase image URL if you upload image
      expiryDate: Timestamp.fromDate(selectedDate!),
      category: selectedValue,
      createdOnDate: Timestamp.now(),
    );

    await FirebaseFirestore.instance
        .collection("user")
        .doc(docId)
        .collection('products')
        .doc(productKiId)
        .update(newProduct.toMap()).then((value){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product Updated successfully!")),
      );
    });
    Navigator.popUntil(context, (route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MainNavigation(userModel: userModel, firebaseUser: firebaseUser),
      ),
    );
    notifyListeners();
  }

  void deleteData(BuildContext context, String docId)async{
    try{
      await FirebaseFirestore.instance
          .collection('user')
          .doc(docId)
          .collection('products')
          .doc(productKiId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Product deleted successfully!")),
      );

      Navigator.pop(context);
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>MainNavigation(userModel: userModel, firebaseUser: firebaseUser)));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting product: $e")),
      );
    }
  }
}