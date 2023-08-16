import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/Credentials/familyGroupKey.dart';
import 'package:fem/Database/FireStore_Database/Family_Profile/family_profile_manage.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final cValue = Get.put(commanValue());

class UserDataModel {
  String email;
  String accessCode;
  String familyId;
  String memberType;
  String dob;
  String name;
  String phoneNumber;
  String photoUrl;
  bool status;

  UserDataModel({
    required this.email,
    required this.accessCode,
    required this.familyId,
    required this.memberType,
    required this.name,
    required this.dob,
    required this.phoneNumber,
    required this.photoUrl,
    required this.status,
  });

  factory UserDataModel.fromSnapshot(DocumentSnapshot snapshot) {
    cValue.loadFromStorage();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    var temp = decryptData(data['accessCode'], cValue.currentUser.value.uid.toString().substring(0, 16));
    if( cValue.currentUser.value.key.toString() != temp.toString()) {
      cValue.currentUser.value.key = temp;
      cValue.saveToStorage();
    }
    cValue.loadFromStorage();
    return UserDataModel(
      name: decryptData(data['name'], cValue.currentUser.value.key),
      email: decryptData(data['emailAddress'], cValue.currentUser.value.key),
      accessCode: temp,
      familyId : decryptData(data['familyId'], cValue.currentUser.value.key),
      memberType: decryptData(data['memberStatus'], cValue.currentUser.value.key),
      dob: decryptData(data['dob'], cValue.currentUser.value.key),
      phoneNumber: decryptData(data['phoneNumber'], cValue.currentUser.value.key),
      photoUrl: decryptData(data['photoUrl'], cValue.currentUser.value.key),
      status: data['status'] ?? '',
    );
  }
}

class UserController extends GetxController {

  String name = "";
  String email = "";
  String f_letter = "";
  String familyId = "";
  String memberType = "";
  String photo_url = "";
  String phone = "";
  String accessCode ="";
  String dob="";
  var currentBalance = 0.obs;
  List<dynamic> expenseCategory = [].obs;
  UserDataModel? user;

  void getUserData() async {
    await cValue.loadFromStorage();
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).get();
    var u = UserDataModel.fromSnapshot(snapshot);
    print("this is call : "+ cValue.currentUser.value.uid.toString());
    name = u.name;
    email = u.email;
    f_letter = u.name.toString().substring(0,1).toUpperCase();
    dob = u.dob.toString();
    photo_url = u.photoUrl;
    familyId = u.familyId;
    memberType = u.memberType;
    phone = u.phoneNumber.toString();
    accessCode = u.accessCode.toString();
    getCurrentBalance();
    update();
  }

  void getCurrentBalance() async {
    DocumentSnapshot balance = await FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid)
        .collection("balance").doc("currentBalance").get();
    var doc = balance.data() as Map<String, dynamic>;
    double _cd = double.parse(decryptData(doc["currentBalance"], cValue.currentUser.value.key));
    currentBalance.value = _cd.toInt();
  }

  void updateUserData(BuildContext context,String field,newdata) async {
    await FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid)
        .update({"$field": encryptData(newdata,  cValue.currentUser.value.key)})
        .then((value) =>null).onError((error, stackTrace) {
      print("error" + error.toString());
    });
    update();
  }

  void updateCurrentBalance(amount) async{
    await FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection("balance").doc("currentBalance").update({
      "currentBalance": encryptData(amount.toString(), cValue.currentUser.value.key)
    }).then((value) => null).onError((error, stackTrace) {
      print("error" + error.toString());
    });
    update();
  }

  void deleteUserProfileImg(url) async {
    if(url.isNotEmpty && url.toString() != " "){
      await FirebaseStorage.instance.refFromURL(url).delete();
    }
  }
}