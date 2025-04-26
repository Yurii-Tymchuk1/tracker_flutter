import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/category.dart';

class CategoryProvider with ChangeNotifier {
  final Box<CategoryModel> _categoryBox = Hive.box<CategoryModel>('categories');

  List<CategoryModel> get categories => _categoryBox.values.toList();

  void addCategory(CategoryModel category) async {
    await _categoryBox.put(category.id, category);
    notifyListeners();
  }

  void deleteCategory(CategoryModel category) async {
    await category.delete();
    notifyListeners();
  }

  void initializeDefaultCategories() async {
    if (_categoryBox.isEmpty) {
      final defaults = [
        CategoryModel(id: '1', name: 'Їжа'),
        CategoryModel(id: '2', name: 'Транспорт'),
        CategoryModel(id: '3', name: 'Розваги'),
        CategoryModel(id: '4', name: 'Комуналка'),
        CategoryModel(id: '5', name: 'Інше'),
      ];
      for (var category in defaults) {
        await _categoryBox.put(category.id, category);
      }
      notifyListeners();
    }
  }
}
