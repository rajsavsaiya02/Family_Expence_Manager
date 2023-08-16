import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileImageUploadScreen extends StatefulWidget {
  @override
  _ProfileImageUploadScreenState createState() =>
      _ProfileImageUploadScreenState();
}

class _ProfileImageUploadScreenState extends State<ProfileImageUploadScreen> {
  File? _imageFile;
  bool _isImageSelected = false;

  final picker = ImagePicker();

  Future getImageFromGallery() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    _cropImage(pickedFile!.path);
  }

  Future getImageFromCamera() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    _cropImage(pickedFile!.path);
  }

  Future<void> _cropImage(filePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          IOSUiSettings(
            title: 'Cropper',
          )
        ]);
    if (croppedFile != null) {
      setState(() {
        _imageFile = File(croppedFile.path);
        _isImageSelected = true;
      });
    }
  }

  Future<String> uploadImageToFirebase() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference =
    storage.ref().child("profile_images/${DateTime.now()}");
    UploadTask uploadTask = reference.putFile(File(_imageFile!.path.toString()));
    TaskSnapshot downloadUrl = (await uploadTask);
    return await downloadUrl.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isImageSelected
                ? ClipOval(child: Image.file(File(_imageFile!.path.toString()), width: 150, height: 150, fit: BoxFit.cover,),)
                : Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[300]), child: Icon(Icons.person, size: 100),),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: getImageFromCamera,
                  child: Text("Camera"),
                ),
                ElevatedButton(
                  onPressed: getImageFromGallery,
                  child: Text("Gallery"),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_isImageSelected) {
                  String imageUrl = await uploadImageToFirebase();
                  print("Image uploaded to Firebase: $imageUrl");
                } else {
                  print("No image selected");
                }
              },
              child: Text("Save"),
            ),
          ],
        );
  }
}