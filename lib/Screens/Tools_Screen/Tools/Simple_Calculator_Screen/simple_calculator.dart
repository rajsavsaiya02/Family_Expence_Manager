import 'package:fem/Utility/Colors.dart';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class Calculator extends StatefulWidget {
  const Calculator({Key? key}) : super(key: key);

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String equation = "";
  TextEditingController _displayTextController = TextEditingController();
  late final Function() onSubmitted;

  void calculate() {
    String equation = _displayTextController.text;
    double result;
    equation = equation.replaceAll('x','*');
    equation = equation.replaceAll('÷','/');
    // check if equation contains a percentage calculation
    if (equation.contains('%')) {
      List<String> parts = equation.split('%');
      double value = double.parse(parts[0]);
      result = value * 0.01;
      equation = result.toString();
      if (parts.length > 1) {
        result *= double.parse(parts[1]);
        equation = result.toString();
      }
    }
    // evaluate the arithmetic expression using the 'math_expressions' package
    try {
      Parser p = Parser();
      Expression exp = p.parse(equation);
      ContextModel cm = ContextModel();
      result = exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      result = 0.0;
    }

    if (result != null) {
      if (result % 1 == 0) {
        // if the result is a whole number, convert it to an integer
        int intResult = result.toInt();
        _displayTextController.text = intResult.toString();
      } else {
        _displayTextController.text = result.toString();
      }
    } else {
      _displayTextController.text = 'Error';
    }
  }

  void arithmeticButtonPressed(String text) {
    String currentText = _displayTextController.text;
    String newText = currentText + text;
    _displayTextController.text = newText;
  }
  void percentageButtonPressed() {
    String currentText = _displayTextController.text;
    String newText = currentText + '%';
    _displayTextController.text = newText;
  }
  void negativeButtonPressed() {
    String currentText = _displayTextController.text;
    if (currentText.startsWith('-')) {
      _displayTextController.text = currentText.substring(1);
    } else {
      _displayTextController.text = '-' + currentText;
    }
  }
  void eraseButtonPressed() {
    String currentText = _displayTextController.text;
    if (currentText.isNotEmpty) {
      String newText = currentText.substring(0, currentText.length - 1);
      _displayTextController.text = newText;
    }
  }

  void buttonPressed(String buttonText) {
    if (buttonText == 'C') {
      _displayTextController.text ="";
    }
    else if (buttonText == '⌫') {eraseButtonPressed();}
    else if (buttonText == '+/-') {negativeButtonPressed();}
    else if (buttonText == '%') {percentageButtonPressed();}
    else if (buttonText == '+' ||buttonText == '-' ||buttonText == 'x' ||buttonText == '÷' ) {arithmeticButtonPressed(buttonText);}
    else if (buttonText == '=') {calculate();}
    else if (buttonText == '.') {
      if (_displayTextController.text.contains('.')) {
          _displayTextController.text = _displayTextController.text;
      } else {
        _displayTextController.text += '.';
      }

    }
    else{_displayTextController.text += buttonText;}
  }

  Widget buildButton(String buttonText, Color buttonColor, Color textColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () => buttonPressed(buttonText),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              buttonText,
              style: TextStyle(
                fontSize: 24.0,
                color: textColor,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            fixedSize: Size.square(60),
            backgroundColor: buttonColor,
            shape: CircleBorder(eccentricity: 0.5),
            elevation: 5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primary,
        centerTitle: true,
        title: const Text('Calculator'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text(
                //   equation,
                //   style: TextStyle(fontSize: 48.0, fontWeight: FontWeight.w400),
                // ),
                TextField(
                  maxLines: 5,
                  minLines: 1,
                  controller: _displayTextController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                  ),
                  style: TextStyle(fontSize: 40),
                  textAlign: TextAlign.right,
                showCursor: true,
                readOnly: true,
                  onSubmitted: (_) => onSubmitted(),
                ),
                SizedBox(height: 4.0),
                Divider(
                  height: 1,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          //keyboard
          Row(
            children: [
              buildButton('C', Colors.white, Colors.black),
              buildButton('⌫', Colors.white, Colors.black),
              buildButton('%', Colors.white, Colors.black),
              buildButton('÷', Colors.grey.shade300, Colors.black),
            ],
          ),
          Row(
            children: [
              buildButton('7', Colors.white, Colors.black),
              buildButton('8', Colors.white, Colors.black),
              buildButton('9', Colors.white, Colors.black),
              buildButton('x', Colors.grey.shade300, Colors.black),
            ],
          ),
          Row(
            children: [
              buildButton('4', Colors.white, Colors.black),
              buildButton('5', Colors.white, Colors.black),
              buildButton('6', Colors.white, Colors.black),
              buildButton('-', Colors.grey.shade300, Colors.black),
            ],
          ),
          Row(
            children: [
              buildButton('1', Colors.white, Colors.black),
              buildButton('2', Colors.white, Colors.black),
              buildButton('3', Colors.white, Colors.black),
              buildButton('+', Colors.grey.shade300, Colors.black),
            ],
          ),
          Row(
            children: [
              buildButton('+/-', Colors.white, Colors.black),
              buildButton('0', Colors.white, Colors.black),
              buildButton('.', Colors.white, Colors.black),
              buildButton('=', primary, Colors.white),
            ],
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
