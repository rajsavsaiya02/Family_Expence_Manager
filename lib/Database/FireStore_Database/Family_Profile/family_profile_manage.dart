import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/Credentials/familyGroupKey.dart';
import 'package:fem/Database/FireStore_Database/Family_Profile/familiy_group_datamodel.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final db = FirebaseFirestore.instance;
final UserController userController = Get.put(UserController());
final FamilyGroupKey gValue = Get.put(FamilyGroupKey());
final firestore = FirebaseFirestore.instance.collection('family');

class GroupController extends GetxController {
  String familyid = "";
  var familyName = "".obs;
  var profileImg = "".obs;
  var groupKey = "".obs;
  var memberList = [].obs;
  var groupCreateDate = "".obs;
  var pwd = "".obs;
  var adminId = "".obs;
  var admin = "".obs;
  var adminName = "".obs;

  void getFamilyGroupData() async {
    if(userController.familyId.toString() != " ") {
      await gValue.loadFromStorage();
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('family').doc(gValue.familyKey.value.fid.toString()).get();
      final fd = FamilyGroupDataModel.fromSnapshot(snapshot);
      familyid = gValue.familyKey.value.fid.toString();
      pwd.value = fd.password.toString();
      familyName.value = fd.familyName.toString();
      profileImg.value = fd.profileImg.toString();
      groupKey.value = fd.accessCode.toString();
      groupCreateDate.value = fd.groupCreateDate.toString();
      memberList.value = fd.member.toList();
      adminId.value = fd.admin.toString();
      admin.value = fd.admin.toString() != cValue.currentUser.value.uid ? "Member" : "Admin";
    }
    update();
  }

  List<dynamic> get familyUserListValue => memberList.value.toList();

  void updateGroupData(String field,String newdata) async {
    await FirebaseFirestore.instance.collection('family').doc(gValue.familyKey.value.fid)
        .update({"$field": encryptData(newdata.toString(),  gValue.familyKey.value.key.toString())})
        .then((value) =>null).onError((error, stackTrace) {
      print("error" + error.toString());
    });
    update();
  }

  void deleteGroupProfileImg(url) async {
    if(url.isNotEmpty && url.toString() != " "){
      await FirebaseStorage.instance.refFromURL(url).delete();
    }
    update();
  }
}

