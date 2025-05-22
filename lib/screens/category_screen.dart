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
  Color _selectedColor = Colors.blue;

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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showEditDialog(context, cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => categoryProvider.deleteCategory(cat.id),
                      ),
                    ],
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
                        color: _selectedColor.value,
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

  Future<void> _pickColor(BuildContext context, [Function(Color)? onPicked]) async {
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
      if (onPicked != null) {
        onPicked(picked);
      } else {
        setState(() => _selectedColor = picked);
      }
    }
  }

  void _showEditDialog(BuildContext context, CategoryModel cat) {
    final nameController = TextEditingController(text: cat.name);
    Color tempColor = Color(cat.color);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Редагувати категорію'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Назва'),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _pickColor(context, (picked) {
                setState(() {
                  tempColor = picked;
                });
              }),
              child: CircleAvatar(
                backgroundColor: tempColor,
                radius: 18,
                child: const Icon(Icons.color_lens, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final updated = CategoryModel(
                  id: cat.id,
                  name: name,
                  type: cat.type,
                  color: tempColor.value,
                );
                Provider.of<CategoryProvider>(context, listen: false)
                    .updateCategory(updated);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Зберегти'),
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
