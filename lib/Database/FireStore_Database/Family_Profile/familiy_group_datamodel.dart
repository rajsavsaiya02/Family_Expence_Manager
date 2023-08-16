import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/familyGroupKey.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:get/get.dart';

class FamilyGroupDataModel {
  String familyId;
  String familyName;
  String accessCode;
  String password;
  List<String> member;
  String admin;
  String groupCreateDate;
  String profileImg;

  FamilyGroupDataModel({
    required this.familyId,
    required this.familyName,
    required this.accessCode,
    required this.member,
    required this.admin,
    required this.profileImg,
    required this.password,
    required this.groupCreateDate
  });

  factory FamilyGroupDataModel.fromSnapshot(DocumentSnapshot snapshot) {
    final FamilyGroupKey gValue = Get.put(FamilyGroupKey());
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    var temp = decryptData(data['accessCode'].toString(), gValue.familyKey.value.fid.substring(0,16).toString());
    if(gValue.familyKey.value.key.toString() != temp.toString()) {
      gValue.familyKey.value.fid = gValue.familyKey.value.fid.toString();
      gValue.familyKey.value.key = temp;
      gValue.saveToStorage();
    }
    gValue.loadFromStorage();
    List<String> memberlist = [];
    for (String id in data['member'] as List<dynamic>) {
        memberlist.add(decryptData(id, gValue.familyKey.value.key));
    }
    return FamilyGroupDataModel(
      familyId: data['uid'].toString(),
      familyName: decryptData(data['familyName'].toString(), gValue.familyKey.value.key),
      admin: decryptData(data['admin'].toString(), gValue.familyKey.value.key),
      password: decryptData(data['password'].toString(), gValue.familyKey.value.key),
      accessCode: temp,
      member : memberlist,
      groupCreateDate: decryptData(data['groupCreateDate'].toString(), gValue.familyKey.value.key),
      profileImg: decryptData(data['profileImg'].toString(), gValue.familyKey.value.key) != " " ? decryptData(data['profileImg'].toString(), gValue.familyKey.value.key) : "",
    );
  }
}