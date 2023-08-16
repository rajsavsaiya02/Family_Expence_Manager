import 'package:fem/Database/FireStore_Database/Family_Transaction/family_expense_datamodel.dart';
import 'package:fem/Database/FireStore_Database/User_Transaction/expense_datamodel.dart';
import 'package:fem/Database/FireStore_Database/User_Transaction/income_datamodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String type = "";

class CategoryManagePopup extends StatefulWidget {
  CategoryManagePopup(String s){
     type = s;
  }

  @override
  _CategoryManagePopupState createState() => _CategoryManagePopupState();
}

class _CategoryManagePopupState extends State<CategoryManagePopup> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final UserExpenseController expenseController = Get.put(UserExpenseController());
  final UserIncomeController incomeController = Get.put(UserIncomeController());
  final FamilyExpenseController familyExpenseController = Get.put(FamilyExpenseController());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: Center(child: Text('Category Manage')),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _textController,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter a category name';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                expenseController.updateExpenseCategoryList();
              },
              child: Text('Cancel',style: TextStyle(color: Colors.black),),
            ),
            Row(
              children: [
                OutlinedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    backgroundColor: Colors.white
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if(type == "expense"){
                        expenseController.deleteExpenseCategoryItem(context,"expenseCategory",_textController.text.trim().capitalize.toString());
                      }
                      if(type == "income"){
                        incomeController.deleteIncomeCategoryItem(context,"incomeCategory",_textController.text.trim().capitalize.toString());
                      }
                      if(type == "familyExpense"){
                        familyExpenseController.deleteExpenseCategoryItem(context, "expenseCategory", _textController.text.trim().capitalize.toString());
                      }
                    }
                  },
                  child: Text('Delete',style: TextStyle(color: Colors.red.shade900),),
                ),
                SizedBox(width: 10,),
                OutlinedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 2,
                      backgroundColor: Colors.white
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if(type == "expense"){
                        expenseController.addExpenseCategoryItem(context,"expenseCategory",_textController.text.trim().capitalize.toString());
                      }
                      if(type == "income"){
                        incomeController.addIncomeCategoryItem(context,"incomeCategory",_textController.text.trim().capitalize.toString());
                      }
                      if(type== "familyExpense"){
                        familyExpenseController.addExpenseCategoryItem(context, "expenseCategory", _textController.text.trim().capitalize.toString());
                      }
                    }
                  },
                  child: Text('Add',style: TextStyle(color: Colors.green.shade900),),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}