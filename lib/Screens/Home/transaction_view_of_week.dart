import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MonthlyView extends StatefulWidget {
  @override
  _MonthlyViewState createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
  final commanValue cValue = Get.put(commanValue());
  TooltipBehavior _tooltipBehavior = TooltipBehavior(enable: true);

  Map<String, dynamic> temp = {};
  List<TransactionData> _TransactionData = [];
  List<DateTime> _DateRange = [];

  void loadLastSevenDays(date) {
    DateTime currentDate = date;
    DateTime startDate = currentDate.subtract(Duration(days: 6));
    _DateRange.clear();
    if (startDate.month != currentDate.month) {
      int daysInMonth = DateTime(startDate.year, startDate.month + 1, 0).day;
      for (int i = startDate.day; i <= daysInMonth; i++) {
        _DateRange.add(DateTime(startDate.year, startDate.month, i));
      }
      for (int i = 1; i <= currentDate.day; i++) {
        _DateRange.add(DateTime(currentDate.year, currentDate.month, i));
      }
    } else {
      for (int i = startDate.day; i <= currentDate.day; i++) {
        _DateRange.add(DateTime(currentDate.year, currentDate.month, i));
      }
    }
  }
  Future<void> getLastSevenDaysData() async {
    DateTime now = DateTime.now();
    loadLastSevenDays(now);
    _TransactionData.clear();
    for (DateTime date in _DateRange) {
      DocumentSnapshot daySnapshot = await FirebaseFirestore.instance.collection('users')
          .doc(cValue.currentUser.value.uid)
          .collection('analysis').doc(date.year.toString())
          .collection('months').doc(date.month.toString())
          .collection('days').doc(date.day.toString())
          .get();
      if (daySnapshot.exists) {
        final dayData = daySnapshot.data() as Map<String, dynamic>;
          double dTotalExpense = double.parse(decryptData(dayData['dTotalExpense'].toString(),cValue.currentUser.value.key));
          double dTotalIncome = double.parse(decryptData(dayData['dTotalIncome'].toString(),cValue.currentUser.value.key));
          String dayName = DateFormat('dd\nEEE').format(date);
          _TransactionData.add(TransactionData(dayName,dTotalIncome,dTotalExpense));
      } else {
        String dayName = DateFormat('dd\nEEE').format(date);
        _TransactionData.add(TransactionData(dayName,0.0,0.0,));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getLastSevenDaysData(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(child: Text('Data loading take time...'));
          }
          else {
            return _TransactionData.isEmpty
                ? Text("Data Not Found!")
                : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Transaction View of Week",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 18),),
                    ),
                    Text("${DateFormat("dd/MM/yyyy").format(_DateRange.first)} to ${DateFormat("dd/MM/yyyy").format(_DateRange.last)}", style: TextStyle(letterSpacing: 2),),
                    Expanded(
                  child: SfCartesianChart(
                    legend: Legend(isVisible: true, position: LegendPosition.bottom),
                    zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning : true, zoomMode: ZoomMode.xy,),
                    tooltipBehavior: _tooltipBehavior,
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(),
                    series: <ChartSeries>[
                      ColumnSeries<TransactionData, String>(
                          dataSource: _TransactionData,
                          xValueMapper: (TransactionData expense, _) => expense.day,
                          yValueMapper: (TransactionData expense, _) =>
                          expense.income,
                          name: 'Income',
                          color: Colors.green),
                      ColumnSeries<TransactionData, String>(
                          dataSource: _TransactionData,
                          xValueMapper: (TransactionData expense, _) => expense.day,
                          yValueMapper: (TransactionData expense, _) =>
                          expense.expense,
                          name: 'Expense',
                          color: Colors.red),
                    ],
                  ),
                ),
                    Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Average Daily Income:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹ ${_getAverageIncome().toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Average Daily Expense:',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹ ${_getAverageExpense().toStringAsFixed(2)}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 15,),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  double _getAverageIncome() {
    double totalIncome =
        _TransactionData.fold(0, (sum, expense) => sum + expense.income);
    return totalIncome / _TransactionData.length;
  }

  double _getAverageExpense() {
    double totalExpense =
        _TransactionData.fold(0, (sum, expense) => sum + expense.expense);
    return totalExpense / _TransactionData.length;
  }
}

class TransactionData {
  final String day;
  final double income;
  final double expense;

  TransactionData(this.day, this.income, this.expense);
}
