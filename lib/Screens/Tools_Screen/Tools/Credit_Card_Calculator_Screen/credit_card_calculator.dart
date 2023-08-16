import 'package:fem/Utility/Colors.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:flutter/material.dart';

class CreditCardPayoffCalculator extends StatefulWidget {
  @override
  _CreditCardPayoffCalculatorState createState() =>
      _CreditCardPayoffCalculatorState();
}

class _CreditCardPayoffCalculatorState
    extends State<CreditCardPayoffCalculator> {
  final _formKey = GlobalKey<FormState>();
  double _balance = 0.0;
  double _apr = 0.0;
  double _monthlyPayment = 0.0;
  double _additionalPayment = 0.0;
  int _monthsToPayOff = 0;
  double _totalInterestPaid = 0;

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      double balance = _balance;
      double monthlyPayment = _monthlyPayment + _additionalPayment;
      double monthlyInterestRate = _apr / 100 / 12;
      int monthsToPayOff = 0;
      int maxIterations = 100000;
      double totalInterestPaid = 0;

      while (balance > 0 && monthsToPayOff < maxIterations) {
        monthsToPayOff++;
        double interestPaid = balance * monthlyInterestRate;
        totalInterestPaid += interestPaid;
        double principalPaid = monthlyPayment - interestPaid;
        balance -= principalPaid;
        if(balance >= _balance){
          monthsToPayOff = 0;
          showTopSnackBar(context, Icons.warning_amber_outlined, "Monthly Payment is not applicable","Increase your monthly Payment");
          break;
        }
      }

      setState(() {
        _monthsToPayOff = monthsToPayOff;
        _totalInterestPaid = totalInterestPaid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Credit Card Payoff Calculator'),
        centerTitle: true,
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16,),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter the credit card balance',
                    labelText: 'Credit Card Balance',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid balance';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _balance = double.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter the APR',
                    labelText: "APR (Annual Percentage Rate)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid APR';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _apr = double.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter the monthly payment',
                    labelText: 'Monthly Payment',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a valid monthly payment';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _monthlyPayment = double.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter any additional monthly payment (optional)',
                    labelText: "Additional Monthly Payment",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _additionalPayment = double.tryParse(value) ?? 0;
                  },
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _calculate,
                      child: Text('Calculate',style: TextStyle(fontSize: 24),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        textStyle: TextStyle(
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 24.0, right: 24.0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                if (_monthsToPayOff > 0)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(), left: BorderSide(), right: BorderSide(), bottom: BorderSide() ),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Month\'s for Payoff : ',style: TextStyle(fontSize: 18.0),),
                              Text('${_monthsToPayOff}',style: TextStyle(fontSize: 18.0),),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Interest Paid : ',style: TextStyle(fontSize: 18.0),),
                              Text('${_totalInterestPaid.toStringAsFixed(2)}',style: TextStyle(fontSize: 18.0),),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Total Payment: ',style: TextStyle(fontSize: 18.0),),
                              Text('${(_totalInterestPaid+_balance).toStringAsFixed(2)}',style: TextStyle(fontSize: 18.0),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
