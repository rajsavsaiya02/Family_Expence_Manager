import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/Credentials/familyGroupKey.dart';
import 'package:fem/Database/Credentials/familyGroupKeyModel.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../User_Analysis/analysis_datamodel.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final commanValue cValue = Get.put(commanValue());
final UserController userController = Get.put(UserController());
final FamilyGroupKey gValue = Get.put(FamilyGroupKey());

class FamilyExpenseDataModel{
  String title;
  String category;
  double amount;
  String method;
  String date_time;
  String memberId;
  String additional_info;

  FamilyExpenseDataModel(this.additional_info, {required this.title, required this.category, required this.amount, required this.method,
      required this.date_time, required this.memberId});

  factory FamilyExpenseDataModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return FamilyExpenseDataModel(
      data['additional_info'],
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      amount: data['amount'] ?? 0.0,
      date_time: data['date_time'] ?? '',
      memberId: data['memberId'] ?? '',
      method: data['method'] ?? '',
    );
  }
}

class FamilyExpenseController extends GetxController {
  String title = "";
  String category = "";
  int amount = 0;
  String method = "";
  String dob="";
  String memberId="";
  String additionalInfo = "";
  List<dynamic> e_Category = [].obs;
  FamilyExpenseDataModel? FamilyExpense;

  // family expense Category's
  Future<void> addExpenseCategoryItem(BuildContext context, String filed, dynamic value) async {
    try {
      final documentReference = firestore.collection('family').doc(gValue.familyKey.value.fid).collection("FamilyCategory").doc("expense");
      // Use FieldValue to update the array field.
      final updateData = {"$filed": FieldValue.arrayUnion([encryptData(value, gValue.familyKey.value.key)])};
      final check = await documentReference.get();
      if (check.exists){
        await documentReference.update(updateData);
      } else {
        await documentReference.set({"$filed":[encryptData(value, gValue.familyKey.value.key)]});
      }
      updateFamilyExpenseCategoryList();
      Navigator.of(context).pop();
      showTopTitleSnackBar(context, Icons.add_alert, "Category Added Successfully");
    } on FirebaseException catch (e) {
      Navigator.of(context).pop();
      print(e);
      showTopSnackBar(context, Icons.add_alert, "Category Not Added","Try Again...!");
    }
  }
  Future<void> updateFamilyExpenseCategoryList() async {
    try {
      final documentReference = firestore.collection("family").doc(gValue.familyKey.value.fid).collection("FamilyCategory").doc("expense");
      final querySnapshot = await documentReference.get();
      Map<String, dynamic> list = querySnapshot.data() as Map<String, dynamic>;
      var temp = list["expenseCategory"];
      e_Category.clear();
      for (int i = 0; i < temp.length; i++) {
        e_Category.add(decryptData(temp[i], gValue.familyKey.value.key));
      }
      print(e_Category);
    } catch (e) {
      print('Error getting field value: $e');
    }
    update();
  }
  Future<void> deleteExpenseCategoryItem(BuildContext context,String filed, dynamic value) async {
    try {
      final documentReference = firestore.collection("family").doc(gValue.familyKey.value.fid).collection("FamilyCategory").doc("expense");
      // Use FieldValue to remove the item from the array field.
      final updateData = {"$filed": FieldValue.arrayRemove([encryptData(value, gValue.familyKey.value.key)])};
      await documentReference.update(updateData);
      updateFamilyExpenseCategoryList();
      Navigator.of(context).pop();
      showTopTitleSnackBar(context, Icons.add_alert, "Category Deleted Successfully");
    } catch (e) {
      Navigator.of(context).pop();
      showTopSnackBar(context, Icons.add_alert, "Category Not Deleted","Try Again...!");
    }
  }

  // transaction recodes
  Future<void> addExpenseRecode(String title, String category, double amount, String method, DateTime date, String info) async {
    CollectionReference users = firestore.collection('family').doc(gValue.familyKey.value.fid).collection("transactions");
    DocumentReference newDocRef = users.doc();
    info = info == "" ? " " : info;
    
    // transaction adding
    String docId = newDocRef.id;
    Map<String, dynamic> data = {
      "uid" : docId,
      "additional_info" : encryptData(info.toString(), gValue.familyKey.value.key),
      'type': encryptData("expense", gValue.familyKey.value.key),
      "amount" : encryptData(amount.toString(), gValue.familyKey.value.key),
      "category" : encryptData(category.toString(), gValue.familyKey.value.key) ,
      "date_time": date.toIso8601String(),
      "method": encryptData(method.toString(), gValue.familyKey.value.key),
      "memberId": encryptData(cValue.currentUser.value.uid.toString(), gValue.familyKey.value.key),
      "memberName": encryptData(userController.name, gValue.familyKey.value.key),
      "title": encryptData(title.toString(), gValue.familyKey.value.key),
    };
    await newDocRef.set(data);
    update();
  }
  Future<void> updateExpenseRecode(String uid, String ntitle, String ncategory, double namount, String nmethod, DateTime ndate, String ninfo, String ptitle, String pcategory, double pamount, String pmethod, DateTime pdate, String pinfo) async {
    if(ptitle != ntitle)
      firestore.collection('family').doc(gValue.familyKey.value.fid).collection("transactions")
           .doc(uid).update({"title":encryptData(ntitle, gValue.familyKey.value.key)});
    if(pmethod != nmethod)
      firestore.collection('family').doc(gValue.familyKey.value.fid).collection("transactions")
          .doc(uid).update({"method": encryptData(nmethod, gValue.familyKey.value.key)});
    if(pinfo != ninfo)
      firestore.collection('family').doc(gValue.familyKey.value.fid).collection("transactions")
          .doc(uid).update({"additional_info": encryptData(ninfo, gValue.familyKey.value.key)});
    if(pcategory != ncategory) {
      firestore.collection('family').doc(gValue.familyKey.value.fid).collection("transactions")
          .doc(uid).update({"category": encryptData(ncategory, gValue.familyKey.value.key)});}
    if(pamount != namount) {
      firestore.collection('family').doc(gValue.familyKey.value.fid).collection("transactions")
          .doc(uid).update({"amount": encryptData(namount.toString(), gValue.familyKey.value.key)});}
    if (pdate != ndate) {
        firestore.collection('family').doc(gValue.familyKey.value.fid).collection("transactions")
            .doc(uid).update({"date_time": ndate.toIso8601String()});}
    update();
  }
  Future<void> deleteExpenseRecode(String uid) async{
    // delete transaction
    await firestore.collection('family').doc(gValue.familyKey.value.fid).collection("transactions").doc(uid).delete().then((value) => null).onError((error, stackTrace) {print(error);});
    update();
  }
}