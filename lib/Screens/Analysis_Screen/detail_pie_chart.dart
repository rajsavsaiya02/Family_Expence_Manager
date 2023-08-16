import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/FireStore_Database/User_Analysis/analysis_datamodel.dart';
import 'package:fem/Screens/Analysis_Screen/Charts/expense_income_charts.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Utility/Colors.dart';

class Expense {
  final String category;
  final double amount;
  Expense(this.category, this.amount);
}

class DetailPieChart extends StatefulWidget {
  String type;
  Map<String, dynamic> data;
  DetailPieChart(this.type,Map<String, dynamic> this.data);

  @override
  _DetailPieChartState createState() => _DetailPieChartState();
}

class _DetailPieChartState extends State<DetailPieChart> {
  List<Expense> datalist = [];

  @override
  void initState() {
    super.initState();
    datalist.clear();
    widget.data.forEach((title, amount) {
      if( amount > 0){
        datalist.add(Expense(title, amount));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.type == "Expense" ? Text('Expense In Detail') : Text('Income In Detail'),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 5,
      ),
      body: datalist.isEmpty ? Center(child: Text("Data Not Found!")) : Column(
              children: [
                Container(
                  height: 300,
                  child: SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                    ),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      format: 'point.x : point.y',
                    ),
                    series: <CircularSeries>[
                      PieSeries<Expense, String>(
                        dataSource: datalist,
                        xValueMapper: (Expense data, _) => data.category,
                        yValueMapper: (Expense data, _) => data.amount,
                        pointColorMapper: (Expense expense, _) =>
                        Colors.accents[datalist.indexOf(expense) % 10],
                        explode: true,
                        explodeIndex: 0,
                        animationDuration: 800,
                        onPointDoubleTap: (ChartPointDetails args) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(datalist[int.parse(args.pointIndex.toString())].category),
                                content: Text('Amount: Rs. ${datalist[int.parse(args.pointIndex.toString())].amount}'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: datalist.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.accents[index % 10],
                        ),
                        title: Text(datalist[index].category),
                        trailing: Text('₹ ${datalist[index].amount.toStringAsFixed(2)}'),
                      );
                    },
                  ),
                ),
              ],
            )
    );
  }
}
//
// Future<void> getMonthlyExpenseCategory() async {
//   temp.clear();
//   final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
//       .doc(now.year.toString())
//       .collection('months')
//       .doc(now.month.toString())
//       .collection('days');
//   QuerySnapshot daysSnapshot = await daysCollection.get();
//   for (QueryDocumentSnapshot day in daysSnapshot.docs) {
//     final dayData = day.data() as Map<String, dynamic>;
//     QuerySnapshot categorySnapshot = await daysCollection.doc(day.id).collection("incomeCategory").get();
//     for (QueryDocumentSnapshot data in categorySnapshot.docs) {
//       final categoryData = data.data() as Map<String, dynamic>;
//       String title = data.id;
//       print("$title");
//       double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
//       if (temp.containsKey(title)) {
//         temp[title] += amount;
//       } else {
//         temp[title] = amount;
//       }
//     }
//   }
// }
// Future<void> getDailyExpenseCategory(DateTime date) async {
//   temp.clear();
//   final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
//       .doc(date.year.toString())
//       .collection('months')
//       .doc(date.month.toString())
//       .collection('days')
//       .doc(date.day.toString());
//   QuerySnapshot categorySnapshot = await daysCollection.collection("incomeCategory").get();
//   for (QueryDocumentSnapshot data in categorySnapshot.docs) {
//     final categoryData = data.data() as Map<String, dynamic>;
//     String title = data.id;
//     print("$title");
//     double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
//     if (temp.containsKey(title)) {
//       temp[title] += amount;
//     } else {
//       temp[title] = amount;
//     }
//   }
// }
//
// Future<void> getLastYearExpenseCategory() async {
//   temp.clear();
//   DateTime today = DateTime.now();
//   for (int i = 0; i < 12; i++) {
//     DateTime date = DateTime(today.year, today.month - i, 1);
//     final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
//         .doc(date.year.toString())
//         .collection('months')
//         .doc(date.month.toString());
//     QuerySnapshot daysSnapshot = await daysCollection.collection('days').get();
//     for (QueryDocumentSnapshot day in daysSnapshot.docs) {
//       QuerySnapshot categorySnapshot = await day.reference.collection("incomeCategory").get();
//       for (QueryDocumentSnapshot data in categorySnapshot.docs) {
//         final categoryData = data.data() as Map<String, dynamic>;
//         String title = data.id;
//         print("$title");
//         double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
//         if (temp.containsKey(title)) {
//           temp[title] += amount;
//         } else {
//           temp[title] = amount;
//         }
//       }
//     }
//   }
// }
// Future<void> getLastMonthExpenseCategory() async {
//   temp.clear();
//   DateTime now = DateTime.now();
//   DateTime lastMonth = DateTime(now.year, now.month - 1, 1);
//   int lastMonthDays = DateTime(lastMonth.year, lastMonth.month + 1, 0).day;
//
//   for (int i = 1; i <= lastMonthDays; i++) {
//     final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
//         .doc(lastMonth.year.toString())
//         .collection('months')
//         .doc(lastMonth.month.toString())
//         .collection('days')
//         .doc(i.toString());
//     QuerySnapshot categorySnapshot = await daysCollection.collection("incomeCategory").get();
//     for (QueryDocumentSnapshot data in categorySnapshot.docs) {
//       final categoryData = data.data() as Map<String, dynamic>;
//       String title = data.id;
//       print("$title");
//       double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
//       if (temp.containsKey(title)) {
//         temp[title] += amount;
//       } else {
//         temp[title] = amount;
//       }
//     }
//   }
// }
// Future<void> getLastSevenDaysExpenseCategory() async {
//   temp.clear();
//   DateTime today = DateTime.now();
//   for (int i = 0; i < 7; i++) {
//     DateTime date = today.subtract(Duration(days: i));
//     final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
//         .doc(date.year.toString())
//         .collection('months')
//         .doc(date.month.toString())
//         .collection('days')
//         .doc(date.day.toString());
//     QuerySnapshot categorySnapshot = await daysCollection.collection("incomeCategory").get();
//     for (QueryDocumentSnapshot data in categorySnapshot.docs) {
//       final categoryData = data.data() as Map<String, dynamic>;
//       String title = data.id;
//       print("$title");
//       double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
//       if (temp.containsKey(title)) {
//         temp[title] += amount;
//       } else {
//         temp[title] = amount;
//       }
//     }
//   }
// }