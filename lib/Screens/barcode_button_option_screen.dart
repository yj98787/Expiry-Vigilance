import 'package:expiry_vigilance/Models/api.dart';
import 'package:expiry_vigilance/Models/ui_helper.dart';
import 'package:expiry_vigilance/Models/user_model.dart';
import 'package:expiry_vigilance/Screens/add_product_screen.dart';
import 'package:expiry_vigilance/components/button.dart';
import 'package:expiry_vigilance/global_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class BarcodeOptionScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const BarcodeOptionScreen({super.key, required this.userModel,required this.firebaseUser});

  @override
  State<BarcodeOptionScreen> createState() => _BarcodeOptionScreenState();
}

class _BarcodeOptionScreenState extends State<BarcodeOptionScreen> {


  String result = "Scan a barcode...";
  late BarcodeViewController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        title: Text("Add Product",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: GlobalColor.scaffoldColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
                width: 300,
                child: SimpleBarcodeScanner(
                  scaleHeight: 200,
                  scaleWidth: 400,
                  onScanned: (code) {
                    setState(() async{
                      result = code;

                      try{
                        final productInfo = await API.fetchProductInfo(code);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context)=>AddProductScreen(
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser,
                                  barcode: code,
                                  productName: productInfo["name"],
                                  productImage: productInfo["image"],
                                  productDescription: productInfo["description"],
                                )));
                      }catch (e) {
                        // Handle error (show dialog or snackbar)
                        UiHelper.showAlertDialog(context, 'Error!', e.toString());
                        print("Error fetching product info: $e");
                      }

                    });
                  },
                  continuous: true,
                  onBarcodeViewCreated: (BarcodeViewController controller) {
                    this.controller = controller;
                  },
                )),
            const SizedBox(height: 20),
            CommonButton(text: "Add Product Manually", onPresser: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AddProductScreen(userModel: widget.userModel,firebaseUser: widget.firebaseUser)));
            }),
            Text(
              result,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
