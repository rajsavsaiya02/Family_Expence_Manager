import 'dart:math';
import 'package:fem/Utility/Colors.dart';
import 'package:flutter/material.dart';

class InterestCalculator extends StatefulWidget {
  const InterestCalculator({Key? key}) : super(key: key);

  @override
  State<InterestCalculator> createState() => _InterestCalculatorState();
}

class _InterestCalculatorState extends State<InterestCalculator>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  //Simple
  double _principal = 0.0;
  double _interestRate = 0.0;
  int _years = 0;
  double _totalAmount = 0.0;
  double _interestEarned = 0.0;

  //compound
  double _ciPrincipal = 0.0;
  double _ciInterestRate = 0.0;
  int _ciYears = 0;

  int _compoundsPerYear = 12;

  double _ciTotalAmount = 0.0;
  double _ciInterestEarned = 0.0;

  List<String> _compoundPeriods = ['Annually', 'Semi-annually', 'Quarterly', 'Monthly'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primary,
        title: const Text('Interest Calculator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Simple'),
            Tab(text: 'Compound'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: 'Principal amount',border: OutlineInputBorder()),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a principal amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _principal = double.parse(value!);
                      },
                    ),
                    SizedBox(height: 16,),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: 'Interest rate (in %)',border: OutlineInputBorder()),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter an interest rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) < 0) {
                          return 'Please enter a non-negative number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _interestRate = double.parse(value!) / 100;
                      },
                    ),
                    SizedBox(height: 16,),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Number of years',border: OutlineInputBorder()),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a number of years';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Please enter a positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _years = int.parse(value!);
                      },
                    ),
                    SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              setState(() {
                                _totalAmount =
                                    _principal * (1 + _interestRate * _years);
                                _interestEarned = _totalAmount - _principal;
                              });
                            }
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
                      ],
                    ),
                    SizedBox(height: 16.0),
                    if (_totalAmount != null && _interestEarned != null) ...[
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
                                  Text('Total Amount: ',style: TextStyle(fontSize: 18.0),),
                                  Text('${_totalAmount.toStringAsFixed(2)}',style: TextStyle(fontSize: 18.0),),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Interest Earned: ',style: TextStyle(fontSize: 18.0),),
                                  Text('${_interestEarned.toStringAsFixed(2)}',style: TextStyle(fontSize: 18.0),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(),
                    ]

                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: 'Principal amount',border: OutlineInputBorder(),),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a principal amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Please enter a positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _ciPrincipal = double.parse(value!);
                      },
                    ),
                    SizedBox(height: 16,),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: 'Interest rate (in %)',border: OutlineInputBorder(),),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter an interest rate';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) < 0) {
                          return 'Please enter a non-negative number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _ciInterestRate = double.parse(value!) / 100;
                      },
                    ),
                    SizedBox(height: 16,),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Number of years',border: OutlineInputBorder(),),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a number of years';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Please enter a positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _ciYears = int.parse(value!);
                      },
                    ),
                    SizedBox(height: 16,),
                    DropdownButtonFormField(
                      value: _compoundPeriods[3],
                      items: _compoundPeriods.map((period) {
                        return DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          switch (value) {
                            case 'Annually':
                              _compoundsPerYear = 1;
                              break;
                            case 'Semi-annually':
                              _compoundsPerYear = 2;
                              break;
                            case 'Quarterly':
                              _compoundsPerYear = 4;
                              break;
                            case 'Monthly':
                              _compoundsPerYear = 12;
                              break;
                          }
                        });
                      },
                      decoration: InputDecoration(
                          labelText: 'Compound period',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              calculateInterest();
                            }
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
                      ],
                    ),
                    SizedBox(height: 26.0),
                    _ciTotalAmount != null && _ciInterestEarned != null
                        ? Container(
                      decoration:BoxDecoration(
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
                                      Text(
                                        'Total Amount:',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      Text(
                                        '${_ciTotalAmount.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Interest Earned: ',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      Text(
                                        '${_ciInterestEarned.toStringAsFixed(2)}',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ),
                        )
                        : Container(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void calculateInterest() {
    double total = _ciPrincipal *
        pow(1 + (_ciInterestRate / _compoundsPerYear), _compoundsPerYear * _ciYears);
    _ciTotalAmount = total;
    _ciInterestEarned = total - _ciPrincipal;
    setState(() {});
  }
}
