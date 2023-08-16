import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/FireStore_Database/User_Transaction/expense_datamodel.dart';
import 'package:fem/Database/FireStore_Database/User_Transaction/income_datamodel.dart';
import 'package:fem/Screens/Data_Input_Screen/edit_expense_transcation_screen.dart';
import 'package:fem/Screens/Data_Input_Screen/edit_income_transcation_screen.dart';
import 'package:fem/Utility/Colors.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Transaction {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final double amount;
  final String type;
  final String method;
  final String additional;

  Transaction({
    required this.additional,
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.type,
    required this.method,
  });

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final commanValue cValue = Get.put(commanValue());
    final data = doc.data() as Map<String, dynamic>;
    var temp = decryptData(data['additional_info'], cValue.currentUser.value.key);
    return Transaction(
        id: data['uid'],
        title: decryptData(data['title'], cValue.currentUser.value.key),
        category: decryptData(data['category'], cValue.currentUser.value.key),
        date: DateTime.parse(data['date_time']),
        amount: double.parse(decryptData(data['amount'].toString(), cValue.currentUser.value.key)),
        type: decryptData(data['type'], cValue.currentUser.value.key),
        method: decryptData(data['method'], cValue.currentUser.value.key),
        additional: temp == " " ? "" : temp
    );
  }
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
DateTime _endDate = DateTime.now();

class _TransactionsScreenState extends State<TransactionsScreen> {
  final commanValue cValue = Get.put(commanValue());
  final UserExpenseController eController = Get.put(UserExpenseController());
  final UserIncomeController iController = Get.put(UserIncomeController());
  var _scrollController = ScrollController();
  final TextEditingController startingDateContoller = TextEditingController();
  final TextEditingController endingDateContoller = TextEditingController();
  final int _limit = 10;
  List<Transaction> _transactions = [];
  List<DocumentSnapshot> _documents = [];
  List<Transaction> _filteredTransactions = [];
  List<Transaction> _tempTransactions = [];
  List<Transaction> _exportData = [];
  bool _loading = false;
  bool _hasMore = true;
  DocumentSnapshot? lastDoc;
  String _searchQuery = '';
  // String _filterBy = "";

  // TextEditingController _searchController = TextEditingController();

  // void _handleSearch(String text) {
  //   setState(() {
  //     _searchText = text;
  //     if (_searchText.isNotEmpty) {
  //       if (_filterBy == "title") {
  //         _filteredTransactions = transactions
  //             .where((transaction) => transaction.title
  //                 .toLowerCase()
  //                 .contains(_searchText.toLowerCase()))
  //             .toList();
  //       } else if (_filterBy == "category") {
  //         _filteredTransactions = transactions
  //             .where((transaction) => transaction.category
  //                 .toLowerCase()
  //                 .contains(_searchText.toLowerCase()))
  //             .toList();
  //       } else if (_filterBy == "date") {
  //         _filteredTransactions = transactions
  //             .where((transaction) => transaction.date
  //                 .toString()
  //                 .toLowerCase()
  //                 .contains(_searchText.toLowerCase()))
  //             .toList();
  //       }
  //       // if (_filterBy == "expense" || _filterBy == "income") {
  //       //   _filteredTransactions = transactions.where((transaction) =>
  //       //       transaction.type.toString().toLowerCase().contains(
  //       //           _searchText.toLowerCase())).toList();
  //       // }
  //       else if (_filterBy == "clear") {
  //         _filteredTransactions = transactions
  //             .where((transaction) => transaction.title
  //                 .toLowerCase()
  //                 .contains(_searchText.toLowerCase()))
  //             .toList();
  //       }
  //     } else {
  //       _filteredTransactions = transactions;
  //     }
  //     // _filteredTransactions = transactions.where((transaction) =>
  //     //         transaction.title
  //     //             .toLowerCase()
  //     //             .contains(_searchText.toLowerCase())||
  //     //         transaction.category
  //     //             .toLowerCase()
  //     //             .contains(_searchText.toLowerCase()) ||
  //     //         transaction.date
  //     //             .toString()
  //     //             .toLowerCase()
  //     //             .contains(_searchText.toLowerCase()) ||
  //     //         (transaction.isExpense ? 'expense' : 'income')
  //     //             .toLowerCase()
  //     //             .contains(_searchText.toLowerCase()))
  //     //     .toList();
  //     // }
  //   });
  // }

  void initState() {
    super.initState();
    _fetchData();
    startingDateContoller.text = DateFormat('dd/MM/yyyy').format(_startDate).toString();
    endingDateContoller.text = DateFormat('dd/MM/yyyy').format(_endDate).toString();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (_loading) return;

    setState(() {
      _loading = true;
    });

    QuerySnapshot querySnapshot;
    if (_documents.isEmpty) {
      querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(cValue.currentUser.value.uid)
          .collection('transactions')
          .orderBy('date_time', descending: true)
          .limit(_limit)
          .get();
    } else {
      final lastDocument = _documents.last;
      querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(cValue.currentUser.value.uid)
          .collection('transactions')
          .orderBy('date_time', descending: true)
          .startAfterDocument(lastDocument)
          .limit(_limit)
          .get();
    }
    final newTransactions = querySnapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList();
    setState(() {
      _documents.addAll(querySnapshot.docs);
      _transactions.addAll(newTransactions);
      _tempTransactions.clear();
      _tempTransactions.addAll(_transactions);
      _loading = false;
      _hasMore = newTransactions.length == _limit;
    });
  }

  void _onScroll() {
    if (_loading) return;
    final isEnd = _scrollController.offset >= _scrollController.position.maxScrollExtent;
    if (isEnd) {
      _fetchData();
    }
  }

  // Future<void> _loadTransactions() async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   try {
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(cValue.currentUser.value.uid)
  //         .collection('transactions')
  //         .orderBy('date_time', descending: true)
  //         .limit(_limit)
  //         .get(GetOptions(source: _hasMore ? Source.serverAndCache : Source.cache));
  //
  //     if( snapshot.docs.isNotEmpty){
  //       _transactions = snapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList();
  //       lastDoc = snapshot.docs.last;
  //     }
  //   setState(() {
  //       _loading = false;
  //       _hasMore = snapshot.docs.length == _limit;
  //     });
  //   } on FirebaseException catch (e) {
  //     setState(() {
  //       _loading = false;
  //     });
  //     debugPrint(e.toString());
  //     await showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: Text('Error'),
  //           content: Text(e.message ?? 'An error occurred'),
  //           actions: [
  //             TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: Text('OK'))
  //           ],
  //         ));
  //   }
  // }
  //
  // Future<void> _loadMoreTransactions() async {
  //   if (_loading) {
  //     return;
  //   } else {
  //   setState(() {
  //     _loading = true;
  //   });
  //   try {
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(cValue.currentUser.value.uid)
  //         .collection('transactions')
  //         .orderBy('date_time', descending: true)
  //         .startAfterDocument(lastDoc!).limit(_limit)
  //         .get(GetOptions(source: _hasMore ? Source.serverAndCache : Source.cache));
  //
  //     final newTransactions = snapshot.docs.map((doc) =>
  //         Transaction.fromFirestore(doc)).toList();
  //     setState(() {
  //       _transactions.addAll(newTransactions);
  //       _loading = false;
  //       _hasMore = snapshot.docs.length != _limit;
  //     });
  //   } on FirebaseException catch (e) {
  //     setState(() {
  //       _loading = false;
  //     });
  //     debugPrint(e.toString());
  //     await showDialog(context: context, builder: (context) =>
  //         AlertDialog(
  //           title: Text('Error'),
  //           content: Text(e.message ?? 'An error occurred'),
  //           actions: [
  //             TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: Text('OK'))
  //           ],
  //         ));
  //   }
  // }
  // }

  void _searchTransactions(String query) async {
    setState(() {
      _loading = true;
      _searchQuery = query;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(cValue.currentUser.value.uid)
          .collection('transactions')
          .get(GetOptions(source: _hasMore ? Source.serverAndCache : Source.cache));

      final _filteredTransactions = querySnapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList();
      setState(() {
        print(_tempTransactions.length);
        _transactions = _filteredTransactions.where((transaction) =>
        transaction.title.toString().toLowerCase().contains(query.toLowerCase()) ||
            transaction.type.toString().toLowerCase().contains(query.toLowerCase()) ||
            transaction.amount.toString().toLowerCase().contains(query.toLowerCase()) ||
            transaction.date.toString()  .toLowerCase().contains(query.toLowerCase()) ||
            transaction.category.toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
        _loading = false;
      });
    } catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while searching transactions.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'))
            ],
          ));
    }
  }

  Future<void> exportData(DateTime Start, DateTime End) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(cValue.currentUser.value.uid)
        .collection('transactions')
        .where('date_time', isGreaterThanOrEqualTo: Start.toIso8601String())
        .where('date_time', isLessThanOrEqualTo: End.toIso8601String())
        .get(GetOptions(source: _hasMore ? Source.serverAndCache : Source.cache));

    final _exportData = querySnapshot.docs.map((doc) => Transaction.fromFirestore(doc)).toList();

    // Create XLSX File
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet() as String];
    // Define column headings
    sheet!.merge(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0));
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = 'Transaction Records';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1)).value = 'Title';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value = 'DateTime';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1)).value = 'Time';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1)).value = 'Type';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1)).value = 'Category';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1)).value = 'Method';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 1)).value = 'Amount';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 1)).value = 'Additional Information';

    // Add data to the sheet
    for (var i = 0; i < _exportData.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 2)).value = _exportData[i].title;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 2)).value = DateFormat("dd/MM/yyyy").format(_exportData[i].date);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 2)).value = DateFormat("hh:mm a").format(_exportData[i].date);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 2)).value = _exportData[i].type.capitalizeFirst;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 2)).value = _exportData[i].category;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 2)).value = _exportData[i].method;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 2)).value = _exportData[i].amount.toStringAsFixed(2);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 2)).value = _exportData[i].additional;
    }

    var fileBytes = excel.save();
    final downloadDir = Directory('/storage/emulated/0/Download');
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    final fileName = 'Transaction Records From ${DateFormat("dd-MM-yy").format(Start).toString()} to ${DateFormat("dd-MM-yy").format(End).toString()}';
    File('${downloadDir.path}/${fileName}.xlsx')
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transcation Recods"),
        centerTitle: true,
        backgroundColor: primary,
        actions: [
          IconButton(
              onPressed: () =>  showDialog(
                  context: context,
                  builder: (context) => StatefulBuilder(builder: (context, setState) => AlertDialog(
                        title: Center(child: Text("Export Date")),
                        content: Container(
                          height: 150,
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
                                height: 15,
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
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              OutlinedButton(
                                child: Text("Export Recode", style: TextStyle(color: Colors.green),),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                  );
                                  final permissionStatus = await Permission.storage.request();
                                  if (permissionStatus.isDenied) {
                                    showTopTitleSnackBar(context, Icons.error, "Storage permission denied");
                                  } else {
                                    exportData(_startDate,_endDate);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    showTopTitleSnackBar(context, Icons.import_export_sharp, "Recode Exported Successfully");
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ))),
              icon: Icon(Iconsax.export_3))
        ],
        // actions: [
        //   // PopupMenuButton(
        //   //   itemBuilder: (BuildContext context) => [
        //   //     PopupMenuItem(
        //   //       child: Text('Filter by title'),
        //   //       value: 'title',
        //   //       onTap: () {
        //   //         _filterBy = "title";
        //   //       },
        //   //     ),
        //   //     PopupMenuItem(
        //   //       child: Text('Filter by date'),
        //   //       value: 'date',
        //   //       onTap: () {
        //   //         _filterBy = "date";
        //   //       },
        //   //     ),
        //   //     PopupMenuItem(
        //   //       child: Text('Filter by category'),
        //   //       value: 'category',
        //   //       onTap: () {
        //   //         _filterBy = "category";
        //   //       },
        //   //     ),
        //   //     PopupMenuItem(
        //   //       child: Text('Filter by type'),
        //   //       value: 'type',
        //   //       onTap: () {
        //   //         _filterBy = "type";
        //   //       },
        //   //     ),
        //   //     PopupMenuItem(
        //   //       child: Text('Clear Filter'),
        //   //       value: 'clear',
        //   //       onTap: () {
        //   //         _filterBy = "clear";
        //   //       },
        //   //     ),
        //   //   ],
        //   //   onSelected: (String value) {
        //   //     // TODO: Implement filter logic
        //   //   },
        //   // ),
        // ],
      ),
      body: Container(
        width: ScreenWidth(context),
        height: ScreenHeight(context),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: ScreenWidth(context),
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  // controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value){
                    if(value.isNotEmpty){
                      _searchTransactions(value);
                    } else {
                      setState(() {
                        _transactions.clear();
                        _transactions.addAll(_tempTransactions);
                      });
                    }
                  },
                ),
              ),
            ),
            if (_loading && _transactions.isEmpty) ...[
              Center(
                child: CircularProgressIndicator(),
              )
            ]
            else ...[
              Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: _transactions.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _transactions.length) {
                    return Container(
                      height: _loading ? 100.0 : 0.0,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  else {
                    Transaction transaction = _transactions[index];
                    return Slidable(
                      child: TransactionListTile(transaction: transaction),
                      endActionPane: ActionPane(
                        motion: DrawerMotion(),
                        children: [
                          SlidableAction(
                            icon: Icons.edit,
                            backgroundColor: Colors.blue.shade500,
                            onPressed: (context) {
                              if(_transactions[index].type == "income"){
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    EditIncomeTransactionScreen(transaction: _transactions[index])));
                              }
                              if(_transactions[index].type == "expense"){
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    EditExpenseTransactionScreen(transaction: _transactions[index])));
                              }
                            },
                          ),
                          SlidableAction(
                            icon: Icons.delete,
                            backgroundColor: Colors.red.shade500,
                            onPressed: (context) {
                              if(_transactions[index].type == "expense"){
                                eController.deleteExpenseRecode(_transactions[index].id.toString(),_transactions[index].amount,_transactions[index].category,_transactions[index].date);
                              }
                              if(_transactions[index].type == "income"){
                                iController.deleteIncomeRecode(_transactions[index].id.toString(),_transactions[index].amount,_transactions[index].category,_transactions[index].date);
                              }
                              showTopTitleSnackBar(context, Icons.delete_rounded, "Recode Deleted Successfully");
                              setState(() {
                                _transactions.removeAt(index);
                              });
                            },
                          )
                        ],
                      ),
                    );
                  }
                },
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(),
              ),
            ),
            ]
          ],
        ),
      ),
    );
  }
}

class TransactionListTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionListTile({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                title: Align(
                alignment: Alignment.center,
                child: Text(
                  "Transaction Detail",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              actions: [OutlinedButton(child: Text("OK"),onPressed: (){
                Navigator.pop(context);
              },),],
              content: SingleChildScrollView(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Title: \n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: '${transaction.title}\n\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                      TextSpan(
                        text: 'Category: \n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: '${transaction.category}\n\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                      TextSpan(
                        text: 'Type: \n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: '${transaction.type}\n\n'.capitalizeFirst,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                      TextSpan(
                        text: 'Amount: \n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: '${transaction.amount}\n\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                      TextSpan(
                        text: 'Method: \n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: '${transaction.method}\n\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                      TextSpan(
                        text: 'Date and Time: \n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: '${DateFormat('dd-MM-yyyy | hh:mm a').format(transaction.date)}\n\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                      TextSpan(
                        text: 'Additional Info: \n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                      ),
                      TextSpan(
                        text: '${transaction.additional}\n\n',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            );
          },
        );
      },
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: transaction.type == "expense" ? Colors.red : Colors.green,
              ),
              child: transaction.method == "Cash"
                  ? Icon(Bootstrap.cash_stack, color: Colors.white)
                  : transaction.method == "Bank"
                  ? Icon(Icons.account_balance_outlined, color: Colors.white)
                  : Icon(Icons.credit_card_outlined, color: Colors.white),
            ),
            title: Text(
              transaction.title,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  '${transaction.category}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
  }
}
