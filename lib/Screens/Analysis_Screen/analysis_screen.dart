import 'package:fem/Utility/Colors.dart';
import 'package:flutter/material.dart';
import 'Charts/expense_income_charts.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _selectedButtonIndex = 1;
  List<String> _buttonTitles = ['Custom', 'Today', 'Yesterday', 'Last 7 Days', 'This Month','Last Month','This Year','Last Year'];

  Widget _getSelectedWidget() {
    switch (_selectedButtonIndex) {
      case 0:
        return const ExpenseIncomeCharts(pageType: 'Custom');
      case 1:
        return const ExpenseIncomeCharts(pageType: "Today",);
      case 2:
        return const ExpenseIncomeCharts(pageType: "Yesterday",);
      case 3:
        return const ExpenseIncomeCharts(pageType: 'Last 7 Days');
      case 4:
        return const ExpenseIncomeCharts(pageType: 'This Month');
      case 5:
        return const ExpenseIncomeCharts(pageType: 'Last Month');
      case 6:
        return const ExpenseIncomeCharts(pageType: 'This Year');
      case 7:
        return const ExpenseIncomeCharts(pageType: 'Last Year');
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis'),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 5,
        // actions: [Padding(
        //   padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        //   child: PopupMenuButton<int>(
        //       itemBuilder: (context) => [
        //         PopupMenuItem(child: Text("Fliter"),),
        //       ]
        //   ),
        // ),],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10,vertical: 5.0),
            height: 60.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _buttonTitles.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _selectedButtonIndex == index ? Colors.indigo : Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0),
                      ),),
                    onPressed: () {
                      setState(() {
                        _selectedButtonIndex = index;
                      });
                    },
                    child: Text(_buttonTitles[index],
                      style: TextStyle(
                        color: _selectedButtonIndex == index ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _getSelectedWidget(),
          ),
        ],
      ),
    );
  }


  // old code
  //Container(
  //               margin: EdgeInsets.all(16),
  //               child: Column(
  //                 children: [
  //
  //                   Container(
  //                     height: 210,
  //                     decoration: BoxDecoration(
  //                       borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16),bottomRight: Radius.circular(16),),
  //                       color: Colors.white,
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.grey.withOpacity(0.5),
  //                           spreadRadius: 1,
  //                           blurRadius: 3,
  //                           offset: Offset(0, 2),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Center(
  //                       child: Container(
  //                         height: 300,
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                           children: [
  //                             Expanded(
  //                               child: SfCircularChart(
  //                                 series: <CircularSeries>[
  //                                   PieSeries<IncomeData, String>(
  //                                     dataSource: data1,
  //                                     xValueMapper: (IncomeData income, _) => income.category,
  //                                     yValueMapper: (IncomeData income, _) => income.amount,
  //                                     pointColorMapper: (IncomeData income, _) => income.color,
  //                                     enableTooltip: true,
  //                                     explode: true,
  //                                     explodeIndex: 0,
  //                                   ),
  //                                 ],
  //                                 tooltipBehavior: TooltipBehavior(
  //                                   enable: true,
  //                                   header: '',
  //                                   format: 'point.x : point.y%',
  //                                 ),
  //                                 legend: Legend(isVisible: false),
  //                               ),
  //                             ),
  //                             Expanded(
  //                               flex: 1,
  //                               child: ListView.builder(
  //                                 itemCount: data1.length,
  //                                 itemBuilder: (context, index) {
  //                                   return ListTile(
  //                                     horizontalTitleGap: 0,
  //                                     leading: Icon(
  //                                       Icons.circle,
  //                                       color: data1[index].color,
  //                                     ),
  //                                     title: Text(
  //                                       data1[index].category,
  //                                       style: TextStyle(
  //                                           fontWeight: FontWeight.bold,
  //                                           fontSize: 15
  //                                       ),
  //                                     ),
  //                                     subtitle: Text(
  //                                       '\$${data1[index].amount}',
  //                                       style: TextStyle(
  //                                         fontSize: 16,
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Divider(),
  //             Container(
  //               margin: EdgeInsets.all(16),
  //               child: Column(
  //                 children: [
  //                   Material(
  //                     elevation: 15,
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.only(topRight: Radius.circular(16),topLeft: Radius.circular(16)),
  //                     child: Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 20.0),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           Text("Income", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
  //                           ),
  //                           IconButton(icon: Icon(Icons.zoom_in_map, color: Colors.black,),
  //                             onPressed: () {
  //                               // Explore this chart
  //                               Navigator.of(context).push(MaterialPageRoute(builder: (context) => SubMenuScreen()));
  //                             },
  //                           ),
  //                         ],),
  //                     ),
  //                   ),
  //                   _buildChart(),
  //                 ],
  //               ),
  //             ),
  //             Divider(),

  //final List<IncomeData> data = [
  //     IncomeData('Salary', 35000),
  //     IncomeData('Investments', 10000),
  //     IncomeData('Gifts', 5000),
  //     IncomeData('Others', 2000),
  //   ];
  //
  //   final List<IncomeData> data1 = [
  //     IncomeData('Rent', 3500),
  //     IncomeData('Groceries', 120),
  //     IncomeData('Transportation', 500),
  //     IncomeData('Others', 2000),
  //   ];
  // Widget _buildHeader() {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     color: Colors.indigoAccent,
  //     child: FittedBox(
  //       fit: BoxFit.fill,
  //       child: Row(
  //         children: [
  //           IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 40,),
  //             onPressed: () {
  //               // Explore this chart
  //             },
  //           ),
  //           SizedBox(width: 15,),
  //           Column(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: [
  //               Text(
  //                 'Your Monthly Expenses',
  //                 style: TextStyle(
  //                   fontSize: 24,
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               SizedBox(height: 8),
  //               Text('Here\'s a breakdown of your monthly expenses.',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ],
  //           ),
  //           SizedBox(width: 15,),
  //           IconButton(icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 40,),
  //             onPressed: () {
  //               // Explore this chart
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  // Widget _buildChart() {
  //   return Container(
  //     height: 210,
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16),bottomRight: Radius.circular(16),),
  //       color: Colors.white,
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.5),
  //           spreadRadius: 1,
  //           blurRadius: 3,
  //           offset: Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Center(
  //       child: Container(
  //         height: 300,
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             Expanded(
  //               child: SfCircularChart(
  //                 series: <CircularSeries>[
  //                   PieSeries<IncomeData, String>(
  //                     dataSource: data,
  //                     xValueMapper: (IncomeData income, _) => income.category,
  //                     yValueMapper: (IncomeData income, _) => income.amount,
  //                     pointColorMapper: (IncomeData income, _) => income.color,
  //                     enableTooltip: true,
  //                     explode: true,
  //                     explodeIndex: 0,
  //                   ),
  //                 ],
  //                 tooltipBehavior: TooltipBehavior(
  //                   enable: true,
  //                   header: '',
  //                   format: 'point.x : point.y%',
  //                 ),
  //                 legend: Legend(isVisible: false),
  //               ),
  //             ),
  //             Expanded(
  //               flex: 1,
  //               child: ListView.builder(
  //                 itemCount: data.length,
  //                 itemBuilder: (context, index) {
  //                   return ListTile(
  //                     horizontalTitleGap: 0,
  //                     leading: Icon(
  //                       Icons.circle,
  //                       color: data[index].color,
  //                     ),
  //                     title: Text(
  //                       data[index].category,
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 15
  //                       ),
  //                     ),
  //                     subtitle: Text(
  //                       '\$${data[index].amount}',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // Widget _buildCategoryList() {
  //   return Container(
  //     margin: EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'Expenses by Category',
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  //         ),
  //         SizedBox(height: 16),
  //         _buildCategoryItem('Food', 200),
  //         _buildCategoryItem('Transportation', 100),
  //         _buildCategoryItem('Entertainment', 50),
  //       ],
  //     ),
  //   );
  // }
  // Widget _buildCategoryItem(String category, double amount) {
  //   return Row(
  //     children: [
  //       Text(
  //         category,
  //         style: TextStyle(fontSize: 16),
  //       ),
  //       Spacer(),
  //       Text(
  //         '\₹${amount.toStringAsFixed(2)}',
  //         style: TextStyle(fontSize: 16),
  //       ),
  //     ],
  //   );
  // }
}

// old class
// class IncomeData {
//   final String category;
//   final double amount;
//   final Color color;
//
//   IncomeData(this.category, this.amount)
//       : color = Colors.primaries[category.length % Colors.primaries.length];
// }