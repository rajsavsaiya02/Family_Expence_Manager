import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'commanValueModel.dart';

class commanValue extends GetxController {
  // User Details
  var currentUser = commanValueModel().obs;

  Future<void> loadFromStorage() async {
    // final appDocumentDir = await getApplicationDocumentsDirectory();
    // Hive.initFlutter(appDocumentDir.path);
    final box = await Hive.openBox('userBox');
    final user = box.get('currentUser');
    if (user != null) {
      currentUser.value = user;
    }
  }

  Future<void> saveToStorage() async {
    // final appDocumentDir = await getApplicationDocumentsDirectory();
    // Hive.initFlutter(appDocumentDir.path);

    final box = await Hive.openBox('userBox');
    await box.put('currentUser', currentUser.value);
  }
}

// class commanValue extends GetxController{
//   // User Details
//   var current_user_uid  = "".obs;
//   var current_user_email = "".obs;
//   var current_user_key = "".obs;
//
//   Future<void> loadFromStorage() async {
//     final prefs = await SharedPreferences.getInstance();
//     current_user_uid.value = prefs.getString('current_user_uid') ?? current_user_uid.value;
//     current_user_email.value = prefs.getString('current_user_email') ?? current_user_email.value;
//     current_user_key.value = prefs.getString('current_user_key') ?? current_user_key.value;
//   }
//
//   Future<void> saveToStorage() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('current_user_uid', current_user_uid.value);
//     await prefs.setString('current_user_email', current_user_email.value);
//     await prefs.setString("current_user_key", current_user_key.value);
//   }
// }