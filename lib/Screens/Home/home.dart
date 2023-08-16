import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Components/Drawer/app_drawer.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/Credentials/familyGroupKey.dart';
import 'package:fem/Database/Credentials/familyGroupKeyModel.dart';
import 'package:fem/Database/FireStore_Database/Family_Profile/family_profile_manage.dart';
import 'package:fem/Database/FireStore_Database/User_Analysis/analysis_datamodel.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Screens/Family_Group_Screen/family_group_room.dart';
import 'package:fem/Screens/Transaction_View/transcation_view_screen.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../Utility/Colors.dart';
import '../Analysis_Screen/analysis_screen.dart';
import '../Data_Input_Screen/combain_input_screen.dart';
import '../Family_Group_Screen/default_family_group_screen.dart';
import '../Tools_Screen/tools_screen.dart';
import 'transaction_view_of_week.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final cValue = Get.put(commanValue());
  final gValue = Get.put(FamilyGroupKey());
  final UserController controller = Get.put(UserController());
  final GroupController groupController = Get.put(GroupController());
  final aController = Get.put(analysisController());
  RxList<RecentTransaction> _TransactionList = <RecentTransaction>[].obs;

  @override
  void initState() {
    _load();
    super.initState();
  }

  Future<void> _load() async {
    cValue.loadFromStorage();
    controller.getUserData();
    aController.getCurrentIncomeExpense();
  }


  Future<void> _loadDataFromFirestore() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cValue.currentUser.value.uid)
        .collection("transactions")
        .orderBy('date_time', descending: true)
        .limit(10)
        .get()
        .then((querySnapshot) {
      List<RecentTransaction> TransactionList = [];
      querySnapshot.docs.forEach((documentSnapshot) {
        RecentTransaction data =
            RecentTransaction.fromFirestore(documentSnapshot);
        TransactionList.add(data);
      });
      _TransactionList.assignAll(TransactionList);
    }).catchError((error) {
      print(error);
    });
  }

  RxList<RecentTransaction> get transactionList => _TransactionList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TransactionInput()));
        },
        child: Icon(
          Icons.add,
          size: 35,
        ),
        backgroundColor: Colors.amber,
        splashColor: Colors.white54,
        foregroundColor: Colors.white,
        clipBehavior: Clip.hardEdge,
        elevation: 2,
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Home"),
        backgroundColor: primary,
        elevation: 5,
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: DrawerScreen(),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    //current view
                    Container(
                      child: Column(
                        children: [
                          Container(
                              width: ScreenWidth(context) / 1.1,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade400,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: Offset(5, 5),
                                    blurRadius: 5,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Current Balance",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(
                                      width: ScreenWidth(context) / 2.2,
                                      child: Obx(() => Text(
                                            '${controller.currentBalance.value.toStringAsFixed(2)}',
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 23,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          //expense
                          Container(
                              width: ScreenWidth(context) / 1.1,
                              height: 125,
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: Offset(5, 5),
                                    blurRadius: 5,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0, vertical: 5.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0,
                                              bottom: 4.0,
                                              left: 10.0,
                                              right: 0.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Expenses",
                                              style: TextStyle(
                                                letterSpacing: 1,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 21,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Obx(() => Padding(padding: const EdgeInsets.all(8.0),
                                              child: aController.currentExpensePR.value == 0.0
                                                  ? Text("")
                                                  : aController.currentExpensePR.value < 0
                                                      ? Transform.rotate(angle: -math.pi * -0.5, child: Icon(
                                                            Icons.double_arrow,
                                                            color: Colors.white,
                                                            size: 25,
                                                          ),)
                                                      : Transform.rotate(angle: -math.pi / 2.0, child: Icon(
                                                            Icons.double_arrow,
                                                            color: Colors.white,
                                                            size: 25,
                                                          ),),
                                            ),),
                                            SizedBox(
                                              child: Obx(() => Text(
                                                    '${aController.currentExpensePR.value.toDouble().abs().toStringAsFixed(2)}%',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 23,
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 5,
                                      thickness: 2,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.white,
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0,
                                                  right: 8,
                                                  top: 0,
                                                  bottom: 0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Yesterday Expenses',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 14,
                                                      )),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        ScreenWidth(context) /
                                                            2.5,
                                                    child: Obx(() => Text(
                                                          '₹ ${aController.previousExpense.value.toStringAsFixed(2)}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 23,
                                                          ),
                                                        )),
                                                  ),
                                                ],
                                              )),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Today Expenses',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                )),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              width: ScreenWidth(context) / 2.5,
                                              child: Obx(() => Text(
                                                    '₹ ${aController.currentExpense.value.toStringAsFixed(2)}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 23,
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          //income
                          Container(
                              width: ScreenWidth(context) / 1.1,
                              height: 125,
                              decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: Offset(5, 5),
                                    blurRadius: 5,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0, vertical: 5.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8.0,
                                              bottom: 4.0,
                                              left: 10.0,
                                              right: 0.0),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Incomes",
                                              style: TextStyle(
                                                letterSpacing: 1,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 21,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Obx(() => Padding(padding: const EdgeInsets.all(8.0),
                                              child: aController.currentIncomePR.value == 0.0
                                                  ? Text("")
                                                  : aController.currentIncomePR.value < 0
                                                  ? Transform.rotate(angle: -math.pi * -0.5, child: Icon(
                                                Icons.double_arrow,
                                                color: Colors.white,
                                                size: 25,
                                              ),)
                                                  : Transform.rotate(angle: -math.pi / 2.0, child: Icon(
                                                Icons.double_arrow,
                                                color: Colors.white,
                                                size: 25,
                                              ),),
                                            ),),
                                            SizedBox(
                                              child: Obx(() => Text(
                                                    '${aController.currentIncomePR.value.toDouble().abs().toStringAsFixed(2)}%',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 23,
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 5,
                                      thickness: 2,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.white,
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0,
                                                  right: 8,
                                                  top: 0,
                                                  bottom: 0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('Yesterday Incomes',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 14,
                                                      )),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        ScreenWidth(context) /
                                                            2.5,
                                                    child: Obx(() => Text(
                                                          '₹ ${aController.previousIncome.value.toStringAsFixed(2)}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 23,
                                                          ),
                                                        )),
                                                  ),
                                                ],
                                              )),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Today Incomes',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                )),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              width: ScreenWidth(context) / 2.5,
                                              child: Obx(() => Text(
                                                    '₹ ${aController.currentIncome.value.toStringAsFixed(2)}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 23,
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),

                    // monthly view
                    Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        child: MonthlyView(),
                        // SfCartesianChart(
                        //   primaryXAxis: CategoryAxis(),
                        //   title: ChartTitle(text: 'Monthly Finance View'),
                        //   legend: Legend(
                        //     isVisible: true,
                        //     position: LegendPosition.bottom,
                        //     overflowMode: LegendItemOverflowMode.wrap,
                        //   ),
                        //   series: <ChartSeries>[
                        //     // LineSeries<SalesData, String>(
                        //     //   name: 'Income',
                        //     //   dataSource: <SalesData>[
                        //     //     SalesData('Jan', 5000),
                        //     //     SalesData('Feb', 7000),
                        //     //     SalesData('Mar', 6000),
                        //     //     SalesData('Apr', 9000),
                        //     //     SalesData('May', 8000),
                        //     //     SalesData('Jun', 11000),
                        //     //   ],
                        //     //   xValueMapper: (SalesData sales, _) =>
                        //     //       sales.month,
                        //     //   yValueMapper: (SalesData sales, _) =>
                        //     //       sales.sales,
                        //     //   color: Colors.green,
                        //     // ),
                        //     LineSeries<mExpense, String>(
                        //       name: 'Expense',
                        //       dataSource: aController.mexpense,
                        //       xValueMapper: (mExpense m, _) => m.month,
                        //       yValueMapper: (mExpense m, _) => m.amount,
                        //       color: Colors.red,
                        //     ),
                        //   ],
                        //   tooltipBehavior: TooltipBehavior(
                        //     enable: true,
                        //     format: 'point.y\$',
                        //   ),
                        // ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),

                    // Last transaction
                    // head
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
                                  child: Text(
                                    'Recent Transactions',
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(thickness: 1.0)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // main
                    SizedBox(height: 25,),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(cValue.currentUser.value.uid)
                          .collection("transactions")
                          .orderBy('date_time', descending: true)
                          .limit(10).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        List<RecentTransaction> dataList = snapshot.data!.docs.map((DocumentSnapshot document)
                        { return RecentTransaction.fromFirestore(document); }).toList();
                        _TransactionList.assignAll(dataList);
                        return Obx(() => ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _TransactionList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final transaction = _TransactionList[index];
                            return _TransactionList.length == 0
                                ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 20.0),
                              child: Center(
                                  child: Text(
                                    "Transaction Not Found!",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  )),
                            )
                                : Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: transaction.type.toString() ==
                                          "expense"
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    child: transaction.method.toString() ==
                                        "Cash"
                                        ? Icon(Bootstrap.cash_stack,
                                        color: Colors.white)
                                        : transaction.method.toString() ==
                                        "Bank"
                                        ? Icon(
                                        Icons
                                            .account_balance_outlined,
                                        color: Colors.white)
                                        : Icon(
                                        Icons.credit_card_outlined,
                                        color: Colors.white),
                                  ),
                                  title: Text(
                                    transaction.title.toString(),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        transaction.category.toString(),
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${double.parse(transaction.amount.toString()).toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "${DateFormat('dd/MM/yy hh:mm').format(transaction.date)}",
                                        style: TextStyle(fontSize: 14),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) => Divider(),
                        ));
                      },
                    ),
                    // return Column(
                    //           children: [
                    //             ListTile(
                    //               leading: Container(
                    //                 width: 50,
                    //                 height: 50,
                    //                 decoration: BoxDecoration(
                    //                   shape: BoxShape.circle,
                    //                   color: decryptData(doc["type"].toString(), cValue.currentUser.value.key) == "expense" ? Colors.red : Colors.green,
                    //                 ),
                    //                 child: decryptData(doc["method"].toString(), cValue.currentUser.value.key) == "Cash"
                    //                     ? Icon(Bootstrap.cash_stack, color: Colors.white)
                    //                     : decryptData(doc["method"].toString(), cValue.currentUser.value.key) == "Bank"
                    //                     ? Icon(Icons.account_balance_outlined, color: Colors.white)
                    //                     : Icon(Icons.credit_card_outlined, color: Colors.white),
                    //               ),
                    //               title: Text(decryptData(doc["title"], cValue.currentUser.value.key),overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                    //               subtitle: Column(
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   SizedBox(height: 10,),
                    //                   Text(decryptData(doc["category"].toString(), cValue.currentUser.value.key), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),overflow: TextOverflow.ellipsis,),
                    //                 ],
                    //               ),
                    //               trailing: Column(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 crossAxisAlignment: CrossAxisAlignment.end,
                    //                 children: [
                    //                   Text('${double.parse(d_amount.toString()).toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    //                   SizedBox(height: 10,),
                    //                   Text("${DateFormat('dd/MM/yy hh:mm').format(DateTime.parse(doc["date_time"]))}",style: TextStyle(fontSize: 14),)
                    //                 ],
                    //               ),
                    //             ),
                    //             Padding(
                    //               padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //               child: SizedBox(height: 10,
                    //               child: Divider(height: 2, thickness: 1,),),
                    //             ),
                    //           ],
                    //         );
                    //   ] else ...[
                    //     Padding(
                    //       padding: const EdgeInsets.all(24.0),
                    //       child: Text('No data available',style: TextStyle(color: Colors.black54,fontSize: 28,fontWeight: FontWeight.w600),),
                    //     )
                    //   ]
                    //   ],
                    // );
                    // Widget hasData()
                    // }
                    // return snapshot.hasData ? hasData() : Padding(
                    //   padding: const EdgeInsets.only(left:16.0, top: 16.0, right:16.0, bottom: 30.0),
                    //   child: Text('No data available',style: TextStyle(color: Colors.black54,fontSize: 28,fontWeight: FontWeight.w600),),
                    // );
                    SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
        color: primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => TransactionsScreen()));
                },
                borderRadius: BorderRadius.circular(100),
                splashColor: Colors.white10,
                highlightColor: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 5.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.list,
                        size: 30,
                        color: Colors.white,
                      ),
                      Text(
                        "Records",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AnalysisScreen()));
                },
                borderRadius: BorderRadius.circular(100),
                splashColor: Colors.white10,
                highlightColor: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0, right: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.chart_1,
                        size: 30,
                        color: Colors.white,
                      ),
                      Text(
                        "Analysis",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 25,
              ),
              InkWell(
                onTap: () {
                  if(controller.familyId.toString() != " "){
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FamilyGroupRoomScreen()));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DefaultFamilyGroup()));
                  }
                },
                borderRadius: BorderRadius.circular(100),
                splashColor: Colors.white10,
                highlightColor: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.family_restroom_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                      Text(
                        "Family",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ToolsBox()));
                },
                borderRadius: BorderRadius.circular(100),
                splashColor: Colors.white10,
                highlightColor: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        BoxIcons.bx_box,
                        size: 30,
                        color: Colors.white,
                      ),
                      Text(
                        "Tools",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentTransaction {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final double amount;
  final String type;
  final String method;
  final String additional;

  RecentTransaction({
    required this.additional,
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.type,
    required this.method,
  });

  factory RecentTransaction.fromFirestore(DocumentSnapshot doc) {
    final cValue = Get.put(commanValue());
    cValue.loadFromStorage();
    final data = doc.data() as Map<String, dynamic>;
    var temp = decryptData(data['additional_info'], cValue.currentUser.value.key);
    return RecentTransaction(
        id: data['uid'],
        title: decryptData(
            data['title'].toString(), cValue.currentUser.value.key),
        category: decryptData(
            data['category'].toString(), cValue.currentUser.value.key),
        date: DateTime.parse(data['date_time'].toString()),
        amount: double.parse(decryptData(
            data['amount'].toString(), cValue.currentUser.value.key)),
        type:
            decryptData(data['type'].toString(), cValue.currentUser.value.key),
        method: decryptData(
            data['method'].toString(), cValue.currentUser.value.key),
        additional: temp == " " ? "" : temp);
  }
}
