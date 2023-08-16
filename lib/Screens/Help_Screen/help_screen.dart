import 'package:flutter/material.dart';

import '../../Utility/Colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(
                  'Frequently Asked Questions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),]
              ),
              const SizedBox(height: 16.0),
              _buildFAQ(context, 'How do I create a new transaction?', 'To create a new transaction, tap the "+" button in the bottom right corner of the screen.'),
              _buildFAQ(context, 'How do I edit a transaction?', 'To edit a transaction, long-press on the transaction in the list and select "Edit" from the context menu.'),
              _buildFAQ(context, 'How do I delete a transaction?', 'To delete a transaction, swipe left on the transaction in the list and tap the "Delete" button.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQ(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(answer),
        ),
      ],
    );
  }
}