import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final commanValue cValue = Get.put(commanValue());
final firestore = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid.toString());
CollectionReference collectionRef = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid.toString()).collection("transactions");

class analysisController extends GetxController {
  var currentExpense = RxDouble(0.0).obs;
  var previousExpense = RxDouble(0.0).obs;
  var currentIncome = RxDouble(0.0).obs;
  var previousIncome = RxDouble(0.0).obs;
  var currentExpensePR = RxDouble(0.0).obs;
  var currentIncomePR = RxDouble(0.0).obs;
  List<mExpense> mexpense = [];
  List<category> mExpenseCategory = [];

  Future<void> getCurrentIncomeExpense() async {
    await firestore.collection("analysis").doc(DateTime.now().year.toString()).collection("months")
        .doc(DateTime.now().month.toString()).collection("days").doc(DateTime.now().day.toString())
        .get().then((value){
          if (value.exists) {
            var data = value.data() as Map<String, dynamic>;
            currentExpense.value = RxDouble(double.parse(decryptData(data["dTotalExpense"].toString(), cValue.currentUser.value.key)));
            currentIncome.value = RxDouble(double.parse(decryptData(data["dTotalIncome"].toString(), cValue.currentUser.value.key)));
          }
        }).onError((error, stackTrace) {
      print(error);
    });
    await firestore.collection("analysis").doc(DateTime.now().year.toString()).collection("months")
        .doc(DateTime.now().month.toString()).collection("days").doc(DateTime.now().subtract(Duration(days: 1)).day.toString())
        .get().then((value){
          if(value.exists) {
            var data = value.data() as Map<String, dynamic>;
            previousExpense.value = RxDouble(double.parse(decryptData(data["dTotalExpense"].toString(), cValue.currentUser.value.key)));
            previousIncome.value = RxDouble(double.parse(decryptData(data["dTotalIncome"].toString(), cValue.currentUser.value.key)));
          }
      }).onError((error, stackTrace) {
      print(error);
    });
    currentExpensePR.value = RxDouble(calculatePercentageChange(previousExpense.value.toDouble(), currentExpense.value.toDouble()));
    currentIncomePR.value = RxDouble(calculatePercentageChange(previousIncome.value.toDouble(), currentIncome.value.toDouble()));
    update();
  }

  // Future<void> getCurrentExpense() async {
  //   var day = DateTime.now();
  //   final startOfDay = DateTime(day.year, day.month, day.day);
  //   final previousDate = startOfDay.subtract(Duration(days: 1));
  //   final endOfDay = startOfDay.add(Duration(days: 1));
  //   //today expense
  //   final query1 = collectionRef.where('date_time', isGreaterThanOrEqualTo: startOfDay.toIso8601String()).where('date_time', isLessThan: endOfDay.toIso8601String());
  //   final snapshot1 = await query1.get();
  //   if (snapshot1.docs.isNotEmpty){
  //     final amountList  = await extractData(snapshot1.docs);
  //     var totalAmount = amountList.reduce((a, b) => a + b);
  //     currentExpense.value = RxDouble(totalAmount);
  //   } else {
  //     currentExpense.value = RxDouble(0);
  //   }
  //
  //   // Yesterday expense
  //   final query0 = collectionRef.where('date_time', isGreaterThanOrEqualTo: previousDate.toIso8601String()).where('date_time', isLessThan: startOfDay.toIso8601String());
  //   final snapshot0 = await query0.get();
  //   if (snapshot0.docs.isNotEmpty){
  //     final amountList  = await extractData(snapshot0.docs);
  //     var totalAmount = amountList.reduce((a, b) => a + b);
  //     previousExpense.value = RxDouble(totalAmount);
  //   } else {
  //     previousExpense.value = RxDouble(0);
  //   }
  //
  //   // await daysCollection.get().then((querySnapshot) {
  //   //   querySnapshot.docs.forEach((doc) {
  //   //     final data = doc.data() as  Map<String, dynamic>;
  //   //     print(data.toString());
  //   //     daysCollection.doc(doc.id).collection("category").get().then((querySnapshot) {
  //   //       querySnapshot.docs.forEach((doc) async {
  //   //         final data = doc.data() as Map<String, dynamic>;
  //   //         dataList.add(data["${doc.id}"]);
  //   //       });
  //   //     });
  //   //   });
  //   // });
  //
  //   // double amount = double.parse(data["${doc.id}"]);
  //   // if (mCategoryDataGroup.containsKey(doc.id)) {
  //   //   mCategoryDataGroup[doc.id] = mCategoryDataGroup[doc.id]!.toDouble() + amount;
  //   // } else {
  //   //   mCategoryDataGroup[doc.id] = amount;
  //   // }
  //   // print(doc.id);
  //
  //   // expense percentage
  //   currentExpensePR.value = RxDouble((calculatePercentageChange(previousExpense.value.toDouble(), currentExpense.value.toDouble())));
  //   mexpense = await getMonthAmountPairsForCurrentYear();
  //   // currentExpensePR.value = (calculatePercentageChange(550, 1757)).toInt();
  //   // print(currentExpensePR);
  //   // double totalAmount = 0.0;
  //   // snapshot.docs.forEach((doc) {
  //   //   final amount = doc.data['amount'] as double;
  //   //   totalAmount += amount;
  //   // });
  //   // Query query = collectionRef.where('date_time', isEqualTo: Timestamp.fromDate(_currentDate)).(['amount',]);
  // }

  // Future<void> loadFromStorage() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   currentExpense.value = prefs.getInt('currentExpense') ?? currentExpense.value;
  //   currentExpense.value = prefs.getInt('currentExpense') ?? currentExpense.value;
  // }
  //
  // Future<void> saveToStorage() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('current_user_uid', current_user_uid.value);
  //   await prefs.setString('current_user_email', current_user_email.value);
  // }
  double calculatePercentageChange(double previous, double current) {
    if (previous == null || previous == 0 || current == 0) {
      return 0.0;
    }
    final difference = current - previous;
    final percentChange = (difference / previous) * 100;
    return percentChange;
  }
  //
  // Future<List<double>> extractData(List<QueryDocumentSnapshot<Object?>> docs) async {
  //   final amountList = <double>[];
  //   docs.forEach((doc) {
  //     final data = doc.data() as Map<String, dynamic>;
  //     String temp = decryptData(data['amount'].toString(), cValue.currentUser.value.key.toString());
  //     final amount = double.parse(temp);
  //     if (amount != null) {
  //       amountList.add(amount);
  //     }
  //   });
  //   return amountList;
  // }
}

//  Future<Map<String, double>> fetchMonthlyAmounts() async {
//     final amountsByMonth = Map<String, double>();
//     final querySnapshot = await FirebaseFirestore.instance
//         .collection('users').doc(cValue.current_user_uid.value).collection("transactions")
//         .orderBy('date_time', descending: true)
//         .get();
//
//     querySnapshot.docs.forEach((doc) {
//       final date = DateTime.parse(doc['date_time']);
//       final month = DateFormat('yyyy-MMMM').format(date);
//       final amount = doc['amount'] ?? 0.0;
//
//       if (amountsByMonth.containsKey(month) || amountsByMonth[month] != null ) {
//         amountsByMonth[month] = amountsByMonth[month]!.toDouble() + double.parse(amount.toString());
//       } else {
//         amountsByMonth[month] = double.parse(amount.toString());
//       }
//     });
//
//     return amountsByMonth;
//   }
//Future<void> printData() async {
//       Map<String, double> data = await fetchMonthlyAmounts(); // Replace 'fetchData()' with your own asynchronous function to fetch the data
//       print('Data: $data');
//     }

// Function to get the total amount for each month in the current year

// Future<List<mExpense>> getMonthAmountPairsForCurrentYear() async {
//   // Get the current year
//   int currentYear = DateTime.now().year;
//
//   // Query the expenses collection for expenses with date in the current year
//   QuerySnapshot querySnapshot = await collectionRef
//       .where('date_time', isGreaterThanOrEqualTo: DateTime(currentYear).toIso8601String())
//       .get();
//
//   // Create a map to store the total amount for each month
//   Map<int, double> monthAmountMap = {};
//
//   // Loop through the query snapshot and add up the total amount for each month
//   for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
//     // Parse the ISO8601 date string into a DateTime object
//     DateTime date = DateTime.parse(docSnapshot['date_time']);
//
//     // Check if the date is in the current year
//     if (date.year == currentYear) {
//       int month = date.month;
//       double amount = double.parse(decryptData(docSnapshot['amount'].toString(), cValue.currentUser.value.key.toString()));
//
//       if (monthAmountMap.containsKey(month)) {
//         monthAmountMap[month] = monthAmountMap[month]!.toDouble() + double.parse(amount.toString());
//       } else {
//         monthAmountMap[month] = amount;
//       }
//     }
//   }
//   // Create a list of month-amount pairs from the map
//   List<mExpense> expenses = [];
//   for (int month = 1; month <= 12; month++) {
//     double amount = monthAmountMap[month] ?? 0;
//     String monthName = DateFormat('MMM').format(DateTime(0, month));
//     if( amount > 0) {
//       expenses.add(mExpense(monthName, amount));
//     }
//   }
//   // Return the list of month-amount pairs
//   return expenses;
// }


class mExpense{
  final String month;
  final double amount;
  mExpense(this.month, this.amount);
}

class mIncome{
  final String month;
  final double amount;
  mIncome(this.month, this.amount);
}

class category{
  final String name;
  final double amount;
  category(this.name,this.amount);
}