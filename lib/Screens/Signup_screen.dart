import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_vigilance/Models/ui_helper.dart';
import 'package:expiry_vigilance/Models/user_model.dart';
import 'package:expiry_vigilance/Screens/bottom_navbar.dart';
import 'package:expiry_vigilance/Screens/home_screen.dart';
import 'package:expiry_vigilance/Screens/login_screen.dart';
import 'package:expiry_vigilance/components/common_textfield.dart';
import 'package:expiry_vigilance/global_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  void togglePasswordText(){
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  void toggleConfirmPasswordText(){
    setState(() {
      hideConfirmPassword = !hideConfirmPassword;
    });
  }

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email == "" || password == "" || confirmPassword == "") {
      return UiHelper.showAlertDialog(
        context,
        "Incomplete Data",
        "Please fill all the Fields!",
      );
    } else if (password != confirmPassword) {
      return UiHelper.showAlertDialog(
        context,
        "Password mismatch",
        "The password you have entered do not match!",
      );
    } else {
      signUp(email, password);
      print("SignUp called");
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;
    String name = fullNameController.text.trim();

    UiHelper.showLoadingDialogs(context, "Creating new Account...");

    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      UiHelper.showAlertDialog(
        context,
        "An error Occurred",
        ex.code.toString(),
      );
    }

    if(credential!=null){
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
          email: email,
          fullName: name,
          uid: uid,
      );

      await FirebaseFirestore.instance.collection("user").doc(uid).set(newUser.toMap());
      print("New user Created!");
      Navigator.popUntil(context, (route)=>route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainNavigation(userModel: newUser, firebaseUser: credential!.user!)));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColor.scaffoldColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 70, // Adjust the radius as needed
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/logo.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              CommonTextfield(
                labelText: 'Full Name',
                hintText: "Name",
                suffixIcon: Icons.person,
                controller: fullNameController,
              ),
              SizedBox(height: 10),
              CommonTextfield(
                labelText: 'Email',
                hintText: 'abc@gmail.com',
                suffixIcon: Icons.mail_outlined,
                controller: emailController,
              ),
              SizedBox(height: 10),
              CommonTextfield(
                labelText: 'Password',
                hintText: 'password',
                suffixIcon: (hidePassword)?Icons.visibility_off:Icons.visibility,
                controller: passwordController,
                obscureText: hidePassword,
                onSuffixTap: togglePasswordText,
              ),
              SizedBox(height: 10),
              CommonTextfield(
                labelText: 'Confirm Password',
                hintText: 'Confirm password',
                suffixIcon: (hideConfirmPassword)?Icons.visibility_off:Icons.visibility,
                controller: confirmPasswordController,
                obscureText: hideConfirmPassword,
                onSuffixTap: toggleConfirmPasswordText,
              ),
              SizedBox(height: 10),
              Container(
                height: 40,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: ElevatedButton(onPressed: () {
                  checkValues();
                }, child: Text("Sign Up")),
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an Account ? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                    },
                    child: Text('LogIn'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
