import 'package:fem/Database/FireStore_Database/Family_Profile/family_profile_manage.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Utility/Values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Utility/Colors.dart';
import '../../Utility/Strings.dart';
import 'create_group_screen.dart';
import 'family_group_room.dart';

final UserController userController = Get.put(UserController());
final GroupController gController = Get.put(GroupController());

class DefaultFamilyGroup extends StatefulWidget {
  const DefaultFamilyGroup({Key? key}) : super(key: key);

  @override
  State<DefaultFamilyGroup> createState() => _DefaultFamilyGroupState();
}


class _DefaultFamilyGroupState extends State<DefaultFamilyGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Family Group"),
        backgroundColor: primary,
        elevation: 5,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: ScreenWidth(context)/1.1,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imgIntroFour),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Text(
              'Connect With Your Family',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Connect with your loved ones and stay updated with the family group. \nFill out the form below to create a new family group or join exits one.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10,),
            Container(
              width: ScreenWidth(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  //   child: SizedBox(
                  //     width: double.infinity,
                  //     child: ElevatedButton(
                  //       style: ElevatedButton.styleFrom(
                  //         elevation: 5,
                  //         backgroundColor: primary,
                  //       ),
                  //       onPressed: () => {
                  //         Navigator.of(context).push(MaterialPageRoute(
                  //             builder: (context) => FamilyChatGroupScreen())),
                  //       },
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Text('Join Family',style: TextStyle(fontSize: 28,fontWeight: FontWeight.w600),),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          backgroundColor: primary,
                        ),
                        onPressed: () => {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CreateGroupScreen())),
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Create Family',style: TextStyle(fontSize: 28,fontWeight: FontWeight.w600),),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 36,),
          ],
        ),
      ),
    );
  }
}
