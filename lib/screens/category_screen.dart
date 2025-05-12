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
  Color _selectedColor = Colors.blue; // 🔹 Початковий колір

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
              _selectedType == CategoryType.income
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
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (_, index) {
                final cat = categories[index];
                return ListTile(
                  leading: CircleAvatar(backgroundColor: Color(cat.color)),
                  title: Text(cat.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => categoryProvider.deleteCategory(cat.id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(hintText: 'Нова категорія'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _pickColor(context),
                      child: CircleAvatar(
                        backgroundColor: _selectedColor,
                        radius: 18,
                        child: const Icon(Icons.color_lens, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = _controller.text.trim();
                    if (name.isNotEmpty) {
                      final newCategory = CategoryModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        type: _selectedType,
                        color: _selectedColor.value, // 💾 Зберігаємо як int
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

  Future<void> _pickColor(BuildContext context) async {
    final Color? picked = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Оберіть колір'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            Colors.blue,
            Colors.green,
            Colors.orange,
            Colors.red,
            Colors.purple,
            Colors.teal,
            Colors.brown,
            Colors.indigo,
            Colors.pink,
            Colors.grey,
          ].map((color) {
            return GestureDetector(
              onTap: () => Navigator.of(context).pop(color),
              child: CircleAvatar(backgroundColor: color),
            );
          }).toList(),
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedColor = picked;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
