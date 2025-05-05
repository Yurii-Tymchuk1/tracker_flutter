import 'package:hive/hive.dart';

part 'income_category.g.dart';

@HiveType(typeId: 4)
class IncomeCategoryModel extends HiveObject {
  @HiveField(0)
  String name;

  IncomeCategoryModel({required this.name});
}
