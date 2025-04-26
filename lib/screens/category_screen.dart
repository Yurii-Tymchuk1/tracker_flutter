import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../data/models/category.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;

    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Категорії'),
      ),
      body: Column(
        children: [
          Expanded(
            child: categories.isEmpty
                ? const Center(
              child: Text(
                'Категорій ще немає. Додайте нову!',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (ctx, i) {
                final category = categories[i];
                return ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      categoryProvider.deleteCategory(category);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Нова категорія',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      final newCategory = CategoryModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _controller.text.trim(),
                      );
                      categoryProvider.addCategory(newCategory);
                      _controller.clear();
                    }
                  },
                  child: const Text('Додати'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
