import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fem/Components/Category_Bottom_Sheet/category_buttom_sheet.dart';
import 'package:fem/Database/FireStore_Database/User_Transaction/income_datamodel.dart';
import 'package:fem/Utility/Colors.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';

class IncomeInputScreen extends StatefulWidget {
  const IncomeInputScreen({Key? key}) : super(key: key);

  @override
  State<IncomeInputScreen> createState() => _IncomeInputScreenState();
}

class _IncomeInputScreenState extends State<IncomeInputScreen> {
  final UserIncomeController incomeController =
      Get.put(UserIncomeController());

  late DateTime _dateTime = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  TextEditingController _titleIncomeController = TextEditingController();
  TextEditingController _amountIncomeController = TextEditingController();
  TextEditingController _notesIncomeController = TextEditingController();
  TextEditingController _categoryIncomeMenuSearchBar = TextEditingController();

  String? _incomeMethod;
  final List<Map<String, dynamic>> _radioValues = [
    {
      'value': 'Cash',
      'icon': Bootstrap.cash_stack,
      'color': Colors.green,
    },
    {
      'value': 'Bank',
      'icon': Icons.account_balance_outlined,
      'color': Colors.blue,
    },
    {
      'value': 'Credit',
      'icon': Icons.credit_card_outlined,
      'color': Colors.orange
    },
  ];

  String? _Income_category;

  @override
  Widget build(BuildContext context) {
    if (incomeController.i_Category.isEmpty) {
      incomeController.updateIncomeCategoryList();
    }
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleIncomeController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter title of income';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: ScreenWidth(context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 55,
                      width: ScreenWidth(context) * 0.73,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border:
                            Border.all(color: Colors.grey.shade500, width: 1),
                      ),
                      child: Obx(
                        () => DropdownButtonHideUnderline(
                          child: DropdownButton2(
                            isExpanded: true,
                            hint: Text(
                              'Select Category',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            items: incomeController.i_Category
                                .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            value: _Income_category,
                            onChanged: (value) {
                              setState(() {
                                if (value.toString().isNotEmpty) {
                                  _Income_category = value.toString();
                                }
                              });
                            },
                            dropdownStyleData: DropdownStyleData(
                                maxHeight: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                elevation: 4,
                                offset: const Offset(0, 0),
                                scrollbarTheme: ScrollbarThemeData(
                                  thickness: MaterialStateProperty.all(6),
                                  thumbVisibility:
                                      MaterialStateProperty.all(true),
                                )),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                              padding: EdgeInsets.only(left: 14, right: 14),
                            ),
                            dropdownSearchData: DropdownSearchData(
                              searchController: _categoryIncomeMenuSearchBar,
                              searchInnerWidgetHeight: 50,
                              searchInnerWidget: Container(
                                height: 50,
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  bottom: 4,
                                  right: 8,
                                  left: 8,
                                ),
                                child: TextFormField(
                                  expands: true,
                                  maxLines: null,
                                  controller: _categoryIncomeMenuSearchBar,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    hintText: 'Search for an Category...',
                                    hintStyle: const TextStyle(fontSize: 12),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              searchMatchFn: (item, searchValue) {
                                return (item.value
                                    .toString()
                                    .toLowerCase()
                                    .contains(
                                        searchValue.toLowerCase().toString()));
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CategoryManagePopup("income");
                          },
                        );
                        setState(() {
                          controller.refresh();
                        });
                      },
                      child: Container(
                        width: ScreenWidth(context) * 0.15,
                        height: 55,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.add,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _amountIncomeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter amount of income';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    _radioValues.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _incomeMethod = _radioValues[index]['value'];
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: _incomeMethod == _radioValues[index]['value']
                              ? _radioValues[index]['color']
                              : Colors.grey.shade200,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              _radioValues[index]['icon'],
                              color:
                                  _incomeMethod == _radioValues[index]['value']
                                      ? Colors.white
                                      : Colors.black,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              _radioValues[index]['value'],
                              style: TextStyle(
                                color: _incomeMethod ==
                                        _radioValues[index]['value']
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Date and Time:"),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        '${DateFormat('dd-MM-yyyy | hh:mm a').format(_dateTime)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: Colors.white,
                        shape: CircleBorder(),
                        fixedSize: Size.square(55)),
                    child: const Icon(
                      Icons.calendar_month_outlined,
                      size: 30,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      showDatePicker(
                              context: context,
                              initialDate: _dateTime,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now())
                          .then((date) {
                        if (date != null) {
                          showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now())
                              .then((time) {
                            if (time != null) {
                              setState(() {
                                _dateTime = DateTime(date.year, date.month,
                                    date.day, time.hour, time.minute);
                              });
                            }
                          });
                        }
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextFormField(
                      controller: _notesIncomeController,
                      maxLines: 7,
                      decoration: InputDecoration(
                        hintText: 'Write your text here...',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                child: const Text('Save Income'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 10.0, left: 24.0, right: 24.0),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_Income_category == null) {
                      showTopTitleSnackBar(
                          context, Icons.error, "Select Income Category");
                    }
                    if (_incomeMethod == null) {
                      showTopTitleSnackBar(
                          context, Icons.error, "Select Income Method");
                    }
                    if (_Income_category != null && _incomeMethod != null) {
                      incomeController.addIncomeRecode(
                          _titleIncomeController.text,
                          _Income_category.toString(),
                          double.parse(_amountIncomeController.text.toString()),
                          _incomeMethod.toString(),
                          _dateTime,
                          _notesIncomeController.text);
                      Navigator.pop(context);
                      showTopTitleSnackBar(context, Icons.comment_sharp, "Income Recoded");
                    }
                  }
                },
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
