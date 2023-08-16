import 'package:fem/Database/FireStore_Database/User_Transaction/expense_datamodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../Utility/Colors.dart';
import 'expense_input_screen.dart';
import 'income_input_screen.dart';

class TransactionInput extends StatefulWidget {
  const TransactionInput({super.key});

  @override
  _TransactionInputState createState() => _TransactionInputState();
}

class _TransactionInputState extends State<TransactionInput>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recode Transaction'),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 5,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => TransactionInput()));
              },
              icon: Icon(Icons.refresh))
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: TabBarView(
          controller: _tabController,
          children: [
            ExpenseInputScreen(),
            IncomeInputScreen(),
          ],
        ),
      ),
    );
  }
}


// SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     TextFormField(
//                       controller: _titleIncomeController,
//                       decoration: const InputDecoration(
//                         labelText: 'Title',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 16.0),
//                     DropdownButtonFormField<String>(
//                       value: _Income_category,
//                       items: <String>['Salary', 'Borrow', 'Treading', 'Gift']
//                           .map<DropdownMenuItem<String>>(
//                               (String value) => DropdownMenuItem<String>(
//                                     value: value,
//                                     child: Text(value),
//                                   ))
//                           .toList(),
//                       onChanged: (String? value) {
//                         setState(() {
//                           _Income_category = value!;
//                         });
//                       },
//                       decoration: const InputDecoration(
//                         labelText: 'Category',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 16.0),
//                     TextFormField(
//                       controller: _amountIncomeController,
//                       keyboardType: TextInputType.number,
//                       decoration: const InputDecoration(
//                         labelText: 'Amount',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 16.0),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                             'Date and Time: ${DateFormat('dd-MM-yyyy | hh:mm a').format(_dateTime)}'),
//                         IconButton(
//                           icon: const Icon(Icons.calendar_month_outlined),
//                           onPressed: () {
//                             showDatePicker(
//                                     context: context,
//                                     initialDate: _dateTime,
//                                     firstDate: DateTime(2000),
//                                     lastDate: DateTime.now())
//                                 .then((date) {
//                               if (date != null) {
//                                 showTimePicker(
//                                         context: context,
//                                         initialTime: TimeOfDay.now())
//                                     .then((time) {
//                                   if (time != null) {
//                                     setState(() {
//                                       _dateTime = DateTime(
//                                           date.year,
//                                           date.month,
//                                           date.day,
//                                           time.hour,
//                                           time.minute);
//                                     });
//                                   }
//                                 });
//                               }
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16.0),
//                     Container(
//                       width: 150,
//                       height: 150,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: const Icon(Icons.add_a_photo, size: 80),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         // TODO: Implement image upload
//                       },
//                       child: const Text('Upload Image'),
//                     ),
//                     const SizedBox(height: 16.0),
//                     TextFormField(
//                       controller: _notesIncomeController,
//                       maxLines: 5,
//                       decoration: const InputDecoration(
//                         labelText: 'Additional Info',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 16.0),
//                     ElevatedButton(
//                       onPressed: () {
//                         // TODO: Save expense data
//                         Navigator.pop(context);
//                       },
//                       child: const Text('Save Income'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),