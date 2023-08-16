import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/Credentials/familyGroupKey.dart';
import 'package:fem/Database/FireStore_Database/Family_Profile/family_profile_manage.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Screens/Analysis_Screen/family_expense_chart.dart';
import 'package:fem/Screens/Data_Input_Screen/family_expense_input_screen.dart';
import 'package:fem/Screens/Family_Group_Screen/manage_family_group_screen.dart';
import 'package:fem/Screens/Family_Group_Screen/view_transaction_screen.dart';
import 'package:fem/Screens/Home/home.dart';
import 'package:fem/Utility/Colors.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'one_to_one_user_chat_screen.dart';

class FamilyGroupRoomScreen extends StatefulWidget {
  const FamilyGroupRoomScreen({Key? key}) : super(key: key);

  @override
  State<FamilyGroupRoomScreen> createState() => _FamilyGroupRoomScreenState();
}

class _FamilyGroupRoomScreenState extends State<FamilyGroupRoomScreen> {
  final GroupController groupController = Get.put(GroupController());
  final UserController userController = Get.put(UserController());
  final FamilyGroupKey gValue = Get.put(FamilyGroupKey());
  final commanValue cValue = Get.put(commanValue());
  final fireStore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _groupNameKey = GlobalKey<FormFieldState>();
  final _addmemberEmail = TextEditingController();
  final _addmemberCode = TextEditingController();
  final _groupPassword = TextEditingController();
  final _groupNameEdit = TextEditingController();
  List<dynamic> userList = [];
  File? imageFile;

  //local variables
  @override
  void initState() {
    groupController.getFamilyGroupData();
    _groupNameEdit.text = groupController.familyName.value.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: primary,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => FamilyExpenseInputScreen()));
          },
        ),
      ),
      appBar: AppBar(
        leadingWidth: 30,
        title: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  (groupController.profileImg.value.toString() != "")
                      ? CachedNetworkImage(
                          imageUrl: groupController.profileImg.value.toString(),
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            radius: 20,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.error, color: Colors.white),
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Icon(Icons.groups_rounded,
                              color: Colors.indigo.shade900, size: 30),
                        ),
                  SizedBox(width: 10),
                  Container(
                    width: ScreenWidth(context)/2.3, // Fixed container width
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        groupController.familyName.value.toString(),
                        style: TextStyle(fontSize: 20),
                        overflow: TextOverflow.ellipsis, // Truncate text with ellipsis if not scrolled
                      ),
                    ),
                  ),

                  // Center(
                  //   child: Text(
                  //     groupController.familyName.value.toString(),
                  //     overflow: TextOverflow.ellipsis,
                  //     style: TextStyle(fontSize: 20),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
        backgroundColor: primary,
        elevation: 5,
        actions: [
          IconButton(padding: EdgeInsets.zero,icon: Icon(Icons.insert_chart_outlined_outlined, color: Colors.white,size: 30,),
            onPressed: () => {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => FamilyAnalysisScreen()))
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 0,top: 0,bottom: 0, right: 15),
            child: PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                if (groupController.admin.value.toString() == "Admin") ...[
                  const PopupMenuItem<String>(
                    height: 40,
                    value: 'Manage Profile',
                    child: Text('Manage Profile'),
                  ),
                  const PopupMenuItem<String>(
                    height: 40,
                    value: 'Add Member',
                    child: Text('Add Member'),
                  ),
                ],
                const PopupMenuItem<String>(
                  height: 40,
                  value: 'View Transactions',
                  child: Text('View Transactions'),
                ),
                const PopupMenuItem<String>(
                  height: 40,
                  value: 'Leave Group',
                  child: Text(
                    'Leave Group',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == "Add Member") {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Add Member", textAlign: TextAlign.center,),
                        content: Form(
                          key: _formKey,
                          child: Container(
                            height: 200,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _addmemberEmail,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter a user email id';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'User Email ID',
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _addmemberCode,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter a user security code';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'User Security Code',
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                TextFormField(
                                  controller: _groupPassword,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter a group password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Group Password',
                                    border: OutlineInputBorder(
                                      borderRadius:
                                      BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              OutlinedButton(
                                child: Text("Add Member", style: TextStyle(color: Colors.green),),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (groupController.pwd.value.toString() == _groupPassword.text.toString()) {
                                      QuerySnapshot snapshot = await fireStore.collection("users").where("emailAddress", isEqualTo: encryptData(_addmemberEmail.text.toString(), _addmemberCode.text.toString())).get();
                                      if (snapshot.docs.isNotEmpty) {
                                        String userKey = _addmemberCode.text.toString();
                                        String docId = snapshot.docs.first.id.toString();
                                        await fireStore.collection("family").doc(groupController.familyid.toString()).update({"member": FieldValue.arrayUnion([encryptData(docId, groupController.groupKey.value.toString())])});
                                        await fireStore.collection("users").doc(docId).update({"familyId": encryptData(groupController.familyid, userKey),});
                                        showTopTitleSnackBar(context, Icons.groups_2, "Member Added");
                                      } else {
                                        Navigator.pop(context);
                                        showTopTitleSnackBar(context,
                                            Icons.message, "User Not Found");
                                      }
                                    } else {
                                      Navigator.pop(context);
                                      showTopTitleSnackBar(
                                          context,
                                          Icons.message,
                                          "Wrong Password, Try Again!");
                                    }
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  );
                }
                else if (value == "Manage Profile") {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ManageFamilyGroupScreen()));
                }
                else if (value == "View Transactions") {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => FamilyTransactionScreen()));
                }
                // else if (value == "Remove Member"){
                //   await fireStore.collection("users").doc(cValue.currentUser.value.uid.toString()).update({"familyId": encryptData(" ", cValue.currentUser.value.key),});
                //   showTopTitleSnackBar(context, Icons.message, "Successfully Leaved Group");
                //   Navigator.pop(context);
                //   userController.getUserData();
                // }
                else if (value == "Leave Group") {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Leave Group", textAlign: TextAlign.center, style: TextStyle(color: Colors.red,),),
                        content:
                        Text("Do you really want to leave this group?"),
                        actions: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton(
                                child: Text("No", style: TextStyle(color: Colors.black),),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              OutlinedButton(
                                child: Text("Yes", style: TextStyle(color: Colors.black),),
                                onPressed: () async {
                                  await fireStore.collection("users").doc(cValue.currentUser.value.uid.toString()).update({"familyId": encryptData(" ", cValue.currentUser.value.key),}).then((value) {
                                    showTopTitleSnackBar(context, Icons.message, "Successfully Leaved Group");
                                  });
                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Home()),(route) => false);
                                  userController.getUserData();
                                },
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  );
                }
              },
              child: Container(
                width: 25,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  Icons.more_vert,
                  size: 25,
                ),
              ),
            ),
          )
        ],
      ),
      body: Obx(() => FutureBuilder<List<DocumentSnapshot>>(
        future: getUsers(),
        builder: (BuildContext context,
            AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var users = snapshot.data;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ListView.separated(
              itemCount: users!.length,
              itemBuilder: (BuildContext context, int index) {
                final userKey = decryptData(users[index].get("accessCode").toString(), users[index].id.substring(0, 16).toString());
                String name = decryptData(users[index].get('name').toString(), userKey);
                String imageUrl = decryptData(users[index].get('photoUrl'), userKey);
                if(users[index].id.toString() == groupController.adminId.toString()){
                  groupController.adminName.value = name.toString();
                }
                // var chatID = chatRoomId(cValue.currentUser.value.uid, users[index].get('id').toString());
                return ListTile(
                  leading: (imageUrl.toString() != " " && imageUrl.toString().isNotEmpty)
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: imageUrl,
                          imageBuilder: (context, imageProvider) => CircleAvatar(
                            backgroundColor: Colors.indigo.shade900,
                            radius: 30,
                            backgroundImage: imageProvider,
                          ),
                          placeholder: (context, url) => CircleAvatar(
                            backgroundColor: Colors.indigo.shade900,
                            radius: 30,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                          errorWidget: (context, url, error) => CircleAvatar(
                            backgroundColor: Colors.indigo.shade900,
                            radius: 30,
                            child: Icon(
                              Icons.error,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.indigo.shade900,
                          radius: 30,
                          child: Icon(Icons.account_circle,
                              color: Colors.white, size: 55),
                        ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 30),overflow: TextOverflow.ellipsis,),
                      groupController.adminName.value != name
                          ? Text("Member", style: TextStyle(fontWeight: FontWeight.w400,fontSize: 14))
                          : Text("Admin", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14)),
                    ],
                  ),
                  onTap: () {
                    var RoomID = chatRoomId(cValue.currentUser.value.uid, users[index].get('id').toString());//encryptData(chatRoomId(cValue.currentUser.value.uid, users[index].get('id').toString()),cValue.currentUser.value.fkey);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => OneToOneChatScreen(name,imageUrl,RoomID)));
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) => Divider(),
            ),
          );
        },
      ),),
    );
  }

  String chatRoomId (String user1, String user2){
    if( user1[0].toLowerCase().codeUnits[0]>user2[0].toLowerCase().codeUnits[0]){
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Future<List<DocumentSnapshot>> getUsers() async {
    List<Future<DocumentSnapshot>> futures = [];
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    for (String docId in groupController.memberList.value.toList()) {
      futures.add(firestore.collection('users').doc(docId).get());
    }
    List<DocumentSnapshot> results = await Future.wait(futures);
    return results.where((snapshot) => snapshot.exists).toList();
  }


  final picker = ImagePicker();

  void showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Card(
          child: Container(
            width: ScreenWidth(context),
            height: ScreenHeight(context) / 5.2,
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: InkWell(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.image,
                            size: 60.0,
                          ),
                          SizedBox(
                            height: 12.0,
                          ),
                          Text(
                            "Gallery",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )
                        ],
                      ),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.pop(context);
                      },
                    )),
                Expanded(
                    child: InkWell(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.camera_alt,
                            size: 60.0,
                          ),
                          SizedBox(
                            height: 12.0,
                          ),
                          Text(
                            "Camera",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          )
                        ],
                      ),
                      onTap: () {
                        _imgFromCamera();
                        Navigator.pop(context);
                      },
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  _imgFromGallery() async {
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
  }

  _imgFromCamera() async {
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 50)
        .then((value) {
      if (value != null) {
        _cropImage(File(value.path));
      }
    });
  }

  _cropImage(File imgFile) async {
    final croppedFile = await ImageCropper().cropImage(
        sourcePath: imgFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: "Image Cropper",
              toolbarColor: primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(title: "Image Cropper")
        ]);
    if (croppedFile != null) {
      imageCache.clear();
      setState(() {
        imageFile = File(croppedFile.path);
      });
    }
  }

  Widget getImage() {
    if (imageFile == null && (groupController.profileImg.value.isEmpty || groupController.profileImg.value.toString() == " ")){
      return const Icon(Icons.account_circle, color: Colors.white, size: 180);
    } else if (groupController.profileImg.value.isNotEmpty && imageFile == null){
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: CachedNetworkImage(
          imageUrl: groupController.profileImg.value,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                )
            ),
          ),
          progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(value: downloadProgress.progress),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: Image.file(imageFile!, height: 180, width: 180, fit: BoxFit.fill,),
      );
    }
  }
}