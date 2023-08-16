import 'package:fem/Utility/Colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DiscountCalculator extends StatefulWidget {
  @override
  _DiscountCalculatorState createState() => _DiscountCalculatorState();
}

class _DiscountCalculatorState extends State<DiscountCalculator> {
  double _price = 0.0;
  int _percentOff = 0;
  double _discount = 0.0;
  double _total = 0.0;

  // Define a list of colors
  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Discount Calculator'),
          centerTitle: true,
          backgroundColor: primary,
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter the original price (INR)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _price = double.parse(value);
                    _calculate();
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter the discount percentage (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _percentOff = int.parse(value);
                    _calculate();
                  });
                },
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(), left: BorderSide(), right: BorderSide(), bottom: BorderSide() ),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Original Price:',
                              style: TextStyle(fontSize: 20.0)),
                          Text('₹${_price.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 20.0)),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Discount Amount:',
                              style: TextStyle(fontSize: 20.0)),
                          Text('₹${_discount.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 20.0)),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('Final Price:', style: TextStyle(fontSize: 20.0)),
                          Text('₹${_total.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 20.0)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries>[
                    ColumnSeries<ChartItem, String>(
                      dataSource: <ChartItem>[
                        ChartItem('Original Price', _price),
                        ChartItem('Discount Amount', _discount),
                        ChartItem("Final Price", _price-_discount),
                      ],
                      xValueMapper: (ChartItem item, _) => item.label,
                      yValueMapper: (ChartItem item, _) => item.value,
                      dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside),
                          pointColorMapper :(ChartItem item, _) {
                            switch (item.label) {
                              case 'Original Price':
                                return Colors.blue;
                              case 'Discount Amount':
                                return Colors.green;
                              case 'Final Price':
                                return Colors.orange;
                              default:
                                return primary;
                            }
                        }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }

  void _calculate() {
    _discount = _price * _percentOff / 100.0;
    _total = _price - _discount;
  }
}

class ChartItem {
  final String label;
  final double value;

  ChartItem(this.label, this.value);
}