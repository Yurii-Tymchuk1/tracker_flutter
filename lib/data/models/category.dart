import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  CategoryModel({required this.id, required this.name});
}
