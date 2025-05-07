import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/category.dart';
import '../providers/category_provider.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  CategoryType _selectedType = CategoryType.expense;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.getCategoriesByType(_selectedType);

    return Scaffold(
      appBar: AppBar(title: const Text('Категорії')),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: [
              _selectedType == CategoryType.expense,
              _selectedType == CategoryType.income,
            ],
            onPressed: (index) {
              setState(() {
                _selectedType = CategoryType.values[index];
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Витрати'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Доходи'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: categories.isEmpty
                ? const Center(child: Text('Немає категорій'))
                : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (_, index) {
                final cat = categories[index];
                return ListTile(
                  title: Text(cat.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        categoryProvider.deleteCategory(cat.id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
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
                ElevatedButton(
                  onPressed: () {
                    final name = _controller.text.trim();
                    if (name.isNotEmpty) {
                      final newCategory = CategoryModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        type: _selectedType,
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
