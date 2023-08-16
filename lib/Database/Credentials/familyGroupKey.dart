import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'familyGroupKeyModel.dart';

class FamilyGroupKey extends GetxController {
  // Group Details
  var familyKey = familyGroupKeyModel().obs;

  Future<void> loadFromStorage() async {
    final box = await Hive.openBox('userBox');
    final group = box.get('familyGroup');
    if (group != null) {
      familyKey.value = group;
    }
  }

  Future<void> saveToStorage() async {
    final box = await Hive.openBox('userBox');
    await box.put('familyGroup', familyKey.value);
  }
}