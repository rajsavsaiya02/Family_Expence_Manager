import 'package:fem/Utility/Colors.dart';
import 'package:fem/Utility/Values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:math_expressions/math_expressions.dart';

class TVMCalculator extends StatefulWidget {
  @override
  _TVMCalculatorState createState() => _TVMCalculatorState();
}

class _TVMCalculatorState extends State<TVMCalculator> {
  double _presentValue = 0.0;
  double _interestRate = 0.0;
  int _numberOfPeriods = 0;
  double _futureValue = 0.0;
  List<double> chartData = [];

  void _calculate() {
    setState(() {
      List<double> chartData = [];
      for (int i = 0; i <= _numberOfPeriods; i++) {
        double periodPV = _presentValue *
            math.pow((1 + (_interestRate / 100)), _numberOfPeriods);
        chartData.add(periodPV);
      }
      _futureValue =
          _presentValue * math.pow(1 + (_interestRate / 100), _numberOfPeriods);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Time Value of Money"),
        centerTitle: true,
        backgroundColor: primary,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: ScreenWidth(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Present Value',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _presentValue = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Interest Rate',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _interestRate = double.tryParse(value) ?? 0.0;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Number of Periods',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _numberOfPeriods = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      child: Text('Calculate',style: TextStyle(fontSize: 26),),
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size.square(50),
                        backgroundColor: primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_futureValue > 0) ...[
                Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Future Value:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('${_futureValue.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 400,
                      width: ScreenWidth(context),
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(
                          title: AxisTitle(
                            text: 'Time',
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(
                            text: 'Amount',
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        series: <ChartSeries>[
                          StackedAreaSeries<_ChartData, String>(
                            dataSource: List.generate(_numberOfPeriods + 1, (index) {
                              double periodPV = _presentValue *
                                  math.pow((1 + (_interestRate / 100)), index);
                              return _ChartData('${index}yrs', periodPV);
                            }),
                            xValueMapper: (_ChartData data, _) => data.time,
                            yValueMapper: (_ChartData data, _) => data.amount.ceilToDouble(),
                            color: Colors.green,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.auto,
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        legend: Legend(
                          isVisible: true,
                          position: LegendPosition.bottom,
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //   child: Container(
                  //       height: 400,
                  //       width: ScreenWidth(context),
                  //       child: SfCartesianChart(
                  //         primaryXAxis: CategoryAxis(
                  //           title: AxisTitle(
                  //             text: 'Time',
                  //             textStyle: TextStyle(
                  //               color: Colors.black,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //         ),
                  //         primaryYAxis: NumericAxis(
                  //           title: AxisTitle(
                  //             text: 'Amount',
                  //             textStyle: TextStyle(
                  //               color: Colors.black,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //         ),
                  //         series: <ChartSeries>[
                  //           LineSeries<_ChartData, String>(
                  //             dataSource: List.generate(_numberOfPeriods + 1, (index) {
                  //               double periodPV = _presentValue *
                  //                   math.pow((1 + (_interestRate / 100)), index);
                  //               return _ChartData('${index}yrs', periodPV);
                  //             }),
                  //             xValueMapper: (_ChartData data, _) => data.time,
                  //             yValueMapper: (_ChartData data, _) => data.amount,
                  //             color: Colors.green,
                  //             markerSettings: MarkerSettings(
                  //               isVisible: true,
                  //               shape: DataMarkerType.circle,
                  //               borderWidth: 2,
                  //               borderColor: Colors.white,
                  //             ),
                  //           ),
                  //         ],
                  //         legend: Legend(
                  //           isVisible: true,
                  //           position: LegendPosition.bottom,
                  //           textStyle: TextStyle(
                  //             color: Colors.black,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //         tooltipBehavior: TooltipBehavior(
                  //           enable: true,
                  //           format: 'point.y',
                  //         ),
                  //       ),
                  //   ),
                  // ),
                ]),
              ] else
                ...[
                  Container(),
                ]
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.time, this.amount);

  final String time;
  final double amount;
}
