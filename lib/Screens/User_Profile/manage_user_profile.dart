import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fem/Database/FireStore_Database/User_Profile/user_datamodel.dart';
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

class ManageUserProfile extends StatefulWidget {
  const ManageUserProfile({Key? key}) : super(key: key);

  @override
  State<ManageUserProfile> createState() => _ManageUserProfileState();
}

class _ManageUserProfileState extends State<ManageUserProfile> {
  final UserController controller = Get.put(UserController());

  DateTime? _selectedDate;
  String uploadedFileURL = "";
  String dob ="";

  final RegExp mobileNumberPattern = RegExp(r'^(?:[+0]9)?\d{10}$');
  File? imageFile;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _currentBalanceController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dobController.text = DateFormat("dd-MM-yyyy").format(DateTime.parse(_selectedDate.toString()));
      });
    }
  }

  @override
  void initState() {
    controller.getUserData();
    _phoneNumberController.text = controller.phone == " " ? "" : controller.phone;
    _currentBalanceController.text = controller.currentBalance.toString();
    _nameController.text = controller.name.toString();
    print(controller.dob.toString());
    if(controller.dob.toString() != " "){
      var temp = controller.dob.toString() == " " ? "" : controller.dob.toString();
      if(temp.isNotEmpty) {
        _selectedDate = DateTime.parse(temp.toString());
        _dobController.text = DateFormat("dd/MM/yyyy").format(DateTime.parse(temp.toString()));
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('User Profile'),
        backgroundColor: primary,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              bool _taskDone = false;
              if( imageFile != null ){
                final storageReference = FirebaseStorage.instance.ref().child('UserProfileImage/${DateTime.now()}');
                final uploadTask = storageReference.putFile(imageFile!);
                await uploadTask.whenComplete(() => null);
                controller.deleteUserProfileImg(controller.photo_url);
                storageReference.getDownloadURL().then((fileURL) {
                    controller.updateUserData(context,"photoUrl", fileURL);
                });
                _taskDone = true;
              }
              if (_dobController.text.isNotEmpty && _dobController.text.toString() != controller.dob)
              {
                var _dob = _selectedDate!.toIso8601String();
                controller.updateUserData(context,"dob", _dob);
                _taskDone = true;
              }
              if (_phoneNumberController.text.isNotEmpty && _phoneNumberController.text != controller.phone && _phoneNumberController.text.length == 10) {
                var _phone = _phoneNumberController.text;
                controller.updateUserData(context,"phoneNumber", _phone);
                _taskDone = true;
              }
              if (_nameController.text.isNotEmpty && _nameController.text != controller.name)
              {
                var _name = _nameController.text.toString();
                controller.updateUserData(context,"name", _name);
                _taskDone = true;
              }
              if (_currentBalanceController.text.isNotEmpty && int.parse(_currentBalanceController.text) > 0 && _currentBalanceController.text != controller.currentBalance.toString()){
                controller.updateCurrentBalance(_currentBalanceController.text.toString());
                _taskDone = true;
              }
              if(_taskDone){
                Navigator.pop(context);
                showTopSnackBar(context, Icons.account_circle, "Account Detail", "Profile is updated");
                controller.getUserData();
                _taskDone = false;
              } else {
                showTopSnackBar(context, Icons.account_circle, "Account Detail", "Profile is not changed");
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.indigo.shade500,
          child: Column(
            children: [
              SizedBox(height: 16,),
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
              SizedBox(height: 16,),
              Text(controller.email,
                style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 16,),
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
                          height: 10,
                        ),
                        TextFormField(
                          controller: _currentBalanceController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Current Balance',
                            suffixIcon: Icon(Icons.currency_rupee_rounded),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter Full Name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          controller: _nameController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.text_fields),
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          initialValue:controller.accessCode,
                          readOnly: true,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Security Code',
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.content_copy,
                                size: 25,
                              ),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: controller.accessCode
                                        .toString()));
                                showTopTitleSnackBar(context,
                                    Icons.content_copy, "Security Code Copied");
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        // Use a TextFormField with an input formatter and validator to create the mobile number input field
                        TextFormField(
                          controller: _phoneNumberController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            hintText: 'Enter your phone number',
                            suffixIcon: Icon(Bootstrap.phone),
                            labelText: 'Phone Number (Optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextFormField(
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Date of Birth',
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today,
                                size: 20,
                              ),
                              onPressed: () {
                                _selectDate(context);
                              },
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                            readOnly: true,
                            controller: _dobController
                        ),
                        // const SizedBox(height: 16.0),
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
    }
  }

 Widget getImage() {
    if (imageFile == null && (controller.photo_url.isEmpty || controller.photo_url.toString() == " ")){
      return const Icon(Icons.account_circle, color: Colors.white, size: 180);
    } else if (controller.photo_url.isNotEmpty && imageFile == null){
      return ClipRRect(
        borderRadius: BorderRadius.circular(100.0),
        child: CachedNetworkImage(
              imageUrl: controller.photo_url,
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
