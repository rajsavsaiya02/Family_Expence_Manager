import 'package:fem/Screens/Tools_Screen/Tools/Credit_Card_Calculator_Screen/credit_card_calculator.dart';
import 'package:fem/Screens/Tools_Screen/Tools/Tax_Calculator_Screen/tax_calculator.dart';
import 'package:flutter/material.dart';
import '../../Utility/Colors.dart';
import '../../Utility/Strings.dart';
import 'Tools/Discount_Calculator_Screen/discount_calculator.dart';
import 'Tools/Interest_Calculator_Screen/interest_calculator.dart';
import 'Tools/Simple_Calculator_Screen/simple_calculator.dart';
import 'Tools/EMI_Calculator_Screen/emi_calculator.dart';
import 'Tools/TVM_Calculator_Screen/tvm_calculator.dart';
import 'Tools/Tip_Split_Calculator_Screen/tip_and_split_calculator.dart';

class ToolsBox extends StatelessWidget {
  const ToolsBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconBoxSizeWidth = MediaQuery.of(context).size.width/5;
    final double IconBoxSizeHeight = 110;
    return Scaffold(
      appBar: AppBar(
        title: Text("Financial Tools", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 26),),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
          Navigator.of(context).pop();
          },),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FittedBox(child: Image.asset(imgCreditCardCalculatorIcon, width:IconBoxSizeWidth, height: IconBoxSizeHeight,)),
                              FittedBox(child: Text("Credit-Card Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreditCardPayoffCalculator()));
                      },
                    ),
                  ),
                  //currency converter
                  // Expanded(
                  //   child: InkWell(
                  //     child: Container(
                  //       decoration: const BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.only(
                  //             topLeft: Radius.circular(20),
                  //             bottomRight: Radius.circular(20),
                  //           ),
                  //           boxShadow: [
                  //             BoxShadow(
                  //             color: Colors.grey,
                  //             blurRadius: 5,
                  //           ),
                  //           ]
                  //       ),
                  //       child: Padding(
                  //         padding: EdgeInsets.all(8.0),
                  //         child: Column(
                  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //           children: [
                  //             FittedBox(child: Image.asset(imgCurrencyIcon, width:IconBoxSizeWidth, height: IconBoxSizeHeight,)),
                  //             FittedBox(child: Text("Currency Converter", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //     onTap: () {
                  //       Navigator.of(context).push(MaterialPageRoute(builder: (context) => CurrencyConverter()));
                  //     },
                  //   ),
                  // ),//Currency Converter
                  SizedBox(width: 20,),
                  Expanded(
                    child: InkWell(
                      child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5,
                            ),
                          ]
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FittedBox(child: Image.asset(imgEMICalculatorIcon, width:IconBoxSizeWidth, height: IconBoxSizeHeight,)),
                            FittedBox(child: Text("EMI & Loan Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)),
                          ],
                        ),
                      ),
                    ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => EMICal()));
                      },
                ),
                  ),//EMI Calculator
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FittedBox(child: Image.asset(imgSimpleCalculatorIcon, width:IconBoxSizeWidth, height: IconBoxSizeHeight,)),
                              FittedBox(child: Text("Simple Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Calculator()));
                      },
                    ),
                  ),
                  SizedBox(width: 20,),
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FittedBox(child: Image.asset(imgInterestCalculatorIcon, width:IconBoxSizeWidth, height: IconBoxSizeHeight,)),
                              FittedBox(child: Text("Interest Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => InterestCalculator()));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FittedBox(child: Image.asset(imgDiscountCalculatorIcon, width:IconBoxSizeWidth, height: IconBoxSizeHeight,)),
                              FittedBox(child: Text("Discount Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => DiscountCalculator()));
                      },
                    ),
                  ),
                  SizedBox(width: 20,),
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FittedBox(child: Image.asset(imgTipAndSplitCalculatorIcon, width:IconBoxSizeWidth, height: IconBoxSizeHeight,)),
                              FittedBox(child: Text("Tip & Split Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => TipAndSplitCalculator()));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FittedBox(child: Image.asset(imgTaxCalculatorIcon, width:IconBoxSizeWidth, height: IconBoxSizeHeight,)),
                              FittedBox(child: Text("Tax Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaxCalculator()));
                      },
                    ),
                  ),
                  SizedBox(width: 20,),
                  Expanded(
                    child: InkWell(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                              ),
                            ]
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FittedBox(child: Image.asset(imgTVMCalculatorIcon, width:IconBoxSizeWidth, height: IconBoxSizeHeight,)),
                              FittedBox(child: Text("TVM Calculator", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),)),
                            ],
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => TVMCalculator()));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
