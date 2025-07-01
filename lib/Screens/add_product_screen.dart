import 'package:expiry_vigilance/Provider/add_product_screen_provider.dart';
import 'package:expiry_vigilance/Models/user_model.dart';
import 'package:expiry_vigilance/components/add_product_textfield.dart';
import 'package:expiry_vigilance/components/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final String? barcode;
  final String? productName;
  final String? productImage;
  final String? productDescription;

  const AddProductScreen({
    super.key,
    required this.userModel,
    required this.firebaseUser,
    this.barcode,
    this.productName,
    this.productImage,
    this.productDescription,
  });


  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}


class _AddProductScreenState extends State<AddProductScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Expiry Vigilance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ChangeNotifierProvider<AddProductScreenProvider>(
              create: (context)=>AddProductScreenProvider(),
            child: Consumer<AddProductScreenProvider>(
                builder: (context,provider,child){
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 30),
                      GestureDetector(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12), // circular shape
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
                          )
                              : Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[300],
                            child: Icon(Icons.image, size: 60),
                          ),
                        ),
                        onTap: (){provider.showPhotoOption(context);},
                      ),
                      SizedBox(height: 10),
                      AddProductTextField(
                        labelText: 'Product Name',
                        hintText: 'Bourbon',
                        controller: provider.productNameController,
                      ),
                      /* ElevatedButton(
                onPressed: () {
                  if (productNameController.text.isNotEmpty) {
                    fetchProductDetails(productNameController.text.trim());
                  }
                },
                child: Text("Auto-Fill from API"),
              ),*/
                      SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: "Category",
                          ),
                          items: provider.categoryList.map((String category){
                            return DropdownMenuItem(
                              child: Text(category),
                              value: category,
                            );
                          }).toList(),
                          onChanged: (String? newValue){
                            setState(() {
                              provider.selectedValue = newValue;
                            });
                          },
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
                              onTap: (){
                                setState(() {
                                  provider.selectDate(context);
                                });
                              },
                              child: AddProductTextField(
                                readOnly: true,
                                labelText: "Expiry Date",
                                hintText: "Tap to pick a date",
                                controller: provider.expiryDateController,
                                onPressed: (){
                                  setState(() {
                                    provider.selectDate(context);
                                  });
                                  },
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              child: Icon(Icons.calendar_month,size: 30,),
                              onTap: (){
                                provider.selectDate(context);
                              },
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      CommonButton(
                        text: 'Add Product',
                        onPresser: (){
                          provider.checkValues(context, widget.firebaseUser.uid,widget.userModel,widget.firebaseUser);
                        },
                      ),
                    ],
                  );
                }
            ),
          )
        ),
      ),
    );
  }
}
