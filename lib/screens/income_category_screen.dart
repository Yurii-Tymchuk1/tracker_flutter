import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/category.dart';
import '../providers/category_provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


class IncomeCategoryScreen extends StatefulWidget {
  const IncomeCategoryScreen({super.key});

  @override
  State<IncomeCategoryScreen> createState() => _IncomeCategoryScreenState();
}

class _IncomeCategoryScreenState extends State<IncomeCategoryScreen> {
  final TextEditingController _controller = TextEditingController();
  Color _selectedColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories =
    categoryProvider.getCategoriesByType(CategoryType.income);

    return Scaffold(
      appBar: AppBar(title: const Text('Категорії доходів')),
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
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final newColor = await showDialog<Color>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Оберіть колір'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: _selectedColor,
                            onColorChanged: (color) =>
                                Navigator.of(context).pop(color),
                          ),
                        ),
                      ),
                    );
                    if (newColor != null) {
                      setState(() => _selectedColor = newColor);
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: _selectedColor,
                    radius: 16,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = _controller.text.trim();
                    if (name.isNotEmpty) {
                      final category = CategoryModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        type: CategoryType.income,
                        color: _selectedColor.value,
                      );
                      categoryProvider.addCategory(category);
                      _controller.clear();
                    }
                  },
                  child: const Text('Додати'),
                ),
              ],
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? const Center(child: Text('Категорій немає'))
                : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (_, index) {
                final cat = categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(cat.color),
                  ),
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
        ],
      ),
    );
  }
}
