import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'familyGroupKeyModel.g.dart';

@HiveType(typeId: 2)
class familyGroupKeyModel extends HiveObject {
  @HiveField(0)
  late String fid;

  @HiveField(1)
  late String key;
}