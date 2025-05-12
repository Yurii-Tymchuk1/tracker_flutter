import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 5) // 👈 окремий typeId для enum
enum CategoryType {
  @HiveField(0)
  expense,

  @HiveField(1)
  income,
}

@HiveType(typeId: 4)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final CategoryType type;

  @HiveField(3)
  final int color; // зберігається як int (наприклад, Colors.red.value)


  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
  });

}
