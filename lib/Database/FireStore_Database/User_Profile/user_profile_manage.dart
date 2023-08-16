import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/Credentials/familyGroupKey.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Screens/Home/home.dart';
import 'package:fem/Screens/UserSignUp/verify_email_screen.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

final db = FirebaseFirestore.instance;
final UserController controller = Get.put(UserController());
final cValue = Get.put(commanValue());

Future<void> userSignIn(context, String email, String pwd) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: pwd)
        .then((value) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (value.user!.emailVerified) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );
        prefs.setBool('IsSignIn', true);
        final cValue = Get.put(commanValue());
        final gValue = Get.put(FamilyGroupKey());
        cValue.currentUser.value.uid = value.user!.uid.toString();
        cValue.currentUser.value.email = value.user!.email.toString();

        final DocumentSnapshot udoc = await FirebaseFirestore.instance.collection('users').doc(value.user!.uid.toString()).get();
        var keyString = decryptData(udoc.get('accessCode').toString(),value.user!.uid.toString().substring(0, 16));
        cValue.currentUser.value.key = keyString;
        await cValue.saveToStorage();

        gValue.familyKey.value.fid = decryptData(udoc.get('familyId').toString(),keyString);
        final DocumentSnapshot fdoc = await FirebaseFirestore.instance.collection('family').doc(decryptData(udoc.get('familyId').toString(),keyString)).get();
        keyString = decryptData(fdoc.get('accessCode').toString(),gValue.familyKey.value.fid.toString().substring(0, 16));
        gValue.familyKey.value.key = keyString;
        await gValue.saveToStorage();

        // await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (Route<dynamic> route) => false);
      } else {
        prefs.setBool('IsSignIn', false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VerifyEmail()),
        );
      }
    });
  } on FirebaseAuthException catch (e) {
    print('Failed with error code: ${e.code}');
    if (e.code == "invalid-email") {
      showTopTitleSnackBar(context, Icons.error, "Invalid Email ID");
    } else if (e.code == "user-disabled") {
      showTopTitleSnackBar(context, Icons.error, "Account Disabled");
    } else if (e.code == "user-not-found") {
      showTopTitleSnackBar(context, Icons.error, "Account not found");
    } else if (e.code == "wrong-password") {
      showTopTitleSnackBar(context, Icons.error, "Wrong Password");
    } else {
      showTopSnackBar(context, Icons.error, "Unknown Error", "Try Again...");
    }
  }
}

Future<void> userSignUp(context, String name, String email, String phone, String password) async {
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      var _uid = value.user!.uid.toString();
      var _phoneNo = phone;
      var _ac_date = value.user!.metadata.creationTime.toString();
      if (phone.isEmpty) {
        _phoneNo = value.user!.providerData[0].phoneNumber.toString();
        _phoneNo = _phoneNo.toString() == "null" ? " " : _phoneNo;
      }
      bool _status = value.user!.emailVerified;
      await createUserProfile(_uid, name, email, _phoneNo, _ac_date, _status);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
      cValue.currentUser.value.uid = value.user!.uid.toString();
      cValue.currentUser.value.email = value.user!.email.toString();
      final DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(value.user!.uid.toString()).get();
      final String keyString = decryptData(doc.get('accessCode').toString(),value.user!.uid.toString().substring(0, 16));
      cValue.currentUser.value.key = keyString;
      await cValue.saveToStorage();
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
      showTopTitleSnackBar(context, Icons.account_circle, "Account Created");
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const VerifyEmail()));
    });
  } on FirebaseAuthException catch (e) {
    print('Failed with error code: ${e.code}');
    if (e.code == "invalid-email") {
      showTopTitleSnackBar(context, Icons.error, "Invalid Email ID");
    } else if (e.code == "user-disabled") {
      showTopTitleSnackBar(context, Icons.error, "Account Disabled");
    } else if (e.code == "user-not-found") {
      showTopTitleSnackBar(context, Icons.error, "Account not found");
    } else if (e.code == "wrong-password") {
      showTopTitleSnackBar(context, Icons.error, "Wrong Password");
    } else if (e.code == "email-already-in-use") {
      showTopTitleSnackBar(context, Icons.error, "Account already exits");
    } else {
      print(e.code);
      showTopSnackBar(context, Icons.error, "Unknown Error", "Try Again...");
    }
  }
}

Future<void> createUserProfile(String uid, String name, String email, String phone_no, String c_date, bool a_status,) async {
  final userCollection = FirebaseFirestore.instance.collection('users');
  final userDataDocument = userCollection.doc(uid);
  var keyString = uid.substring(0, 16);
  //access code
  var uuid = Uuid();
  var accessCode = uuid.v4().substring(0, 16);
  var temp = accessCode;
  accessCode = encryptData(accessCode, keyString);
  keyString = temp;
  await userDataDocument.set({
    'id':uid,
    'name': encryptData(name, keyString),
    'emailAddress': encryptData(email, keyString),
    'phoneNumber': encryptData(phone_no, keyString),
    'familyId': encryptData(" ", keyString),
    'memberStatus': encryptData(" ", keyString),
    'dob': encryptData(" ", keyString),
    'accessCode': accessCode,
    'acDate': encryptData(c_date, keyString),
    'photoUrl': encryptData(" ", keyString),
    'status': a_status,
  });
  await userDataDocument.collection("userCategory").doc("expense").set({'expenseCategory': [],});
  await userDataDocument.collection("userCategory").doc("income").set({'incomeCategory': [],});
  await userDataDocument.collection("balance").doc("currentBalance").set({'currentBalance': encryptData("0", keyString),});
  // await userDataDocument.collection("analysis")
  //     .doc(DateTime.now().year.toString()).set({'yTotalExpense': 0,'yTotalIncome': 0,});
  // await userDataDocument.collection("analysis").doc(DateTime.now().year.toString()).collection("months")
  //     .doc(DateTime.now().month.toString()).set({'mTotalExpense': 0,'mTotalIncome': 0,});
  // await userDataDocument.collection("analysis").doc(DateTime.now().year.toString()).collection("months").doc(DateTime.now().month.toString()).collection("day")
  //     .doc(DateTime.now().day.toString()).set({'dTotalExpense': 0,'dTotalIncome': 0,});
}

Future<void> userSignOut(context) async {
  FirebaseAuth.instance.signOut().then((value) async {
    final prefs = await SharedPreferences.getInstance();
    final box = await Hive.openBox('userBox');
    prefs.clear();
    prefs.setBool('IsSignIn', false);
    Get.reset();
    await box.clear();
    await DefaultCacheManager().emptyCache();
    // Close the app
    SystemNavigator.pop();
  }).onError((error, stackTrace) {
    print("Error (User SingOut): ${error.toString()}");
  });
}
