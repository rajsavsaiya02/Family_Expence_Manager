import 'package:fem/Utility/Colors.dart';
import 'package:flutter/material.dart';

class TipAndSplitCalculator extends StatefulWidget {
  const TipAndSplitCalculator({Key? key}) : super(key: key);

  @override
  State<TipAndSplitCalculator> createState() => _TipAndSplitCalculatorState();
}

class _TipAndSplitCalculatorState extends State<TipAndSplitCalculator>  with SingleTickerProviderStateMixin  {
  int _personCount = 1;
  double _billAmount = 0.0;
  double _tipPercentage = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Tip & Bill Splitter'),
        backgroundColor: primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Text(
              'Enter bill amount',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 8.0),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0.0',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _billAmount = double.parse(value);
                });
              },
            ),
            SizedBox(height: 16.0),
            Text(
              'Select tip percentage',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _tipPercentage,
                    min: 0.0,
                    max: 50.0,
                    divisions: 50,
                    onChanged: (value) {
                      setState(() {
                        _tipPercentage = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16.0),
                Text('${_tipPercentage.toStringAsFixed(1)}%'),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              'Number of people',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        if (_personCount > 1) {
                          _personCount--;
                        }
                      });
                    },
                    child: Text(
                      '-',
                      style: TextStyle(fontSize: 48.0),
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Text(
                  '$_personCount',
                  style: TextStyle(fontSize: 38.0),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _personCount++;
                      });
                    },
                    child: Text(
                      '+',
                      style: TextStyle(fontSize: 48.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.0),
            Center(
              child: Text(
                'Total per person',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: Text(
                '${(_billAmount * (1 + _tipPercentage / 100) / _personCount).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 48.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
