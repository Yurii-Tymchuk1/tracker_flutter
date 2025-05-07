import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../data/models/category.dart';

class IncomeCategoryScreen extends StatelessWidget {
  IncomeCategoryScreen({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final incomeCategories = categoryProvider.getCategoriesByType(CategoryType.income);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Категорії доходів'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Нова категорія',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final name = _controller.text.trim();
                    if (name.isNotEmpty) {
                      categoryProvider.addCategory(
                        CategoryModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          type: CategoryType.income,
                        ),
                      );
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: incomeCategories.isEmpty
                ? const Center(child: Text('Категорій ще немає'))
                : ListView.builder(
              itemCount: incomeCategories.length,
              itemBuilder: (_, index) {
                final category = incomeCategories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      categoryProvider.deleteCategory(category.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
