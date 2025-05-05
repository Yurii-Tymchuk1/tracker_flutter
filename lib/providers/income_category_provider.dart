import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/income_category.dart';

class IncomeCategoryProvider with ChangeNotifier {
  final Box<IncomeCategoryModel> _box = Hive.box<IncomeCategoryModel>('income_categories');

  List<IncomeCategoryModel> get categories => _box.values.toList();

  void addCategory(String name) {
    final exists = _box.values.any((c) => c.name.toLowerCase() == name.toLowerCase());
    if (!exists) {
      final category = IncomeCategoryModel(name: name);
      _box.add(category);
      notifyListeners();
    }
  }

  void deleteCategory(IncomeCategoryModel category) async {
    await category.delete();
    notifyListeners();
  }

  void initializeDefaultCategories() {
    if (_box.isEmpty) {
      addCategory('Зарплата');
      addCategory('Подарунок');
      addCategory('Фріланс');
    }
  }
}
