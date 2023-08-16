import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Screens/Home/home.dart';
import 'package:fem/Screens/UserSignIn/user_sign_in.dart';
import 'package:fem/Utility/Colors.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
final db = FirebaseFirestore.instance;
final cValue = Get.put(commanValue());

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({Key? key}) : super(key: key);

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if(!isEmailVerified){
      sendVerificationEmail();
      timer = Timer.periodic(Duration(seconds: 3), (timer) => checkEmailVerified(),);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async{
    await FirebaseAuth.instance.currentUser?.reload();
    if (this.mounted) setState(() {
      if(FirebaseAuth.instance.currentUser != null){
        isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      } else {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const UserSignIn()),(route) => false);
      }
    });
    if(isEmailVerified) {
      timer?.cancel();
      cValue.loadFromStorage();
      await db.collection('users').doc(cValue.currentUser.value.uid).update({"status": true})
          .then((value) async {
        cValue.loadFromStorage();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('IsSignIn', true);

        showTopTitleSnackBar(context, Icons.account_circle, "Account Verificated");
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Home()),(route) => false);
      },
      onError: (e) {
        showTopSnackBar(context, Icons.account_circle, "Account Verification Failed", "Try again...");
        print("verification : " + e.toString());
      });
    }
  }

  Future sendVerificationEmail() async{
    try{
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      print('Error resending verification email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Verify Email"),
        backgroundColor: primary,
        elevation: 5,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("A Verification email has been sent to your email address.",
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24,),
              ElevatedButton.icon(
                  onPressed: () {
                    if (canResendEmail) {
                      sendVerificationEmail;
                    }
                  },
                  icon: Icon(Icons.email, size: 32,),
                  label: Text(
                    "Resend Email",
                    style: TextStyle(fontSize: 24),
                  )),
              SizedBox(height: 8,),
              OutlinedButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const UserSignIn()),(route) => false);
                  },
                  child: Text("Cancel", style: TextStyle(fontSize: 24),)),
            ],
          ),
        ),
      ),
    );
  }
}
