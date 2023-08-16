import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../User_Analysis/analysis_datamodel.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;
final UserController controller = Get.put(UserController());
final commanValue cValue = Get.put(commanValue());
final aController = Get.put(analysisController());
var uid = cValue.currentUser.value.uid;

class ExpenseDataModel{
  String title;
  String category;
  double amount;
  String method;
  String date_time;
  String additional_info;

  ExpenseDataModel(this.additional_info, {required this.title, required this.category, required this.amount, required this.method,
      required this.date_time});

  factory ExpenseDataModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return ExpenseDataModel(
      data['additional_info'],
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      amount: data['amount'] ?? 0.0,
      date_time: data['date_time'] ?? '',
      method: data['method'] ?? '',
    );
  }
}

class UserExpenseController extends GetxController {
  String title = "";
  String category = "";
  int amount = 0;
  String method = "";
  String dob="";
  String additionalInfo = "";
  List<dynamic> e_Category = [].obs;
  ExpenseDataModel? userExpense;

  // expense Category's
  Future<void> addExpenseCategoryItem(BuildContext context, String filed, dynamic value) async {
    try {
      final documentReference = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("userCategory").doc("expense");
      // Use FieldValue to update the array field.
      final updateData = {"$filed": FieldValue.arrayUnion([encryptData(value, cValue.currentUser.value.key)])};
      await documentReference.update(updateData);
      updateExpenseCategoryList();
      Navigator.of(context).pop();
      showTopTitleSnackBar(context, Icons.add_alert, "Category Added Successfully");
    } on FirebaseException catch (e) {
      Navigator.of(context).pop();
      print(e);
      showTopSnackBar(context, Icons.add_alert, "Category Not Added","Try Again...!");
    }
  }
  Future<void> updateExpenseCategoryList() async {
    try {
      final documentReference = firestore.collection("users").doc(cValue.currentUser.value.uid).collection("userCategory").doc("expense");
      final querySnapshot = await documentReference.get();
      Map<String, dynamic> list = querySnapshot.data() as Map<String, dynamic>;
      var temp = list["expenseCategory"];
      e_Category.clear();
      for (int i = 0; i < temp.length; i++) {
        e_Category.add(decryptData(temp[i], cValue.currentUser.value.key));
      }
      print(e_Category);
    } catch (e) {
      print('Error getting field value: $e');
    }
    update();
  }
  Future<void> deleteExpenseCategoryItem(BuildContext context,String filed, dynamic value) async {
    try {
      final documentReference = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("userCategory").doc("expense");
      // Use FieldValue to remove the item from the array field.
      final updateData = {"$filed": FieldValue.arrayRemove([encryptData(value, cValue.currentUser.value.key)])};
      await documentReference.update(updateData);
      updateExpenseCategoryList();
      Navigator.of(context).pop();
      showTopTitleSnackBar(context, Icons.add_alert, "Category Deleted Successfully");
    } catch (e) {
      Navigator.of(context).pop();
      showTopSnackBar(context, Icons.add_alert, "Category Not Deleted","Try Again...!");
    }
  }

  // transaction recodes
  Future<void> addExpenseRecode(String title, String category, double amount, String method, DateTime date, String info) async {
    CollectionReference users = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("transactions");
    DocumentReference newDocRef = users.doc();
    var temp = controller.currentBalance.value.toDouble();
    temp = temp - amount;
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
      'type': encryptData("expense", cValue.currentUser.value.key),
      "amount" : encryptData(amount.toString(), cValue.currentUser.value.key),
      "category" : encryptData(category.toString(), cValue.currentUser.value.key) ,
      "date_time": date.toIso8601String(),
      "method": encryptData(method.toString(), cValue.currentUser.value.key),
      "title": encryptData(title.toString(), cValue.currentUser.value.key),
    };
    await newDocRef.set(data);
    await addAnalysisExpenseYearlyAmount(date, amount);
    await addAnalysisExpenseMonthlyAmount(date, amount);
    await addAnalysisExpenseDailyAmount(date, amount);
    await addAnalysisExpenseCategoryAmount(category.toString(),date,amount);
    // await firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
    //     .doc(date.year.toString()).collection(date.month.toString()).doc(date.day.toString())
    //     .collection("Category").doc(category.toString()).set({
    //   "${category.toString()}" : amount.toString(),
    // });
    if( DateTime.now().day == date.day || DateTime.now().subtract(Duration(days: 1)).day == date.day){
      aController.getCurrentIncomeExpense();
    }
    controller.getCurrentBalance();
    update();
  }
  Future<void> updateExpenseRecode(String uid, String ntitle, String ncategory, double namount, String nmethod, DateTime ndate, String ninfo, String ptitle, String pcategory, double pamount, String pmethod, DateTime pdate, String pinfo) async {
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
        var temp = controller.currentBalance.value + difference;

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
        await deleteTransactionUpdateAnalysisExpenseYearlyAmount(pdate, pamount);
        await deleteTransactionUpdateAnalysisExpenseMonthlyAmount(pdate, pamount);
        await deleteTransactionUpdateAnalysisExpenseDailyAmount(pdate,pamount);
        await deleteTransactionUpdateAnalysisExpenseCategoryAmount(pcategory, pdate, pamount);
        // adding new amount
        await addAnalysisExpenseYearlyAmount(ndate, namount);
        await addAnalysisExpenseMonthlyAmount(ndate, namount);
        await addAnalysisExpenseDailyAmount(ndate,namount);
        await addAnalysisExpenseCategoryAmount(ncategory, ndate, namount);
      }
      else {
        if( pdate != ndate ){
          if(pdate.year != ndate.year){
            await deleteTransactionUpdateAnalysisExpenseYearlyAmount(pdate, pamount);
            await deleteTransactionUpdateAnalysisExpenseMonthlyAmount(pdate, pamount);
            await deleteTransactionUpdateAnalysisExpenseDailyAmount(pdate,pamount);
            await deleteTransactionUpdateAnalysisExpenseCategoryAmount(pcategory, pdate, pamount);
            // adding new amount
            await addAnalysisExpenseYearlyAmount(ndate, namount);
            await addAnalysisExpenseMonthlyAmount(ndate, namount);
            await addAnalysisExpenseDailyAmount(ndate,namount);
            await addAnalysisExpenseCategoryAmount(ncategory, ndate, namount);
          }
          else if (pdate.month != ndate.month){
            await deleteTransactionUpdateAnalysisExpenseMonthlyAmount(pdate, pamount);
            await deleteTransactionUpdateAnalysisExpenseDailyAmount(pdate,pamount);
            await deleteTransactionUpdateAnalysisExpenseCategoryAmount(pcategory, pdate, pamount);
            // adding new amount
            await addAnalysisExpenseMonthlyAmount(ndate, namount);
            await addAnalysisExpenseDailyAmount(ndate,namount);
            await addAnalysisExpenseCategoryAmount(ncategory, ndate, namount);
          }
          else if (pdate.day != ndate.day){
            await deleteTransactionUpdateAnalysisExpenseDailyAmount(pdate,pamount);
            await deleteTransactionUpdateAnalysisExpenseCategoryAmount(pcategory, pdate, pamount);
            // adding new amount
            await addAnalysisExpenseDailyAmount(ndate,namount);
            await addAnalysisExpenseCategoryAmount(ncategory, ndate, namount);
          }
        }
        else {
          if (pcategory != ncategory){
            await deleteTransactionUpdateAnalysisExpenseCategoryAmount(pcategory, pdate, pamount);
            // adding new amount
            await addAnalysisExpenseCategoryAmount(ncategory, ndate, namount);
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
  Future<void> deleteExpenseRecode(String uid,double amount,category,date) async{
    var temp = controller.currentBalance.value + amount;
    // update current balance
    await firestore.collection('users').doc(cValue.currentUser.value.uid).collection("balance").doc("currentBalance").update({
    "currentBalance": encryptData(temp.toInt().toString(), cValue.currentUser.value.key)
    });
    controller.getCurrentBalance();

    // delete transaction
    await firestore.collection('users').doc(cValue.currentUser.value.uid).collection("transactions").doc(uid).delete().then((value) => null).onError((error, stackTrace) {print(error);});

    // change category total
    await deleteTransactionUpdateAnalysisExpenseYearlyAmount(date, amount);
    await deleteTransactionUpdateAnalysisExpenseMonthlyAmount(date, amount);
    await deleteTransactionUpdateAnalysisExpenseDailyAmount(date,amount);
    await deleteTransactionUpdateAnalysisExpenseCategoryAmount(category, date, amount);

    if( DateTime.now().day == date.day || DateTime.now().subtract(Duration(days: 1)).day == date.day){
      aController.getCurrentIncomeExpense();
    }
    update();
  }

  // yearly total analysis
  Future<void> addAnalysisExpenseYearlyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis");
    double value = 0;
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.year.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        value = double.parse(decryptData(data["yTotalExpense"].toString(), cValue.currentUser.value.key)) + amount;
        await _myCollection.doc(date.year.toString()).update({
          "yTotalExpense": encryptData( value.toString(), cValue.currentUser.value.key),
        });
      } else {
        value = amount;
        firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
            .doc(date.year.toString()).set({
              "yTotalExpense": encryptData( value.toString(), cValue.currentUser.value.key),
              "yTotalIncome": encryptData( "0.0", cValue.currentUser.value.key)
            }
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> deleteTransactionUpdateAnalysisExpenseYearlyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis");
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.year.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        var currentAmount = double.parse(decryptData(data["yTotalExpense"].toString(), cValue.currentUser.value.key));
        currentAmount = currentAmount - amount;
        await _myCollection.doc(date.year.toString()).update({
          "yTotalExpense": encryptData(currentAmount.toString(), cValue.currentUser.value.key),
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // monthly analysis
  Future<void> addAnalysisExpenseMonthlyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months");
    double value = 0;
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.month.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        value = double.parse(decryptData(data["mTotalExpense"].toString(), cValue.currentUser.value.key)) + amount;
        await _myCollection.doc(date.month.toString()).update({
          "mTotalExpense": encryptData(value.toString(), cValue.currentUser.value.key),
        });
      } else {
        value = amount;
        firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis").doc(date.year.toString())
            .collection("months").doc(date.month.toString()).set({
          "mTotalIncome": encryptData( "0.0", cValue.currentUser.value.key),
          "mTotalExpense":encryptData(value.toString(), cValue.currentUser.value.key)});
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> deleteTransactionUpdateAnalysisExpenseMonthlyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months");
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.month.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        var currentAmount = double.parse(decryptData(data["mTotalExpense"].toString(), cValue.currentUser.value.key));
        currentAmount = currentAmount - amount;
        await _myCollection.doc(date.month.toString()).update({
          "mTotalExpense": encryptData(currentAmount.toString(), cValue.currentUser.value.key),
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // daily total analysis
  Future<void> addAnalysisExpenseDailyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months").doc(date.month.toString()).collection("days");
    double value = 0;
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.day.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        value = double.parse(decryptData(data["dTotalExpense"].toString(), cValue.currentUser.value.key)) + amount;
        print(value);
        await _myCollection.doc(date.day.toString()).update({
          "dTotalExpense": encryptData(value.toString(), cValue.currentUser.value.key),
        });
      } else {
        value = amount;
        firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis").doc(date.year.toString())
            .collection("months").doc(date.month.toString()).collection("days").doc(date.day.toString())
            .set({
          "dTotalIncome": encryptData( "0.0", cValue.currentUser.value.key),
          "dTotalExpense":encryptData(value.toString(), cValue.currentUser.value.key)});
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> deleteTransactionUpdateAnalysisExpenseDailyAmount(date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months").doc(date.month.toString()).collection("days");
    try {
      DocumentSnapshot documentSnapshot = await _myCollection.doc(date.day.toString()).get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic> ;
        var currentAmount = double.parse(decryptData(data["dTotalExpense"].toString(), cValue.currentUser.value.key));
        currentAmount = currentAmount - amount;
        await _myCollection.doc(date.day.toString()).update({
          "dTotalExpense": encryptData(currentAmount.toString(), cValue.currentUser.value.key),
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // daily category vise total
  Future<void> addAnalysisExpenseCategoryAmount(category,date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months").doc(date.month.toString()).collection("days").doc(date.day.toString())
        .collection("expenseCategory");
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
            .collection("expenseCategory").doc(category).set({"$category": encryptData(value.toString(), cValue.currentUser.value.key)});
      }
    } catch (e) {
      print('Error: $e');
    }
  }
  Future<void> deleteTransactionUpdateAnalysisExpenseCategoryAmount(category,date,amount) async {
    final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
        .doc(date.year.toString()).collection("months").doc(date.month.toString()).collection("days").doc(date.day.toString())
        .collection("expenseCategory");
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

// specific day category wase total
// final List<Map<String, dynamic>> categoryList = [];
// await _myCollection.get().then((querySnapshot) {
//   querySnapshot.docs.forEach((doc) {
//     categoryList.add(doc.data());
//   });
// });
// print(categoryList);


// print(data);
// Define the start and end dates for the query
// DateTime march1 = DateTime.utc(DateTime.now().year, 2, 1);
// DateTime april1 = DateTime.utc(DateTime.now().year, 3, 1);
//
//
// try {
//   QuerySnapshot querySnapshot = await users
//       .where("date_time", isGreaterThanOrEqualTo: march1)
//       .where("date_time", isLessThan: april1).get();
//
// // / Get the list of documents returned by the query
// List<QueryDocumentSnapshot> documents = querySnapshot.docs;
//   documents.forEach((doc) {
//     print('UID: ${doc.id}');
//     print("Amount:${doc["amount"]}");
//     print('Date and Time: ${doc['date_time'].toIso8601String()}');
//     // Print other fields as needed
//   });
// } catch (e) {
// // .where('date_time', isGreaterThanOrEqualTo: march1)
// //     .where('date_time', isLessThan: april1)
// //     .orderBy('date_time')
// //     .get();
//
// }
// try {
//   await firestore.collection('transactions').doc(uid)
//         .collection("expense").doc("${date.year}")
//         .collection("months").doc("${date.month}")
//         .collection("day").doc("${date.day}")
//         .collection("time").doc("${date.hour}:${date.minute}:${date.second}")
//         .set(data)
//         .then((value) {
//       print("data recoded");
//     });
// } catch (e) {
//   print('Error updating fields in Firestore: $e');
// }

// var u = ExpenseDataModel.fromSnapshot(snapshot);
// /transactions/FE3BVtHOrrTmfvrGH85fJ8xtzya2/expenses/2023/months/1/day/12/time
// print(snapshot);
// print();
// name = u.name;
// email = u.email;
// f_letter = u.name.toString().substring(0,1).toUpperCase();
// dob = u.dob.toString();
// currentBalance = u.currentBalance;
// photo_url = u.photoUrl;
// phone = u.phoneNumber.toString();
// accessCode = u.accessCode.toString();


// Future<void> AnalysisExpenseAddData(category, date, amount) async {
//   final _myCollection = firestore.collection('users').doc(cValue.currentUser.value.uid).collection("analysis")
//       .doc(date.year.toString()).collection("months").doc(date.month.toString()).collection("days").doc(date.day.toString())
//       .collection("Category");
//   try {
//     DocumentSnapshot documentSnapshot = await _myCollection.doc(category).get();
//     if (documentSnapshot.exists) {
//       var data = documentSnapshot.data() as Map<String, dynamic> ;
//       var temp = double.parse(data["$category"].toString()) + amount;
//       // If document exists, update the data
//       await _myCollection.doc(category).update({
//         "${category.toString()}" : temp.toString(),
//       });
//     } else {
//       // If document doesn't exist, set the data
//       await _myCollection.doc(category).set({
//         "${category.toString()}" : amount.toString(),
//       });
//     }
//   } catch (e) {
//     print('Error: $e');
//   }
// }