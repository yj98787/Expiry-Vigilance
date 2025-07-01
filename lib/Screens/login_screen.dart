import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_vigilance/Models/ui_helper.dart';
import 'package:expiry_vigilance/Models/user_model.dart';
import 'package:expiry_vigilance/Screens/Signup_screen.dart';
import 'package:expiry_vigilance/Screens/bottom_navbar.dart';
import 'package:expiry_vigilance/Screens/home_screen.dart';
import 'package:expiry_vigilance/components/button.dart';
import 'package:expiry_vigilance/components/common_textfield.dart';
import 'package:expiry_vigilance/global_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isObscure = true;

  void togglePassword(){
    setState(() {
      isObscure = !isObscure;
    });
  }

  void checkValues()async{
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email==""||password==""){
      return UiHelper.showAlertDialog(
        context,
        "Incomplete Data",
        "Please fill all the Fields!",
      );
    }else{
      login(email, password);
      print("login initiated");
    }
  }

  void login(String email,String password)async{
    UserCredential? credential;

    UiHelper.showLoadingDialogs(context, "Logging in...");

    try{
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(ex){
      Navigator.pop(context);
      UiHelper.showAlertDialog(context, "An error Occurred", ex.code.toString());

      print(ex.code.toString());
    }
    if(credential!=null){
      String uid = credential.user!.uid;

      DocumentSnapshot userData = await FirebaseFirestore.instance.collection("user").doc(uid).get();

      UserModel newUser1 = UserModel.fromMap(userData.data() as Map<String,dynamic>);

      print("Log In Successful!");

      Navigator.popUntil(context, (route)=>route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainNavigation(userModel: newUser1, firebaseUser: credential!.user!)));
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
                  labelText: 'Email',
                  hintText: 'abc@gmail.com',
                  suffixIcon: Icons.mail_outlined,
                  controller: emailController,
              ),
              SizedBox(height: 10,),
              CommonTextfield(
                  labelText: 'Password',
                  hintText: 'password',
                  suffixIcon: (isObscure)?Icons.visibility_off:Icons.remove_red_eye_outlined,
                  controller: passwordController,
                  obscureText: isObscure,
                  onSuffixTap: togglePassword,
              ),
              SizedBox(height: 10,),
              CommonButton(
                text: 'Login',
                onPresser: (){
                  checkValues();
                },
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an Account ? "),
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupScreen()));
                  },
                      child: Text('SignUp'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(0),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
