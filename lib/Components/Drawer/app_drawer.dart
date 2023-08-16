import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_profile_manage.dart';
import 'package:fem/Screens/Help_Screen/help_screen.dart';
import 'package:fem/Screens/Home/home.dart';
import 'package:fem/Screens/Tools_Screen/tools_screen.dart';
import 'package:fem/Screens/UserSignIn/user_sign_in.dart';
import 'package:fem/Screens/User_Profile/manage_user_profile.dart';
import 'package:fem/Screens/User_Profile/user_profile.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Reminder/reminder.dart';

var cValue = Get.put(commanValue());

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({Key? key}) : super(key: key);
  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  final UserController controller = Get.put(UserController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
        children: [
          Stack(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.indigoAccent,
                      Colors.lightBlue,
                    ],
                  ),
                ),
                accountName: Text(controller.name.toString(), style: const TextStyle(fontSize: 22)),
                accountEmail: Text(controller.email.toString(), style: const TextStyle(fontSize: 16)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.blue[900],
                  child: Text(controller.f_letter.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 35)),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 10,
                //give the values according to your requirement
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ManageUserProfile()));
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(20, 20),
                    shape: const CircleBorder(),
                    elevation: 2,
                  ),
                  child: const Icon(Icons.edit_outlined),
                ),
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Home()),
                      (Route<dynamic> route) => false)
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () => {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UserProfileScreen()))
            },
          ),
          ListTile(
            leading: const Icon(Icons.punch_clock),
            title: const Text("Reminder"),
            onTap: () => {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => RemindersScreen()))
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Tools'),
            onTap: () => {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const ToolsBox()))
            },
          ),
          ExpansionTile(
            title: const Text('Setting'),
            leading: const Icon(Icons.settings),
            children: [
              ListTile(
                leading: Icon(Icons.password_sharp, color: Colors.yellow.shade800,),
                title: const Text('Change Password', style: TextStyle(color: Colors.black87, letterSpacing: 1),),
                onTap: () {
                  var forgotEmailId = cValue.currentUser.value.email.toString();
                  if (cValue.currentUser.value.email.isNotEmpty) {
                    showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Reset Password?'),
                          content: Text('Are you sure you want to reset your password?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                await FirebaseAuth.instance.sendPasswordResetEmail(email: cValue.currentUser.value.email.toString())
                                    .then((value) {
                                  Navigator.of(context).pop(false);
                                  showTopSnackBar(context, Icons.key, "Password Changing Processed", "Check your email to change password!");
                                }).onError((error, stackTrace) {
                                  print("Error (User Reset Password): ${error.toString()}");
                                });
                              },
                              child: Text('Reset'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_forever, color: Colors.red.shade900,),
                title: const Text("Delete Account"),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Account'),
                        content: Container(
                          height: 100,
                          child: Column(
                            children: [
                              Text('Are you sure you want to delete your account?\n'),
                              Text("\"once you delete your account it not recoverable!\"", style: TextStyle(color: Colors.red.shade900),),
                            ],
                          ),
                        ),
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
                              var user = FirebaseAuth.instance.currentUser;
                              user!.delete().whenComplete(() {
                              Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const UserSignIn()),
                              (Route<dynamic> route) => false);
                              });
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
          ListTile(
              title: const Text('Help'),
              leading: const Icon(Icons.help),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HelpScreen()));
              }),
          const Spacer(),
          const Divider(
            thickness: 1,
          ),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app,
              size: 24,
              color: Colors.redAccent,
            ),
            title: const Text(
              "Log Out",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w400),
            ),
            onTap: () {
              userSignOut(context);
            }
          ),
        ],
    );
  }
}
