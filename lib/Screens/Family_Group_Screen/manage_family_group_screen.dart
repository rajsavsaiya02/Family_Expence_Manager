import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fem/Database/FireStore_Database/Family_Profile/family_profile_manage.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
import 'package:fem/Screens/Family_Group_Screen/family_group_room.dart';
import 'package:fem/Utility/Functions.dart';
import 'package:fem/Utility/Values.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Utility/Colors.dart';

class ManageFamilyGroupScreen extends StatefulWidget {
  const ManageFamilyGroupScreen({Key? key}) : super(key: key);

  @override
  State<ManageFamilyGroupScreen> createState() => _ManageFamilyGroupScreenState();
}

class _ManageFamilyGroupScreenState extends State<ManageFamilyGroupScreen> {
  final GroupController controller = Get.put(GroupController());

  String uploadedFileURL = "";
  String _newGroupName = "";
  File? imageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  final _nameKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    controller.getFamilyGroupData();
    _nameController.text = controller.familyName.value.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Family Profile'),
        backgroundColor: primary,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: ScreenWidth(context),
          color: Colors.indigo.shade500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                  children: [
                SizedBox(height: 16,),
                SizedBox(
                    width: 250,
                    height: 250,
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
                SizedBox(height: 16,),
                Text(controller.familyName.value.toString(),
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(height: 20,),
                ElevatedButton(
                  child: const Text('Change Family Name'),
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: primary,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 40.0, right: 40.0),
                  ),
                  onPressed: (){
                    showDialog(
                        context: context,
                        builder: (context) => StatefulBuilder(builder: (context, setState) =>
                            AlertDialog(
                          title: Center(child: Text("Update Family Profile")),
                          content: Container(
                            height: 65,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                TextFormField(
                                  key: _nameKey,
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    labelText: 'Enter Group Name',
                                    suffixIcon: Icon(
                                      Icons.text_fields,
                                      size: 20,
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a group name';
                                      }
                                      return null;
                                    },
                                ),
                              ],
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
                                    _nameController.text = controller.familyName.value.toString();
                                    Navigator.of(context).pop();
                                  },
                                ),
                                OutlinedButton(
                                  child: Text("Save Change", style: TextStyle(color: Colors.green),),
                                  onPressed: () async {
                                    if(_nameKey.currentState!.isValid){
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const Center(child: CircularProgressIndicator());
                                        },
                                      );
                                      controller.updateGroupData("familyName", _nameController.text.trim());
                                      controller.familyName.value = _nameController.text.trim().toString();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      showTopTitleSnackBar(context, Icons.groups, "Family Profile Updated");
                                    }
                                    else {
                                      showTopSnackBar(context, Icons.groups, "Update Profile", "Please enter a group name");
                                    }
                                  },
                                ),
                              ],
                            )
                          ],
                        )));
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  child: const Text('Change Group Password'),
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: primary,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10.0, left: 24.0, right: 24.0),
                  ),
                  onPressed: (){
                    showDialog(
                        context: context,
                        builder: (context) => StatefulBuilder(builder: (context, setState) =>
                            AlertDialog(
                              title: Center(child: Text("Update Family Profile")),
                              content: Container(
                                height: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    TextFormField(
                                      controller: _currentPassword,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'Current Password',
                                        prefixIcon: Icon(
                                          Icons.key,
                                          size: 20,
                                        ),
                                      ),
                                      keyboardType: TextInputType.text,
                                    ),
                                    SizedBox(height: 16.0),
                                    TextFormField(
                                      controller: _newPassword,
                                      decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        labelText: 'New Password',
                                        prefixIcon: Icon(
                                          Icons.key,
                                          size: 20,
                                        ),
                                      ),
                                      keyboardType: TextInputType.text,
                                    ),
                                  ],
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
                                      child: Text("Save Change", style: TextStyle(color: Colors.green),),
                                      onPressed: () async {
                                        if(_currentPassword.text.isNotEmpty && _currentPassword.text == controller.pwd.value.toString())
                                        {
                                          if(_newPassword.text.isNotEmpty){
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return const Center(child: CircularProgressIndicator());
                                              },
                                            );
                                            controller.updateGroupData("password", _newPassword.text.trim());
                                            controller.pwd.value = _newPassword.text;
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            showTopTitleSnackBar(context, Icons.groups, "Family Profile Updated");
                                          } else {
                                            showTopSnackBar(context, Icons.groups, "Update Profile", "Please enter a new password");
                                          }
                                        }
                                        else {
                                          showTopSnackBar(context, Icons.groups, "Update Profile", "Password is not match");
                                        }
                                      },
                                    ),
                                  ],
                                )
                              ],
                            )));
                  },
                ),
                SizedBox(height: 16,),
              ]),
              Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    Card(
                      elevation: 5,
                      shape: const StadiumBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.person, size: 48),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Admin of Family Group",
                                          style: const TextStyle(
                                            color: Colors.black38,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        controller.adminName.value.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Card(
                      elevation: 5,
                      shape: const StadiumBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_month_outlined,
                                      size: 38),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "Date of Group Creation",
                                          style: const TextStyle(
                                            color: Colors.black38,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        controller.groupCreateDate.isNotEmpty
                                            ? controller.groupCreateDate.toString() != " "
                                            ? DateFormat("MMMM dd, yyyy").format(DateTime.parse(controller.groupCreateDate.value.toString()))
                                            : "None"
                                            : "None",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              )),
            ],
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );
      if( imageFile != null ){
            final storageReference = FirebaseStorage.instance.ref().child('FamilyProfileImage/${DateTime.now()}');
            final uploadTask = storageReference.putFile(imageFile!);
            await uploadTask.whenComplete(() => null);
            controller.deleteGroupProfileImg(controller.profileImg.value.toString());
            storageReference.getDownloadURL().then((fileURL) {
              controller.updateGroupData("profileImg", fileURL);
              controller.profileImg.value = fileURL;
            });
            controller.getFamilyGroupData();
      }
      Navigator.of(context).pop();
    }
  }

  Widget getImage() {
    if (imageFile == null && (controller.profileImg.value.isEmpty || controller.profileImg.value.toString() == " ")){
      return const Icon(Icons.account_circle, color: Colors.white, size: 250);
    } else if (controller.profileImg.value.isNotEmpty && imageFile == null){
      return ClipRRect(
        borderRadius: BorderRadius.circular(150.0),
        child: CachedNetworkImage(
          imageUrl: controller.profileImg.value.toString(),
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
        borderRadius: BorderRadius.circular(150.0),
        child: Image.file(imageFile!, height: 250, width: 250, fit: BoxFit.fill,),
      );
    }
  }
}
