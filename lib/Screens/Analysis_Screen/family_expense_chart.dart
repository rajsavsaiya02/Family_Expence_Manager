import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/familyGroupKey.dart';
import 'package:fem/Screens/Analysis_Screen/detail_pie_chart.dart';
import 'package:fem/Utility/Colors.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FamilyAnalysisScreen extends StatefulWidget {
  const FamilyAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<FamilyAnalysisScreen> createState() => _FamilyAnalysisScreenState();
}

class FamilyExpenseAnalysisData {
  final double amount;
  final String category;

  FamilyExpenseAnalysisData({required this.category, required this.amount});

  factory FamilyExpenseAnalysisData.fromDocument(DocumentSnapshot doc) {
    final FamilyGroupKey gValue = Get.put(FamilyGroupKey());
    final data = doc.data() as Map<String, dynamic>;
    return FamilyExpenseAnalysisData(
      category: decryptData(data['category'], gValue.familyKey.value.key),
      amount: double.parse(
          decryptData(data['amount'].toString(), gValue.familyKey.value.key)),
    );
  }
}

class _FamilyAnalysisScreenState extends State<FamilyAnalysisScreen> {
  List<Expense> datalist = [];
  Map<String, dynamic> e_temp = {};
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
  DateTime _endDate = DateTime.now();
  final FamilyGroupKey gValue = Get.put(FamilyGroupKey());
  final TextEditingController startingDateContoller = TextEditingController();
  final TextEditingController endingDateContoller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCustomExpensePieChartCategory(_startDate, _endDate);
    startingDateContoller.text = DateFormat('dd/MM/yyyy').format(_startDate).toString();
    endingDateContoller.text = DateFormat('dd/MM/yyyy').format(_endDate).toString();
  }

  Future<void> getCustomExpensePieChartCategory(
      DateTime startDate, DateTime endDate) async {
    e_temp.clear();
    final querySnapshot = await FirebaseFirestore.instance
        .collection("family")
        .doc(gValue.familyKey.value.fid)
        .collection('transactions')
        .where('date_time', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date_time', isLessThanOrEqualTo: endDate.toIso8601String())
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final data = await querySnapshot.docs
          .map((doc) => FamilyExpenseAnalysisData.fromDocument(doc))
          .toList();
      for (var value in data) {
        String title = value.category;
        double amount = value.amount;
        if (e_temp.containsKey(title)) {
          e_temp[title] += amount;
        } else {
          e_temp[title] = amount;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Analysis'),
          centerTitle: true,
          backgroundColor: primary,
          elevation: 5,
        ),
        body: Column(
          children: [
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
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
                      SizedBox(
                        height: 16,
                      ),
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
                              showTopTitleSnackBar(
                                  context,
                                  Icons.calendar_month_outlined,
                                  "Ending date can't before starting date");
                              setState(() {
                                _endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
                                endingDateContoller.text =
                                    DateFormat('dd/MM/yyyy')
                                        .format(_endDate)
                                        .toString();
                              });
                            } else {
                              setState(() {
                                _endDate = picked;
                                endingDateContoller.text =
                                    DateFormat('dd/MM/yyyy')
                                        .format(_endDate)
                                        .toString();
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                              "Expense Chart In Detail",
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
            SizedBox(
              height: 8,
            ),
            FutureBuilder(
                  future: getCustomExpensePieChartCategory(_startDate, _endDate),
                  builder: (BuildContext context, AsyncSnapshot snapshot){
                    datalist.clear();
                    if (e_temp.isNotEmpty) {
    e_temp.forEach((title, amount) {
    if (amount > 0) {
    datalist.add(Expense(title, amount));
    }
    });
    }
                     return datalist.isEmpty
                      ? Center(child: Text("Data Not Found!"))
                          :Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Text("${DateFormat("dd/MM/yyyy").format(DateTime.now())}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 2),),
                                IconButton(
                                  icon: Icon(
                                    Icons.zoom_in_map,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) =>
                                            DetailPieChart("Expense", e_temp)))
                                  },
                                ),
                              ],
                            ),
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
                                PieSeries<Expense, String>(
                                  dataSource: datalist,
                                  xValueMapper: (Expense Expense, _) => Expense.category,
                                  yValueMapper: (Expense Expense, _) => Expense.amount,
                                  pointColorMapper: (Expense Expense, _) =>
                                  Colors.accents[datalist.indexOf(Expense) % 10],
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
                        ],
                      );
                  }
                ),
          ],
        ));
  }
}
