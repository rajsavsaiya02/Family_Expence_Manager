import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../Utility/Colors.dart';

class EMICal extends StatefulWidget {
  const EMICal({Key? key}) : super(key: key);

  @override
  State<EMICal> createState() => _EMICalState();
}

class _EMICalState extends State<EMICal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List _tenureTypes = ['Month(s)', 'Year(s)'];
  String _tenureType = "Year(s)";
  String _emiResult = "";
  String _totalAmount = "";
  String _totalInterest = "";

  double _loanAmount = 0.0;
  double _loaninterestRate = 0.0;
  int _loanTerm = 0;
  String _loanresult = "";

  double _loanmonthlyPayment = 0.0;
  double _loantotalPayment = 0.0;
  double _loantotalInterest = 0.0;

  final TextEditingController _loanprincipalAmount = TextEditingController();
  final TextEditingController _loaninterestRateController = TextEditingController();
  final TextEditingController _loantenure = TextEditingController();
  final TextEditingController _emitenure = TextEditingController();
  final TextEditingController _emiprincipalAmount = TextEditingController();
  final TextEditingController _emiinterestRateController = TextEditingController();

  bool _switchValue = true;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EMI & Loan Calculator"),
        elevation: 5,
        centerTitle: true,
        backgroundColor: primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'EMI Calculator'),
            Tab(text: 'Loan Calculator'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            child: Container(
              child: Center(
                  child: Container(
                      child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      padding: EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: _emiprincipalAmount,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Enter Principal Amount"),
                        keyboardType: TextInputType.number,
                      )),
                  Container(
                      padding: EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: _emiinterestRateController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Interest Rate"),
                        keyboardType: TextInputType.number,
                      )),
                  Container(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        children: <Widget>[
                          Flexible(
                              flex: 4,
                              fit: FlexFit.tight,
                              child: TextField(
                                controller: _emitenure,
                                decoration: InputDecoration(
                                  labelText: "Tenure",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              flex: 1,
                              child: Column(children: [
                                Text(_tenureType,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Switch(
                                    value: _switchValue,
                                    onChanged: (bool value) {
                                      print(value);
                                      if (value) {
                                        _tenureType = _tenureTypes[1];
                                      } else {
                                        _tenureType = _tenureTypes[0];
                                      }
                                      setState(() {
                                        _switchValue = value;
                                      });
                                    })
                              ]))
                        ],
                      )),
                  ElevatedButton(
                    onPressed: () {
                      _handleCalculation();
                      FocusScope.of(context).unfocus();
                    },
                    child: Text(
                      "Calculate",
                      style: TextStyle(fontSize: 28),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      textStyle: TextStyle(
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 24.0, right: 24.0),
                    ),
                  ),
                  emiResultsWidget(_emiResult)
                ],
              ))),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: _loanprincipalAmount,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Loan amount"),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a loan amount';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _loanAmount = double.parse(value!);
                          },
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Container(
                          padding: EdgeInsets.all(10.0),
                          child: TextFormField(
                            controller: _loaninterestRateController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Interest Rate"),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a Interest Rate';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _loaninterestRate = double.parse(value!);
                            },
                          )),
                      SizedBox(height: 8.0),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              flex: 4,
                              fit: FlexFit.tight,
                              child: TextFormField(
                                controller: _loantenure,
                                decoration: InputDecoration(
                                  labelText: "Loan Duration",
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a loan term';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _loanTerm = int.parse(value!);
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Flexible(
                                flex: 1,
                                child: Column(children: [
                                  Text(_tenureType,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Switch(
                                      value: _switchValue,
                                      onChanged: (bool value) {
                                        print(value);
                                        if (value) {
                                          _tenureType = _tenureTypes[1];
                                        } else {
                                          _tenureType = _tenureTypes[0];
                                        }
                                        setState(() {
                                          _switchValue = value;
                                        });
                                      })
                                ]))
                          ],
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            _calculateLoan();
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            "Calculate",
                            style: TextStyle(fontSize: 28),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            textStyle: TextStyle(
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.only(
                                top: 10.0,
                                bottom: 10.0,
                                left: 24.0,
                                right: 24.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      loneResultsWidget(_loanresult),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCalculation() {
    //  Amortization
    //  A = Payemtn amount per period
    //  P = Initial Printical (loan amount)
    //  r = interest rate
    //  n = total number of payments or periods

    double A = 0.0;
    double I = 0.0;
    double T = 0.0;
    int P = int.parse(_emiprincipalAmount.text);
    double r = int.parse(_emiinterestRateController.text) / 12 / 100;
    int n = _tenureType == "Year(s)"
        ? int.parse(_emitenure.text) * 12
        : int.parse(_emitenure.text);

    A = (P * r * pow((1 + r), n) / (pow((1 + r), n) - 1));
    I = A * n - P;
    T = P + I;
    _emiResult = A.toStringAsFixed(2);
    _totalInterest = I.toStringAsFixed(2);
    _totalAmount = T.toStringAsFixed(2);
    setState(() {});
  }

  void _calculateLoan() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool _isYearly;
      _tenureType == "Year(s)" ? _isYearly = true : _isYearly = false;

      double rate = _loaninterestRate / 100 / (_isYearly ? 12 : 12);

      int nper = _isYearly ? _loanTerm * 12 : _loanTerm;

      double numerator = _loanAmount * rate * pow(1 + rate, nper);
      double denominator = pow(1 + rate, nper) - 1;
      _loanmonthlyPayment = numerator / denominator;
      _loanresult = _loanmonthlyPayment.toString();
      _loantotalInterest = (_loanmonthlyPayment * nper) - _loanAmount;
      _loantotalPayment = _loanAmount + _loantotalInterest;
      setState(() {});
    }
  }

  Widget emiResultsWidget(emiResult) {
    bool canShow = false;
    String _emiResult = emiResult;

    if (_emiResult.length > 0) {
      canShow = true;
    }
    return Container(
        margin: EdgeInsets.only(top: 40.0),
        child: canShow
            ? Column(children: [
                Text("Your Monthly EMI is",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 10,
                ),
                Container(
                    child: Text(_emiResult,
                        style: TextStyle(
                            fontSize: 28.0, fontWeight: FontWeight.w600))),
                SizedBox(
                  height: 10,
                ),
                Text("Total Interest Payable on EMI is",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 10,
                ),
                Container(
                    child: Text(_totalInterest,
                        style: TextStyle(
                            fontSize: 28.0, fontWeight: FontWeight.w600))),
                SizedBox(
                  height: 10,
                ),
                Text("Total Payment with Interest on EMI is",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 10,
                ),
                Container(
                    child: Text(_totalAmount,
                        style: TextStyle(
                            fontSize: 28.0, fontWeight: FontWeight.w600))),
              ])
            : Container());
  }

  Widget loneResultsWidget(value) {
    bool loancanShow = false;
    String monthlyPayment = value.toString();

    if (monthlyPayment.length > 0) {
      loancanShow = true;
    }
    return Container(
        alignment: Alignment.center,
        child: loancanShow
            ? Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(height: 16.0),
                Text(
                  'Monthly Payment:',
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  '${_loanmonthlyPayment.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 28.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Total Interest:',
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  ' ${_loantotalInterest.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 28.0),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Total Payment:',
                  style: TextStyle(fontSize: 24.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  ' ${_loantotalPayment.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 28.0),
                ),
              ])
            : Container());
  }
}
