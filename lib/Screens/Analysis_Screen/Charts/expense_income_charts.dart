import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Screens/Analysis_Screen/detail_pie_chart.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class ExpenseIncomeCharts extends StatefulWidget {
  final String pageType;
  const ExpenseIncomeCharts({required this.pageType,Key? key}) : super(key: key);

  @override
  State<ExpenseIncomeCharts> createState() => _ExpenseIncomeChartsState();
}

class _ExpenseIncomeChartsState extends State<ExpenseIncomeCharts> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final commanValue cValue = Get.put(commanValue());
  final TextEditingController startingDateContoller = TextEditingController();
  final TextEditingController endingDateContoller = TextEditingController();
  List<DateTime> _DateRange = [];
  List<PieChartData> Total = [];
  List<ExpensePieChart> ExpensePieCharts = [];
  List<IncomePieChart> IncomePieCharts = [];
  Map<String, dynamic>  i_temp = {};
  Map<String, dynamic>  e_temp = {};

  //Functions
  //Custom
  Future<void> getCustomExpensePieChartCategory(DateTime startDate, DateTime endDate) async {
    e_temp.clear();
    _DateRange.clear();
    for (var i = startDate; i.isBefore(endDate); i = i.add(Duration(days: 1))) {
      _DateRange.add(i);
    }
    _DateRange.add(endDate);
    for (DateTime date in _DateRange) {
      final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid)
          .collection('analysis').doc(date.year.toString())
          .collection('months').doc(date.month.toString())
          .collection('days').doc(date.day.toString());
      QuerySnapshot categorySnapshot = await daysCollection.collection("expenseCategory").get();
      if(categorySnapshot.docs.isNotEmpty){
        for (QueryDocumentSnapshot data in categorySnapshot.docs) {
          final categoryData = data.data() as Map<String, dynamic>;
          String title = data.id;
          double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
          if (e_temp.containsKey(title)) {
            e_temp[title] += amount;
          } else {
            e_temp[title] = amount;
          }
        }
      }
    }
  }
  Future<void> getCustomIncomePieChartCategory(DateTime startDate, DateTime endDate) async {
    i_temp.clear();
    _DateRange.clear();
    for (var i = startDate; i.isBefore(endDate); i = i.add(Duration(days: 1))) {
      _DateRange.add(i);
    }
    _DateRange.add(endDate);
    for (DateTime date in _DateRange) {
      final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid)
          .collection('analysis').doc(date.year.toString())
          .collection('months').doc(date.month.toString())
          .collection('days').doc(date.day.toString());
      QuerySnapshot categorySnapshot = await daysCollection.collection("incomeCategory").get();
      if(categorySnapshot.docs.isNotEmpty){
        for (QueryDocumentSnapshot data in categorySnapshot.docs) {
          final categoryData = data.data() as Map<String, dynamic>;
          String title = data.id;
          double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
          if (i_temp.containsKey(title)) {
            i_temp[title] += amount;
          } else {
            i_temp[title] = amount;
          }
        }
      }
    }
  }
  Future<void> getCustomTotalExpenseIncome(DateTime startDate, DateTime endDate) async {
    Total.clear();
    _DateRange.clear();
    for (var i = startDate; i.isBefore(endDate); i = i.add(Duration(days: 1))) {
      _DateRange.add(i);
    }
    _DateRange.add(endDate);
    double _totalIncome = 0.0;
    double _totalExpense = 0.0;
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
        _totalExpense += dTotalExpense;
        _totalIncome += dTotalIncome;
      }
    }
    Total.add(PieChartData(category: "Expense", amount: _totalExpense));
    Total.add(PieChartData(category: "Income", amount: _totalIncome));
  }

  //Today
  Future<void> getTodayExpensePieChartCategory() async {
    DateTime date = DateTime.now();
    e_temp.clear();
    ExpensePieCharts.clear();
    final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
        .doc(date.year.toString())
        .collection('months')
        .doc(date.month.toString())
        .collection('days')
        .doc(date.day.toString());
    QuerySnapshot categorySnapshot = await daysCollection.collection("expenseCategory").get();
    for (QueryDocumentSnapshot data in categorySnapshot.docs) {
      final categoryData = data.data() as Map<String, dynamic>;
      String title = data.id;
      double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
      if (e_temp.containsKey(title)) {
        e_temp[title] += amount;
      } else {
        e_temp[title] = amount;
      }
    }
  }
  Future<void> getTodayIncomePieChartCategory() async {
    DateTime date = DateTime.now();
    IncomePieCharts.clear();
    i_temp.clear();
    final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
        .doc(date.year.toString())
        .collection('months')
        .doc(date.month.toString())
        .collection('days')
        .doc(date.day.toString());
    QuerySnapshot categorySnapshot = await daysCollection.collection("incomeCategory").get();
    for (QueryDocumentSnapshot data in categorySnapshot.docs) {
      final categoryData = data.data() as Map<String, dynamic>;
      String title = data.id;
      double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
      if (i_temp.containsKey(title)) {
        i_temp[title] += amount;
      } else {
        i_temp[title] = amount;
      }
    }
  }
  Future<void> getTodayTotalExpenseIncome() async {
    Total.clear();
    DateTime now = DateTime.now();
      DocumentSnapshot daySnapshot = await FirebaseFirestore.instance.collection('users')
          .doc(cValue.currentUser.value.uid)
          .collection('analysis').doc(now.year.toString())
          .collection('months').doc(now.month.toString())
          .collection('days').doc(now.day.toString())
          .get();
      if (daySnapshot.exists) {
        final dayData = daySnapshot.data() as Map<String, dynamic>;
        double dTotalExpense = double.parse(decryptData(dayData['dTotalExpense'].toString(),cValue.currentUser.value.key));
        double dTotalIncome = double.parse(decryptData(dayData['dTotalIncome'].toString(),cValue.currentUser.value.key));
        Total.add(PieChartData(category: "Expense", amount: dTotalExpense));
        Total.add(PieChartData(category: "Income", amount: dTotalIncome));
      }
      else {
        Total.add(PieChartData(category: "Expense", amount: 0.0));
        Total.add(PieChartData(category: "Income", amount: 0.0));
      }
  }

  //Yesterday
  Future<void> getYesterdayExpensePieChartCategory() async {
    DateTime date = DateTime.now().subtract(Duration(days: 1));
    e_temp.clear();
    ExpensePieCharts.clear();
    final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
        .doc(date.year.toString())
        .collection('months')
        .doc(date.month.toString())
        .collection('days')
        .doc(date.day.toString());
    QuerySnapshot categorySnapshot = await daysCollection.collection("expenseCategory").get();
    for (QueryDocumentSnapshot data in categorySnapshot.docs) {
      final categoryData = data.data() as Map<String, dynamic>;
      String title = data.id;
      double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
      if (e_temp.containsKey(title)) {
        e_temp[title] += amount;
      } else {
        e_temp[title] = amount;
      }
    }
  }
  Future<void> getYesterdayIncomePieChartCategory() async {
    DateTime date = DateTime.now().subtract(Duration(days: 1));
    IncomePieCharts.clear();
    i_temp.clear();
    final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
        .doc(date.year.toString())
        .collection('months')
        .doc(date.month.toString())
        .collection('days')
        .doc(date.day.toString());
    QuerySnapshot categorySnapshot = await daysCollection.collection("incomeCategory").get();
    for (QueryDocumentSnapshot data in categorySnapshot.docs) {
      final categoryData = data.data() as Map<String, dynamic>;
      String title = data.id;
      print("$title");
      double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
      if (i_temp.containsKey(title)) {
        i_temp[title] += amount;
      } else {
        i_temp[title] = amount;
      }
    }
  }
  Future<void> getYesterdayTotalExpenseIncome() async {
    Total.clear();
    DateTime date = DateTime.now().subtract(Duration(days: 1));
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
      Total.add(PieChartData(category: "Expense", amount: dTotalExpense));
      Total.add(PieChartData(category: "Income", amount: dTotalIncome));
      print(Total.toString());
    }
    else {
      Total.add(PieChartData(category: "Expense", amount: 0.0));
      Total.add(PieChartData(category: "Income", amount: 0.0));
    }
  }

  //Last 7 days
  Future<void> getLastSevenDaysExpensePieChartCategory() async {
    e_temp.clear();
    _DateRange.clear();
    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(Duration(days: 6));
    _DateRange.clear();
    if (startDate.month != now.month) {
      int daysInMonth = DateTime(startDate.year, startDate.month + 1, 0).day;
      for (int i = startDate.day; i <= daysInMonth; i++) {
        _DateRange.add(DateTime(startDate.year, startDate.month, i));
      }
      for (int i = 1; i <= now.day; i++) {
        _DateRange.add(DateTime(now.year, now.month, i));
      }
    }
    else {
      for (int i = startDate.day; i <= now.day; i++) {
        _DateRange.add(DateTime(now.year, now.month, i));
      }
    }
    for (DateTime date in _DateRange) {
      final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid)
          .collection('analysis').doc(date.year.toString())
          .collection('months').doc(date.month.toString())
          .collection('days').doc(date.day.toString());
      QuerySnapshot categorySnapshot = await daysCollection.collection("expenseCategory").get();
      for (QueryDocumentSnapshot data in categorySnapshot.docs) {
        final categoryData = data.data() as Map<String, dynamic>;
        String title = data.id;
        double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
        if (e_temp.containsKey(title)) {
          e_temp[title] += amount;
        } else {
          e_temp[title] = amount;
        }
      }
    }
  }
  Future<void> getLastSevenDaysIncomePieChartCategory() async {
    i_temp.clear();
    _DateRange.clear();
    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(Duration(days: 6));
    _DateRange.clear();
    if (startDate.month != now.month) {
      int daysInMonth = DateTime(startDate.year, startDate.month + 1, 0).day;
      for (int i = startDate.day; i <= daysInMonth; i++) {
        _DateRange.add(DateTime(startDate.year, startDate.month, i));
      }
      for (int i = 1; i <= now.day; i++) {
        _DateRange.add(DateTime(now.year, now.month, i));
      }
    }
    else {
      for (int i = startDate.day; i <= now.day; i++) {
        _DateRange.add(DateTime(now.year, now.month, i));
      }
    }
    for (DateTime date in _DateRange) {
      final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid)
          .collection('analysis').doc(date.year.toString())
          .collection('months').doc(date.month.toString())
          .collection('days').doc(date.day.toString());
      QuerySnapshot categorySnapshot = await daysCollection.collection("incomeCategory").get();
      for (QueryDocumentSnapshot data in categorySnapshot.docs) {
        final categoryData = data.data() as Map<String, dynamic>;
        String title = data.id;
        double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
        if (i_temp.containsKey(title)) {
          i_temp[title] += amount;
        } else {
          i_temp[title] = amount;
        }
      }
    }
  }
  Future<void> getLastSevenDaysTotalExpenseIncome() async {
    Total.clear();
    _DateRange.clear();
    DateTime now = DateTime.now();
    DateTime startDate = now.subtract(Duration(days: 6));
    if (startDate.month != now.month) {
      int daysInMonth = DateTime(startDate.year, startDate.month + 1, 0).day;
      for (int i = startDate.day; i <= daysInMonth; i++) {
        _DateRange.add(DateTime(startDate.year, startDate.month, i));
      }
      for (int i = 1; i <= now.day; i++) {
        _DateRange.add(DateTime(now.year, now.month, i));
      }
    }
    else {
      for (int i = startDate.day; i <= now.day; i++) {
        _DateRange.add(DateTime(now.year, now.month, i));
      }
    }
    double _totalIncome = 0.0;
    double _totalExpense = 0.0;
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
        _totalExpense += dTotalExpense;
        _totalIncome += dTotalIncome;
      }
    }
    Total.add(PieChartData(category: "Expense", amount: _totalExpense));
    Total.add(PieChartData(category: "Income", amount: _totalIncome));
  }

  //This Month
  Future<void> getThisMonthExpensePieChartCategory() async {
    e_temp.clear();
    _DateRange.clear();
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, 1); // First day of current month
    _DateRange.clear();
    for (int i = startDate.day; i <= now.day; i++) {
      _DateRange.add(DateTime(now.year, now.month, i));
    }
    for (DateTime date in _DateRange) {
      final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid)
          .collection('analysis').doc(date.year.toString())
          .collection('months').doc(date.month.toString())
          .collection('days').doc(date.day.toString());
      QuerySnapshot categorySnapshot = await daysCollection.collection("expenseCategory").get();
      if( categorySnapshot.docs.isNotEmpty){
        for (QueryDocumentSnapshot data in categorySnapshot.docs) {
        final categoryData = data.data() as Map<String, dynamic>;
        String title = data.id;
        double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
        if (e_temp.containsKey(title)) {
          e_temp[title] += amount;
        } else {
          e_temp[title] = amount;
        }
      }
      }
    }
  }
  Future<void> getThisMonthsIncomePieChartCategory() async {
    i_temp.clear();
    _DateRange.clear();
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, 1); // First day of current month
    _DateRange.clear();
    for (int i = startDate.day; i <= now.day; i++) {
      _DateRange.add(DateTime(now.year, now.month, i));
    }
    for (DateTime date in _DateRange) {
      final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid)
          .collection('analysis').doc(date.year.toString())
          .collection('months').doc(date.month.toString())
          .collection('days').doc(date.day.toString());
      QuerySnapshot categorySnapshot = await daysCollection.collection("incomeCategory").get();
      if( categorySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot data in categorySnapshot.docs) {
          final categoryData = data.data() as Map<String, dynamic>;
          String title = data.id;
          double amount = double.parse(decryptData(
              categoryData[title].toString(), cValue.currentUser.value.key));
          if (i_temp.containsKey(title)) {
            i_temp[title] += amount;
          } else {
            i_temp[title] = amount;
          }
        }
      }
    }
  }
  Future<void> getThisMonthTotalExpenseIncome() async {
    Total.clear();
    _DateRange.clear();
    DateTime date = DateTime.now();
    double _totalIncome = 0.0;
    double _totalExpense = 0.0;
    DocumentSnapshot monthSnapshot = await FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid)
          .collection('analysis').doc(date.year.toString())
          .collection('months').doc(date.month.toString())
          .get();
      if (monthSnapshot.exists) {
        final monthData = monthSnapshot.data() as Map<String, dynamic>;
        double mTotalExpense = double.parse(decryptData(monthData['mTotalExpense'].toString(),cValue.currentUser.value.key));
        double mTotalIncome = double.parse(decryptData(monthData['mTotalIncome'].toString(),cValue.currentUser.value.key));
        _totalExpense += mTotalExpense;
        _totalIncome += mTotalIncome;
      }
    Total.add(PieChartData(category: "Expense", amount: _totalExpense));
    Total.add(PieChartData(category: "Income", amount: _totalIncome));
  }

  //Last Month
  Future<void> getLastMonthExpensePieChartCategory() async {
    e_temp.clear();
    _DateRange.clear();
    DateTime now = DateTime.now();
    DateTime lastMonth = DateTime(now.year, now.month - 1, 1);
    int lastMonthDays = DateTime(lastMonth.year, lastMonth.month + 1, 0).day;
    for (int i = 1; i <= lastMonthDays; i++) {
      final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
          .doc(lastMonth.year.toString())
          .collection('months')
          .doc(lastMonth.month.toString())
          .collection('days')
          .doc(i.toString());
      QuerySnapshot categorySnapshot = await daysCollection.collection("expenseCategory").get();
      for (QueryDocumentSnapshot data in categorySnapshot.docs) {
        final categoryData = data.data() as Map<String, dynamic>;
        String title = data.id;
        double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
        if (e_temp.containsKey(title)) {
          e_temp[title] += amount;
        } else {
          e_temp[title] = amount;
        }
      }
    }
  }
  Future<void> getLastMonthIncomePieChartCategory() async {
    i_temp.clear();
    _DateRange.clear();
    DateTime now = DateTime.now();
    DateTime lastMonth = DateTime(now.year, now.month - 1, 1);
    int lastMonthDays = DateTime(lastMonth.year, lastMonth.month + 1, 0).day;

    for (int i = 1; i <= lastMonthDays; i++) {
      final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
          .doc(lastMonth.year.toString())
          .collection('months')
          .doc(lastMonth.month.toString())
          .collection('days')
          .doc(i.toString());
      QuerySnapshot categorySnapshot = await daysCollection.collection("incomeCategory").get();
      for (QueryDocumentSnapshot data in categorySnapshot.docs) {
        final categoryData = data.data() as Map<String, dynamic>;
        String title = data.id;
        double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
        if (i_temp.containsKey(title)) {
          i_temp[title] += amount;
        } else {
          i_temp[title] = amount;
        }
      }
    }
  }
  Future<void> getLastMonthTotalExpenseIncome() async {
    DateTime now = DateTime.now();
    DateTime lastMonth = DateTime(now.year, now.month - 1, 1);
    double _totalIncome = 0.0;
    double _totalExpense = 0.0;
      DocumentSnapshot daySnapshot = await FirebaseFirestore.instance.collection('users')
          .doc(cValue.currentUser.value.uid)
          .collection('analysis').doc(lastMonth.year.toString())
          .collection('months').doc(lastMonth.month.toString())
          .get();
      if (daySnapshot.exists) {
        final dayData = daySnapshot.data() as Map<String, dynamic>;
        double mTotalExpense = double.parse(decryptData(dayData['mTotalExpense'].toString(),cValue.currentUser.value.key));
        double mTotalIncome = double.parse(decryptData(dayData['mTotalIncome'].toString(),cValue.currentUser.value.key));
        _totalExpense += mTotalExpense;
        _totalIncome += mTotalIncome;
      }
    Total.clear();
    Total.add(PieChartData(category: "Expense", amount: _totalExpense));
    Total.add(PieChartData(category: "Income", amount: _totalIncome));
  }

  //This Year
  Future<void> getThisYearExpensePieChartCategory() async {
    e_temp.clear();
    DateTime today = DateTime.now();
    for (int i = 0; i < today.month; i++) {
      DateTime date = DateTime(today.year, i + 1, 1);
      final daysCollection = FirebaseFirestore.instance.collection('users')
          .doc(cValue.currentUser.value.uid)
          .collection('analysis')
          .doc(date.year.toString())
          .collection('months')
          .doc(date.month.toString());
      QuerySnapshot daysSnapshot = await daysCollection.collection('days').get();
      for (QueryDocumentSnapshot day in daysSnapshot.docs) {
        QuerySnapshot categorySnapshot = await day.reference.collection("expenseCategory").get();
        for (QueryDocumentSnapshot data in categorySnapshot.docs) {
          final categoryData = data.data() as Map<String, dynamic>;
          String title = data.id;
          double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
          if (e_temp.containsKey(title)) {
            e_temp[title] += amount;
          } else {
            e_temp[title] = amount;
          }
        }
      }
    }
  }
  Future<void> getThisYearIncomePieChartCategory() async {
    i_temp.clear();
    DateTime today = DateTime.now();
    for (int i = 0; i < today.month; i++) {
      DateTime date = DateTime(today.year, i + 1, 1);
      final daysCollection = FirebaseFirestore.instance.collection('users')
          .doc(cValue.currentUser.value.uid)
          .collection('analysis')
          .doc(date.year.toString())
          .collection('months')
          .doc(date.month.toString());
      QuerySnapshot daysSnapshot = await daysCollection.collection('days').get();
      for (QueryDocumentSnapshot day in daysSnapshot.docs) {
        QuerySnapshot categorySnapshot = await day.reference.collection("incomeCategory").get();
        for (QueryDocumentSnapshot data in categorySnapshot.docs) {
          final categoryData = data.data() as Map<String, dynamic>;
          String title = data.id;
          double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
          if (i_temp.containsKey(title)) {
            i_temp[title] += amount;
          } else {
            i_temp[title] = amount;
          }
        }
      }
    }
  }
  Future<void> getThisYearTotalExpenseIncome() async {
    Total.clear();
    double _totalIncome = 0.0;
    double _totalExpense = 0.0;
    DateTime today = DateTime.now();
    for (int i = 0; i < today.month; i++) {
      DateTime date = DateTime(today.year, i + 1, 1);
      final daysCollection = FirebaseFirestore.instance.collection('users')
          .doc(cValue.currentUser.value.uid)
          .collection('analysis')
          .doc(date.year.toString())
          .collection('months');
      final daysSnapshot = await daysCollection.doc(date.month.toString()).get();
        if (daysSnapshot.exists) {
          final monthData = daysSnapshot.data() as Map<String, dynamic>;
          double mTotalExpense = double.parse(decryptData(monthData['mTotalExpense'].toString(),cValue.currentUser.value.key));
          double mTotalIncome = double.parse(decryptData(monthData['mTotalIncome'].toString(),cValue.currentUser.value.key));
          _totalExpense += mTotalExpense;
          _totalIncome += mTotalIncome;
      }
    }
    Total.add(PieChartData(category: "Expense", amount: _totalExpense));
    Total.add(PieChartData(category: "Income", amount: _totalIncome));
  }

  //Last Year
  Future<void> getLastYearExpensePieChartCategory() async {
    e_temp.clear();
    DateTime today = DateTime.now();
    for (int i = 1; i <= 12; i++) {
      DateTime date = DateTime(today.year - 1, i, 1);
      final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
          .doc(date.year.toString())
          .collection('months')
          .doc(date.month.toString());
      QuerySnapshot daysSnapshot = await daysCollection.collection('days').get();
      for (QueryDocumentSnapshot day in daysSnapshot.docs) {
        QuerySnapshot categorySnapshot = await day.reference.collection("expenseCategory").get();
        for (QueryDocumentSnapshot data in categorySnapshot.docs) {
          final categoryData = data.data() as Map<String, dynamic>;
          String title = data.id;
          double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
          if (e_temp.containsKey(title)) {
            e_temp[title] += amount;
          } else {
            e_temp[title] = amount;
          }
        }
      }
    }
  }
  Future<void> getLastYearIncomePieChartCategory() async {
    i_temp.clear();
    DateTime today = DateTime.now();
    for (int i = 1; i <= 12; i++) {
      DateTime date = DateTime(today.year -1 , i, 1);
      final daysCollection = FirebaseFirestore.instance.collection('users').doc(cValue.currentUser.value.uid).collection('analysis')
          .doc(date.year.toString())
          .collection('months')
          .doc(date.month.toString());
      QuerySnapshot daysSnapshot = await daysCollection.collection('days').get();
      for (QueryDocumentSnapshot day in daysSnapshot.docs) {
        QuerySnapshot categorySnapshot = await day.reference.collection("incomeCategory").get();
        for (QueryDocumentSnapshot data in categorySnapshot.docs) {
          final categoryData = data.data() as Map<String, dynamic>;
          String title = data.id;
          double amount = double.parse(decryptData(categoryData[title].toString(), cValue.currentUser.value.key));
          if (i_temp.containsKey(title)) {
            i_temp[title] += amount;
          } else {
            i_temp[title] = amount;
          }
        }
      }
    }
  }
  Future<void> getLastYearTotalExpenseIncome() async {
    Total.clear();
    double _totalIncome = 0.0;
    double _totalExpense = 0.0;
    DateTime today = DateTime.now();
    for (int i = 1; i <= 12; i++) {
      DateTime date = DateTime(today.year-1, i, 1);
      final daysCollection = FirebaseFirestore.instance.collection('users')
          .doc(cValue.currentUser.value.uid)
          .collection('analysis')
          .doc(date.year.toString())
          .collection('months');
      final daysSnapshot = await daysCollection.doc(date.month.toString()).get();
      if (daysSnapshot.exists) {
        final monthData = daysSnapshot.data() as Map<String, dynamic>;
        double mTotalExpense = double.parse(decryptData(monthData['mTotalExpense'].toString(),cValue.currentUser.value.key));
        double mTotalIncome = double.parse(decryptData(monthData['mTotalIncome'].toString(),cValue.currentUser.value.key));
        _totalExpense += mTotalExpense;
        _totalIncome += mTotalIncome;
      }
    }
    Total.add(PieChartData(category: "Expense", amount: _totalExpense));
    Total.add(PieChartData(category: "Income", amount: _totalIncome));
  }

  @override
  void initState() {
    super.initState();
    i_temp.clear();
    e_temp.clear();
    _DateRange.clear();
    IncomePieCharts.clear();
    ExpensePieCharts.clear();
    startingDateContoller.text = DateFormat('dd/MM/yyyy').format(_startDate).toString();
    endingDateContoller.text = DateFormat('dd/MM/yyyy').format(_endDate).toString();
    Total.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            if(widget.pageType == "Custom")
              ...[Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(child: Divider(thickness: 1.0)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    "Date Range For Data",
                                    style: TextStyle(
                                        wordSpacing: 2,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18),
                                  ),
                                ),
                                Expanded(child: Divider(thickness: 1.0)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          controller: startingDateContoller,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Starting Date',
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              size: 20,
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                          readOnly: true,
                          onChanged: (value) {
                            getCustomExpensePieChartCategory(_startDate,_endDate);
                          },
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime(2015),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _startDate = picked;
                                startingDateContoller.text =
                                    DateFormat('dd/MM/yyyy')
                                        .format(_startDate)
                                        .toString();
                              });
                            }
                          },
                        ),
                        SizedBox(height: 16,),
                        TextFormField(
                          controller: endingDateContoller,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Ending Date',
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              size: 20,
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                          readOnly: true,
                          onChanged: (value) {
                            getCustomExpensePieChartCategory(_startDate,_endDate);
                          },
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
                              firstDate: DateTime(2015),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              if (picked.isBefore(_startDate)) {
                                showTopTitleSnackBar(context, Icons.calendar_month_outlined, "Ending date can't before starting date");
                                setState((){
                                  _endDate = DateTime.now();
                                  endingDateContoller.text = DateFormat('dd/MM/yyyy').format(_endDate).toString();
                                });
                              } else {
                                setState(() {
                                  _endDate = picked;
                                  endingDateContoller.text = DateFormat('dd/MM/yyyy').format(_endDate).toString();
                                });
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),],

            //Total Income & Expense
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(child: Divider(thickness: 1.0)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  "Total Income & Expense",
                                  style: TextStyle(
                                      wordSpacing: 2,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                ),
                              ),
                              Expanded(child: Divider(thickness: 1.0)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 210,
                  margin: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: FutureBuilder(
                    future:widget.pageType == "Custom"
                        ? getCustomTotalExpenseIncome(_startDate, _endDate)
                        : widget.pageType == "Today"
                        ? getTodayTotalExpenseIncome()
                        : widget.pageType == "Yesterday"
                        ? getYesterdayTotalExpenseIncome()
                        : widget.pageType == "Last 7 Days"
                        ? getLastSevenDaysTotalExpenseIncome()
                        : widget.pageType == "This Month"
                        ? getThisMonthTotalExpenseIncome()
                        : widget.pageType == "Last Month"
                        ? getLastMonthTotalExpenseIncome()
                        : widget.pageType == "This Year"
                        ? getThisYearTotalExpenseIncome()
                        : getLastYearTotalExpenseIncome(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                    }
                    else if (snapshot.hasError) {
                    return Center(child: Text('Loading data take time...'));
                    }
                    else {
                      return Total.isEmpty || (Total[0].amount == 0 && Total[1].amount == 0) ? Center(child: Text("Data Not Found!")) : Container(
                            child: SfCircularChart(
                          legend: Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                            overflowMode: LegendItemOverflowMode.scroll,
                            textStyle: TextStyle(fontSize: 12),
                            iconWidth: 12,
                            iconHeight: 12,
                          ),
                          series: <CircularSeries>[
                            DoughnutSeries<PieChartData, String>(
                              dataSource: Total,
                              xValueMapper: (PieChartData data, _) =>
                              data.category,
                              yValueMapper: (PieChartData data, _) =>
                              data.amount,
                              dataLabelSettings: DataLabelSettings(
                                  isVisible: true,
                                  labelPosition: ChartDataLabelPosition.outside,
                                  overflowMode: OverflowMode.shift),
                              pointColorMapper: (PieChartData data, _) =>
                              data.category == "Income" ? Colors.green : Colors
                                  .red,
                            ),
                          ],
                        ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            //Expense
            Column(
              children: [
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(child: Divider(thickness: 1.0)),
                            Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 8.0),
                              child:Text("Expense In Detail", style: TextStyle(wordSpacing: 2, fontWeight: FontWeight.w500, fontSize: 22),),
                            ),
                            Expanded(child: Divider(thickness: 1.0)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    height: 400,
                    child: Container(
                      margin: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FutureBuilder(
                        future: widget.pageType == "Custom"
                            ? getCustomExpensePieChartCategory(_startDate, _endDate)
                            : widget.pageType == "Today"
                            ? getTodayExpensePieChartCategory()
                            : widget.pageType == "Yesterday"
                            ? getYesterdayExpensePieChartCategory()
                            : widget.pageType == "Last 7 Days"
                            ? getLastSevenDaysExpensePieChartCategory()
                            : widget.pageType == "This Month"
                            ? getThisMonthExpensePieChartCategory()
                            : widget.pageType == "Last Month"
                            ? getLastMonthExpensePieChartCategory()
                            : widget.pageType == "This Year"
                            ? getThisYearExpensePieChartCategory()
                            : getLastYearExpensePieChartCategory(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          else if (snapshot.hasError) {
                            return Center(child: Text('Loading data take time...'));
                          }
                          else {
                            ExpensePieCharts.clear();
                            e_temp.forEach((title, amount) {
                              if( amount > 0){
                                ExpensePieCharts.add(ExpensePieChart(title, amount));
                              }
                            });
                            return ExpensePieCharts.isEmpty ? Center(child: Text("Data Not Found!"))
                                : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Text("${DateFormat("dd/MM/yyyy").format(DateTime.now())}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 2),),
                                      IconButton(icon: Icon(Icons.zoom_in_map, color: Colors.black,),
                                        onPressed: () => {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailPieChart("Expense",e_temp)))
                                        },
                                      ),
                                    ],),
                                ),
                                Container(
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
                                      PieSeries<ExpensePieChart, String>(
                                        dataSource: ExpensePieCharts,
                                        xValueMapper: (ExpensePieChart ExpensePieChart, _) => ExpensePieChart.category,
                                        yValueMapper: (ExpensePieChart ExpensePieChart, _) => ExpensePieChart.amount,
                                        pointColorMapper: (ExpensePieChart ExpensePieChart, _) =>
                                        Colors.accents[ExpensePieCharts.indexOf(ExpensePieChart) % 10],
                                        explode: true,
                                        explodeIndex: 0,
                                        animationDuration: 300,
                                        dataLabelSettings: DataLabelSettings(
                                          overflowMode: OverflowMode.shift,
                                          isVisible: true,
                                          labelPosition: ChartDataLabelPosition.outside,
                                        ),
                                        onPointDoubleTap: (ChartPointDetails args) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(ExpensePieCharts[int.parse(args.pointIndex.toString())].category),
                                                content: Text('Amount: Rs. ${ExpensePieCharts[int.parse(args.pointIndex.toString())].amount}'),
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
                              ],
                            );
                          }
                        },
                      ),
                    )
                ),
              ],
            ),

            //Income
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(child: Divider(thickness: 1.0)),
                              Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 8.0),
                                child:Text("Income In Detail", style: TextStyle(wordSpacing: 2, fontWeight: FontWeight.w500, fontSize: 22),),
                              ),
                              Expanded(child: Divider(thickness: 1.0)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    height: 400,
                    child: Container(
                      margin: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FutureBuilder(
                        future: widget.pageType == "Custom"
                            ? getCustomIncomePieChartCategory(_startDate, _endDate)
                            : widget.pageType == "Today"
                            ? getTodayIncomePieChartCategory()
                            : widget.pageType == "Yesterday"
                            ? getYesterdayIncomePieChartCategory()
                            : widget.pageType == "Last 7 Days"
                            ? getLastSevenDaysIncomePieChartCategory()
                            : widget.pageType == "This Month"
                            ? getThisMonthsIncomePieChartCategory()
                            : widget.pageType == "Last Month"
                            ? getLastMonthIncomePieChartCategory()
                            : widget.pageType == "This Year"
                            ? getThisYearIncomePieChartCategory()
                            : getLastYearIncomePieChartCategory(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          else if (snapshot.hasError) {
                            return Center(child: Text('Loading data take time...'));
                          }
                          else {
                            IncomePieCharts.clear();
                            i_temp.forEach((title, amount) {
                              if( amount > 0){
                                IncomePieCharts.add(IncomePieChart(title, amount));
                              }
                            });
                            return IncomePieCharts.isEmpty ? Center(child: Text("Data Not Found!")) : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Text("${DateFormat("dd/MM/yyyy").format(DateTime.now())}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 2),),
                                      IconButton(icon: Icon(Icons.zoom_in_map, color: Colors.black,),
                                        onPressed: () => {
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailPieChart("Income",i_temp)))
                                        },
                                      ),
                                    ],),
                                ),
                                Container(
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
                                      PieSeries<IncomePieChart, String>(
                                        dataSource: IncomePieCharts,
                                        xValueMapper: (IncomePieChart ExpensePieChart, _) => ExpensePieChart.category,
                                        yValueMapper: (IncomePieChart ExpensePieChart, _) => ExpensePieChart.amount,
                                        pointColorMapper: (IncomePieChart ExpensePieChart, _) =>
                                        Colors.accents[IncomePieCharts.indexOf(ExpensePieChart) % 10],
                                        explode: true,
                                        explodeIndex: 0,
                                        animationDuration: 300,
                                        dataLabelSettings: DataLabelSettings(
                                          overflowMode: OverflowMode.shift,
                                          isVisible: true,
                                          labelPosition: ChartDataLabelPosition.outside,
                                        ),
                                        onPointDoubleTap: (ChartPointDetails args) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(IncomePieCharts[int.parse(args.pointIndex.toString())].category),
                                                content: Text('Amount: Rs. ${IncomePieCharts[int.parse(args.pointIndex.toString())].amount}'),
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


                                // Container(
                                //   height: 260,
                                //   child: SfCartesianChart(
                                //     legend: Legend(
                                //       isVisible: true,
                                //       position: LegendPosition.bottom,
                                //     ),
                                //     tooltipBehavior: TooltipBehavior(
                                //       enable: true,
                                //       format: 'point.x : point.y',
                                //     ),
                                //     series: <CircularSeries>[
                                //       PieSeries<IncomePieChart, String>(
                                //         dataSource: IncomePieCharts,
                                //         xValueMapper: (IncomePieChart IncomePieChart, _) => IncomePieChart.category,
                                //         yValueMapper: (IncomePieChart IncomePieChart, _) => IncomePieChart.amount,
                                //         pointColorMapper: (IncomePieChart IncomePieChart, _) =>
                                //         Colors.accents[IncomePieCharts.indexOf(IncomePieChart) % 10],
                                //         explode: true,
                                //         explodeIndex: 0,
                                //         animationDuration: 300,
                                //       )
                                //     ],
                                //   ),
                                // ),
                                // Expanded(
                                //   child: ListView.builder(
                                //     itemCount: IncomePieCharts.length,
                                //     itemBuilder: (context, index) {
                                //       return ListTile(
                                //         leading: CircleAvatar(
                                //           backgroundColor: Colors.accents[index % 10],
                                //         ),
                                //         title: Text(IncomePieCharts[index].category),
                                //         trailing: Text('₹ ${IncomePieCharts[index].amount.toStringAsFixed(2)}'),
                                //       );
                                //     },
                                //   ),
                                // ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}

class PieChartData {
  final String category;
  final double amount;
  PieChartData({required this.category, required this.amount});
}

class IncomePieChart {
  final String category;
  final double amount;
  IncomePieChart(this.category, this.amount);
}

class ExpensePieChart {
  final String category;
  final double amount;
  ExpensePieChart(this.category, this.amount);
}