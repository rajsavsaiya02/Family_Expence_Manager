import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fem/Database/Credentials/commanValue.dart';
import 'package:fem/Database/Credentials/familyGroupKey.dart';
import 'package:fem/Database/FireStore_Database/Family_Profile/family_profile_manage.dart';
import 'package:fem/Database/FireStore_Database/User_Analysis/analysis_datamodel.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_profile_manage.dart';
import 'package:fem/Screens/Home/home.dart';
import 'package:fem/Utility/Colors.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final commanValue cValue = Get.put(commanValue());
  final UserController userController = Get.put(UserController());
  final FamilyGroupKey gValue = Get.put(FamilyGroupKey());
  final _formKey = GlobalKey<FormState>();
  File? imageFile;
  String _groupName = "";
  String _password = "";
  String _confirmPassword = "";
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _showConfirmPassword = !_showConfirmPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Create Family Group"),
        backgroundColor: primary,
        elevation: 5,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Column(
              children: [
                SizedBox(height: 20),
                SizedBox(
                    width: 190,
                    height: 190,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          getImage(),
                          ElevatedButton(
                            onPressed: () async {
                              Map<Permission, PermissionStatus> statuses = await [
                                Permission.storage,
                                Permission.camera,
                              ].request();
                              if (statuses[Permission.storage]!.isGranted &&
                                  statuses[Permission.camera]!.isGranted) {
                                showImagePicker(context);
                              } else {
                                showTopTitleSnackBar(context, Icons.error_outline,
                                    "Permission Denied");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: const Size(40, 40),
                                backgroundColor: Colors.white,
                                shape: const CircleBorder(),
                                elevation: 15,
                                splashFactory: InkSplash.splashFactory,
                                foregroundColor: Colors.black),
                            child: Icon(
                              Icons.add_a_photo,
                              color: primary,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.text_fields),
                      labelText: 'Group Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a group name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _groupName = value;
                    },
                  ),
                ),
                SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.key),
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    obscureText: !_showPassword,
                    onChanged: (value) {
                      _password = value;
                    },
                    validator: (value) {
                      if (value!.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.key),
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: _toggleConfirmPasswordVisibility,
                      ),
                    ),
                    obscureText: !_showConfirmPassword,
                    onChanged: (value) {
                      _confirmPassword = value;
                    },
                    validator: (value) {
                      if (value != _password) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 5,
                        backgroundColor: primary,
                      ),
                      onPressed: () async {
                        String photoUrl = " ";
                        if (_formKey.currentState!.validate()) {
                          final documentReference = FirebaseFirestore.instance.collection('family').doc();
                          String uid = documentReference.id;
                          String title = _groupName;
                          String pwd = _password;
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const Center(child: CircularProgressIndicator());
                            },
                          );
                          final storageReference = FirebaseStorage.instance.ref().child('FamilyProfileImage/${DateTime.now()}');
                          if(imageFile != null) {
                            final uploadTask = storageReference.putFile(imageFile!);
                            final snapshot = await uploadTask.whenComplete(() {});
                            final downloadUrl = await snapshot.ref.getDownloadURL();
                            setState(() {
                              photoUrl = downloadUrl;
                            });
                          }
                          var keyString = uid.substring(0, 16);
                          //access code
                          var uuid = Uuid();
                          var accessCode = uuid.v4().substring(0, 16);
                          var temp = accessCode;
                          accessCode = encryptData(accessCode, keyString);
                          keyString = temp;
                          await FirebaseFirestore.instance.collection("family").doc(uid).set({
                            "uid": uid.toString(),
                            "admin": encryptData(cValue.currentUser.value.uid.toString(), keyString),
                            "member": [encryptData(cValue.currentUser.value.uid.toString(), keyString),],
                            "familyName":encryptData(title.toString(), keyString),
                            "groupCreateDate":encryptData(DateTime.now().toIso8601String(), keyString),
                            "profileImg": encryptData(photoUrl.toString(), keyString),
                            "password": encryptData(pwd.toString(), keyString),
                            "accessCode": accessCode,
                          }).then((value) async {
                              await FirebaseFirestore.instance.collection("users").doc(cValue.currentUser.value.uid)
                                  .update({
                                "familyId" : encryptData(uid, cValue.currentUser.value.key),
                                "memberStatus" : encryptData("admin", cValue.currentUser.value.key),
                              });
                              gValue.familyKey.value.fid = uid.toString();
                              gValue.familyKey.value.key = keyString.toString();
                              gValue.saveToStorage();
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Home()),(route) => false);
                          });
                          showTopTitleSnackBar(context, Icons.groups, "Family Group Created");
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Create',style: TextStyle(fontSize: 28,fontWeight: FontWeight.w600),),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
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
    if (imageFile == null){
      return ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          height: 200,
          width: 300,
          decoration: BoxDecoration(
            color: primary,
          border: Border.all(),
          borderRadius: BorderRadius.circular(100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.groups, size: 140, color: Colors.white,),
          ),
        ),);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: Image.file(imageFile!, height: 180, width: 180, fit: BoxFit.fill,),
      );
    }
  }
}