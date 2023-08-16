import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../User_Analysis/analysis_datamodel.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final UserController controller = Get.put(UserController());
final commanValue cValue = Get.put(commanValue());
final aController = Get.put(analysisController());
var uid = cValue.currentUser.value.uid;

class IncomeDataModel{
  String title;
  String category;
  double amount;
  String method;
  String date_time;
  String additional_info;

  IncomeDataModel(this.additional_info, {required this.title, required this.category, required this.amount, required this.method,
    required this.date_time});

  factory IncomeDataModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return IncomeDataModel(
      data['additional_info'],
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      amount: data['amount'] ?? 0.0,
      date_time: data['date_time'] ?? '',
      method: data['method'] ?? '',
    );
  }
}

class UserIncomeController extends GetxController {
  String title = "";
  String category = "";
  int amount = 0;
  String method = "";
  String dob="";
  String additionalInfo = "";
  List<dynamic> i_Category = [].obs;
  IncomeDataModel? userIncome;

  // Income Category's
  Future<void> addIncomeCategoryItem(BuildContext context, String filed, dynamic value) async {
    try {
      final documentReference = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("userCategory").doc("income");
      // Use FieldValue to update the array field.
      final updateData = {"$filed": FieldValue.arrayUnion([encryptData(value, cValue.currentUser.value.key)])};
      await documentReference.update(updateData);
      updateIncomeCategoryList();
      Navigator.of(context).pop();
      showTopTitleSnackBar(context, Icons.add_alert, "Category Added Successfully");
    } on FirebaseException catch (e) {
      Navigator.of(context).pop();
      print(e);
      showTopSnackBar(context, Icons.add_alert, "Category Not Added","Try Again...!");
    }
  }
  Future<void> updateIncomeCategoryList() async {
    try {
      final documentReference = firestore.collection("users").doc(cValue.currentUser.value.uid).collection("userCategory").doc("income");
      final querySnapshot = await documentReference.get();
      Map<String, dynamic> list = querySnapshot.data() as Map<String, dynamic>;
      var temp = list["incomeCategory"];
      i_Category.clear();
      for (int i = 0; i < temp.length; i++) {
        i_Category.add(decryptData(temp[i], cValue.currentUser.value.key));
      }
      print(i_Category);
    } catch (e) {
      print('Error getting field value: $e');
    }
    update();
  }
  Future<void> deleteIncomeCategoryItem(BuildContext context,String filed, dynamic value) async {
    try {
      final documentReference = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("userCategory").doc("income");
      // Use FieldValue to remove the item from the array field.
      final updateData = {"$filed": FieldValue.arrayRemove([encryptData(value, cValue.currentUser.value.key)])};
      await documentReference.update(updateData);
      updateIncomeCategoryList();
      Navigator.of(context).pop();
      showTopTitleSnackBar(context, Icons.add_alert, "Category Deleted Successfully");
    } catch (e) {
      Navigator.of(context).pop();
      showTopSnackBar(context, Icons.add_alert, "Category Not Deleted","Try Again...!");
    }
  }

  // transaction recodes
  Future<void> addIncomeRecode(String title, String category, double amount, String method, DateTime date, String info) async {
    CollectionReference users = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("transactions");
    DocumentReference newDocRef = users.doc();
    var temp = controller.currentBalance.value.toDouble();
    temp = temp + amount;
    info = info == "" ? " " : info;

    // update current balance
    await firestore.collection('users').doc(cValue.currentUser.value.uid).collection("balance").doc("currentBalance")
        .update({"currentBalance": encryptData(temp.toInt().toString(), cValue.currentUser.value.key)})
        .then((value) => null).onError((error, stackTrace) {print("error" + error.toString());});

    // transaction adding
    String docId = newDocRef.id;
    Map<String, dynamic> data = {
      "uid" : docId,
      "additional_info" : encryptData(info.toString(), cValue.currentUser.value.key),
      'type': encryptData("income", cValue.currentUser.value.key),
      "amount" : encryptData(amount.toString(), cValue.currentUser.value.key),
      "category" : encryptData(category.toString(), cValue.currentUser.value.key) ,
      "date_time": date.toIso8601String(),
      "method": encryptData(method.toString(), cValue.currentUser.value.key),
      "title": encryptData(title.toString(), cValue.currentUser.value.key),
    };
    await newDocRef.set(data);
    await addAnalysisIncomeYearlyAmount(date, amount);
    await addAnalysisIncomeMonthlyAmount(date, amount);
    await addAnalysisIncomeDailyAmount(date, amount);
    await addAnalysisIncomeCategoryAmount(category.toString(),date,amount);

    if( DateTime.now().day == date.day || DateTime.now().subtract(Duration(days: 1)).day == date.day){
      aController.getCurrentIncomeExpense();
    }
    controller.getCurrentBalance();
    update();
  }
  Future<void> updateIncomeRecode(String uid, String ntitle, String ncategory, double namount, String nmethod, DateTime ndate, String ninfo, String ptitle, String pcategory, double pamount, String pmethod, DateTime pdate, String pinfo) async {
    if(ptitle != ntitle)
      firestore.collection('users').doc(cValue.currentUser.value.uid).collection("transactions")
          .doc(uid).update({"title":encryptData(ntitle, cValue.currentUser.value.key)});
    if(pmethod != nmethod)
      firestore.collection('users').doc(cValue.currentUser.value.uid).collection("transactions")
          .doc(uid).update({"method": encryptData(nmethod, cValue.currentUser.value.key)});
    if(pinfo != ninfo)
      firestore.collection('users').doc(cValue.currentUser.value.uid).collection("transactions")
          .doc(uid).update({"additional_info": encryptData(ninfo, cValue.currentUser.value.key)});
    if(pcategory != ncategory || pamount != namount || pdate != ndate) {
      if (pcategory != ncategory) {
        firestore.collection('users').doc(cValue.currentUser.value.uid)
            .collection("transactions").doc(uid)
            .update(
            {"category": encryptData(ncategory, cValue.currentUser.value.key)});
      }
      if (pamount != namount) {

        var difference = pamount - namount;
        var temp = controller.currentBalance.value - difference;
        // update current balance
        firestore.collection('users').doc(cValue.currentUser.value.uid)
            .collection("balance").doc("currentBalance")
            .update({
          "currentBalance": encryptData(
              temp.toString(), cValue.currentUser.value.key)
        });
        controller.getCurrentBalance();

        // update transaction
        firestore.collection('users').doc(cValue.currentUser.value.uid)
            .collection("transactions").doc(uid)
            .update({
          "amount": encryptData(
              namount.toString(), cValue.currentUser.value.key)
        });
      }
      if (pdate != ndate) {
        firestore.collection('users').doc(cValue.currentUser.value.uid).collection("transactions")
            .doc(uid).update({"date_time": ndate.toIso8601String()});
      }

      if( pamount != namount){
        // removing old amount
        await deleteTransactionUpdateAnalysisIncomeYearlyAmount(pdate, pamount);
        await deleteTransactionUpdateAnalysisIncomeMonthlyAmount(pdate, pamount);
        await deleteTransactionUpdateAnalysisIncomeDailyAmount(pdate,pamount);
        await deleteTransactionUpdateAnalysisIncomeCategoryAmount(pcategory, pdate, pamount);
        // adding new amount
        await addAnalysisIncomeYearlyAmount(ndate, namount);
        await addAnalysisIncomeMonthlyAmount(ndate, namount);
        await addAnalysisIncomeDailyAmount(ndate,namount);
        await addAnalysisIncomeCategoryAmount(ncategory, ndate, namount);
      }
      else {
        if( pdate != ndate ){
          if(pdate.year != ndate.year){
            await deleteTransactionUpdateAnalysisIncomeYearlyAmount(pdate, pamount);
            await deleteTransactionUpdateAnalysisIncomeMonthlyAmount(pdate, pamount);
            await deleteTransactionUpdateAnalysisIncomeDailyAmount(pdate,pamount);
            await deleteTransactionUpdateAnalysisIncomeCategoryAmount(pcategory, pdate, pamount);
            // adding new amount
            await addAnalysisIncomeYearlyAmount(ndate, namount);
            await addAnalysisIncomeMonthlyAmount(ndate, namount);
            await addAnalysisIncomeDailyAmount(ndate,namount);
            await addAnalysisIncomeCategoryAmount(ncategory, ndate, namount);
          }
          else if (pdate.month != ndate.month){
            await deleteTransactionUpdateAnalysisIncomeMonthlyAmount(pdate, pamount);
            await deleteTransactionUpdateAnalysisIncomeDailyAmount(pdate,pamount);
            await deleteTransactionUpdateAnalysisIncomeCategoryAmount(pcategory, pdate, pamount);
            // adding new amount
            await addAnalysisIncomeMonthlyAmount(ndate, namount);
            await addAnalysisIncomeDailyAmount(ndate,namount);
            await addAnalysisIncomeCategoryAmount(ncategory, ndate, namount);
          }
          else if (pdate.day != ndate.day){
            await deleteTransactionUpdateAnalysisIncomeDailyAmount(pdate,pamount);
            await deleteTransactionUpdateAnalysisIncomeCategoryAmount(pcategory, pdate, pamount);
            // adding new amount
            await addAnalysisIncomeDailyAmount(ndate,namount);
            await addAnalysisIncomeCategoryAmount(ncategory, ndate, namount);
          }
        }
        else {
          if (pcategory != ncategory){
            await deleteTransactionUpdateAnalysisIncomeCategoryAmount(pcategory, pdate, pamount);
            // adding new amount
            await addAnalysisIncomeCategoryAmount(ncategory, ndate, namount);
          }
        }
      }
    }
    if( DateTime.now().day == ndate.day || DateTime.now().subtract(Duration(days: 1)).day == ndate.day){
      aController.getCurrentIncomeExpense();
    }
    //
    //   var finalDate = pdate == ndate ? pdate : ndate;
    //   var finalamount = pamount == namount ? pamount : namount;
    //
    //
    // }
    // if(pamount != namount) {
    //   var difference = pamount - namount;
    //   var temp = controller.currentBalance.value + difference;
    //
    //   // update current balance
    //   firestore.collection('users').doc(cValue.currentUser.value.uid).collection("balance").doc("currentBalance").update({
    //       "currentBalance": encryptData(temp.toString(), cValue.currentUser.value.key)
    //   });
    //   controller.getCurrentBalance();
    //
    //   // update transaction
    //   firestore.collection('users').doc(cValue.currentUser.value.uid).collection("transactions").doc(uid).update({"amount": encryptData(namount.toString(), cValue.currentUser.value.key) });
    //
    //   // update analysis values
    //   var finalDate = pdate == ndate ? pdate : ndate;
    //   var finalCategory = pcategory == ncategory ? pcategory : ncategory;
    //   await updateAnalysisExpenseYearlyAmount(finalDate, difference);
    //   await updateAnalysisExpenseMonthlyAmount(finalDate, difference);
    //   await updateAnalysisExpenseDailyAmount(finalDate, difference);
    //   await updateAnalysisExpenseCategoryAmount(finalCategory, finalDate, difference);
    // }
    // if(pdate != ndate) {
    //   // update recode
    //   firestore.collection('users').doc(cValue.currentUser.value.uid).collection("transactions")
    //       .doc(uid).update({"date_time": ndate.toIso8601String()});
    //
    //   // update analysis
    //
    // }
    update();
  }
  Future<void> deleteIncomeRecode(String uid,double amount,category,date) async{
    var temp = controller.currentBalance.value - amount;
    // update current balance
    await firestore.collection('users').doc(cValue.currentUser.value.uid).collection("balance").doc("currentBalance").update({
      "currentBalance": encryptData(temp.toInt().toString(), cValue.currentUser.value.key)
    });
    controller.getCurrentBalance();

    // delete transaction
    await firestore.collection('users').doc(cValue.currentUser.value.uid).collection("transactions").doc(uid).delete().then((value) => null).onError((error, stackTrace) {print(error);});

    // change category total
    await deleteTransactionUpdateAnalysisIncomeYearlyAmount(date, amount);
    await deleteTransactionUpdateAnalysisIncomeMonthlyAmount(date, amount);
    await deleteTransactionUpdateAnalysisIncomeDailyAmount(date,amount);
    await deleteTransactionUpdateAnalysisIncomeCategoryAmount(category, date, amount);

    if( DateTime.now().day == date.day || DateTime.now().subtract(Duration(days: 1)).day == date.day){
      aController.getCurrentIncomeExpense();
    }
    update();
  }

  // yearly total analysis
  Future<void> addAnalysisIncomeYearlyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis");
    double value = 0;
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.year.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        value = double.parse(decryptData(data["yTotalIncome"].toString(), cValue.currentUser.value.key)) + amount;
        await _myCollection.doc(date.year.toString()).update({
          "yTotalIncome": encryptData( value.toString(), cValue.currentUser.value.key),
        });
      } else {
        value = amount;
        firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
            .doc(date.year.toString()).set({
          "yTotalExpense": encryptData( "0.0", cValue.currentUser.value.key),
          "yTotalIncome": encryptData( value.toString(), cValue.currentUser.value.key),
        }
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> deleteTransactionUpdateAnalysisIncomeYearlyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis");
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.year.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        var currentAmount = double.parse(decryptData(data["yTotalIncome"].toString(), cValue.currentUser.value.key));
        currentAmount = currentAmount - amount;
        await _myCollection.doc(date.year.toString()).update({
          "yTotalIncome": encryptData(currentAmount.toString(), cValue.currentUser.value.key),
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // monthly analysis
  Future<void> addAnalysisIncomeMonthlyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months");
    double value = 0;
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.month.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        value = double.parse(decryptData(data["mTotalIncome"].toString(), cValue.currentUser.value.key)) + amount;
        await _myCollection.doc(date.month.toString()).update({
          "mTotalIncome": encryptData(value.toString(), cValue.currentUser.value.key),
        });
      } else {
        value = amount;
        firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis").doc(date.year.toString())
            .collection("months").doc(date.month.toString()).set({
          "mTotalIncome": encryptData(value.toString(), cValue.currentUser.value.key),
          "mTotalExpense": encryptData( "0.0", cValue.currentUser.value.key)});
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> deleteTransactionUpdateAnalysisIncomeMonthlyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months");
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.month.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        var currentAmount = double.parse(decryptData(data["mTotalIncome"].toString(), cValue.currentUser.value.key));
        currentAmount = currentAmount - amount;
        await _myCollection.doc(date.month.toString()).update({
          "mTotalIncome": encryptData(currentAmount.toString(), cValue.currentUser.value.key),
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // daily total analysis
  Future<void> addAnalysisIncomeDailyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months").doc(date.month.toString()).collection("days");
    double value = 0;
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.day.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        value = double.parse(decryptData(data["dTotalIncome"].toString(), cValue.currentUser.value.key)) + amount;
        print(value);
        await _myCollection.doc(date.day.toString()).update({
          "dTotalIncome": encryptData(value.toString(), cValue.currentUser.value.key),
        });
      } else {
        value = amount;
        firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis").doc(date.year.toString())
            .collection("months").doc(date.month.toString()).collection("days").doc(date.day.toString())
            .set({
          "dTotalExpense": encryptData( "0.0", cValue.currentUser.value.key),
          "dTotalIncome":encryptData(value.toString(), cValue.currentUser.value.key)});
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> deleteTransactionUpdateAnalysisIncomeDailyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months").doc(date.month.toString()).collection("days");
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.day.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        var currentAmount = double.parse(decryptData(data["dTotalIncome"].toString(), cValue.currentUser.value.key));
        currentAmount = currentAmount - amount;
        await _myCollection.doc(date.day.toString()).update({
          "dTotalIncome": encryptData(currentAmount.toString(), cValue.currentUser.value.key),
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // daily category vise total
  Future<void> addAnalysisIncomeCategoryAmount(category,date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months").doc(date.month.toString()).collection("days").doc(date.day.toString())
        .collection("incomeCategory");
    double value = 0;
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(category).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        value = double.parse(decryptData(data["$category"].toString(), cValue.currentUser.value.key)) + amount;
        await _myCollection.doc(category).update({
          "$category": encryptData(value.toString(), cValue.currentUser.value.key),
        });
      } else {
        value = amount;
        await firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis").doc(date.year.toString())
            .collection("months").doc(date.month.toString()).collection("days").doc(date.day.toString())
            .collection("incomeCategory").doc(category).set({"$category": encryptData(value.toString(), cValue.currentUser.value.key)});
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> deleteTransactionUpdateAnalysisIncomeCategoryAmount(category,date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months").doc(date.month.toString()).collection("days").doc(date.day.toString())
        .collection("incomeCategory");
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(category).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        var currentAmount = double.parse(decryptData(data["$category"].toString(), cValue.currentUser.value.key));
        currentAmount = currentAmount - amount;
        await _myCollection.doc(category).update({
          "$category": encryptData(currentAmount.toString(), cValue.currentUser.value.key),
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}