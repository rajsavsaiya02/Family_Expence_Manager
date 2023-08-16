import 'package:flutter/material.dart';

import '../../Utility/Colors.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  double _fontScale = 1.0;
  String _selectedLanguage = 'English';

  List<String> _supportedLanguages = ['English', 'Spanish', 'French', 'German'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        backgroundColor: primary,
        elevation: 5,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('Enable Dark Mode'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),
          ListTile(
            title: Text('Language'),
            trailing: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButton<String>(
                value: _selectedLanguage,
                items: _supportedLanguages
                    .map((language) => DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
            ),
          ),
          ListTile(
            title: Text('Delete Account'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Account'),
                    content: Text('Are you sure you want to delete your account?'),
                    actions: [
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () {
                          // var user = firebase.auth().getUser(uid);
                          // firebase.auth().currentUser.delete()

                          // Delete account and navigate to login screen
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}