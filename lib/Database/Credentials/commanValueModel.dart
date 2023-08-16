import 'package:hive/hive.dart';

part 'commanValueModel.g.dart';


@HiveType(typeId: 1)
class commanValueModel extends HiveObject {
  @HiveField(0)
  late String uid;

  @HiveField(1)
  late String email;

  @HiveField(2)
  late String key;
}