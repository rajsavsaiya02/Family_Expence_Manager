import 'package:fem/Utility/Colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class TaxCalculator extends StatefulWidget {
  const TaxCalculator({Key? key}) : super(key: key);

  @override
  _TaxCalculatorState createState() => _TaxCalculatorState();
}

class _TaxCalculatorState extends State<TaxCalculator> {
  late TextEditingController _amountController;
  late TextEditingController _taxPercentageController;
  late List<_TaxData> _taxData;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _taxPercentageController = TextEditingController();
    _taxData = [];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _taxPercentageController.dispose();
    super.dispose();
  }

  void _calculateTax() {
    double amount = double.tryParse(_amountController.text) ?? 0;
    double taxPercentage = double.tryParse(_taxPercentageController.text) ?? 0;

    double taxAmount = (amount * taxPercentage) / 100;
    double totalAmount = amount + taxAmount;

    setState(() {
      _result = 'Tax Amount: ₹${taxAmount.toStringAsFixed(2)}\n'
          'Total Amount: ₹${totalAmount.toStringAsFixed(2)}';

      _taxData = [
        _TaxData('Amount', amount),
        _TaxData('Tax', taxAmount),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tax Calculator'),
        centerTitle: true,
        backgroundColor: primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10,),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _taxPercentageController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Tax Percentage',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _calculateTax,
              child: Text('Calculate',style: TextStyle(fontSize: 24),),
              style: ElevatedButton.styleFrom(
                fixedSize: Size.square(50),
                backgroundColor: primary,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              _result,
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            if (_taxData.isNotEmpty)
              Container(
                height: 400.0,
                child: SfCircularChart(
                  legend: Legend(
                    isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap,
                  ),
                  series: <CircularSeries>[
                    PieSeries<_TaxData, String>(
                      dataSource: _taxData,
                      xValueMapper: (_TaxData data, _) => data.label,
                      yValueMapper: (_TaxData data, _) => data.amount,
                      dataLabelMapper: (_TaxData data, _) =>
                      '₹${data.amount.toStringAsFixed(2)}',
                      enableTooltip: true,
                      dataLabelSettings: DataLabelSettings(
                        textStyle: TextStyle(fontSize: 18),
                        isVisible: true,
                        labelPosition: ChartDataLabelPosition.inside,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaxData {
  final String label;
  final double amount;

  _TaxData(this.label, this.amount);
}