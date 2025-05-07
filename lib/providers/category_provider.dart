import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/category.dart';

class CategoryProvider with ChangeNotifier {
  final Box<CategoryModel> _categoryBox = Hive.box<CategoryModel>('categories');

  List<CategoryModel> get categories => _categoryBox.values.toList();

  Future<void> addCategory(CategoryModel category) async {
    await _categoryBox.put(category.id, category);
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryBox.delete(id);
    notifyListeners();
  }

  Future<void> updateCategory(CategoryModel updated) async {
    await _categoryBox.put(updated.id, updated);
    notifyListeners();
  }

  List<CategoryModel> getCategoriesByType(CategoryType type) {
    return _categoryBox.values.where((c) => c.type == type).toList();
  }

  Future<void> initializeDefaultCategories() async {
    if (_categoryBox.isEmpty) {
      final defaultCategories = [
        CategoryModel(id: '1', name: 'Продукти', type: CategoryType.expense),
        CategoryModel(id: '2', name: 'Транспорт', type: CategoryType.expense),
        CategoryModel(id: '3', name: 'Зарплата', type: CategoryType.income),
        CategoryModel(id: '4', name: 'Фріланс', type: CategoryType.income),
      ];

      for (var cat in defaultCategories) {
        await _categoryBox.put(cat.id, cat);
      }

      notifyListeners();
    }
  }
}
