import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../data/models/income.dart';
import '../providers/income_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../data/models/category.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'UAH';
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();

    // ✅ Автоматична базова валюта
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _selectedCurrency = settingsProvider.baseCurrency;

    final incomeCategories = Provider.of<CategoryProvider>(context, listen: false)
        .getCategoriesByType(CategoryType.income);
    if (incomeCategories.isNotEmpty) {
      _selectedCategory = incomeCategories.first.name;
    }
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _submitData() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0 || _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введіть коректну суму та категорію')),
      );
      return;
    }

    final income = IncomeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      date: _selectedDate,
      currency: _selectedCurrency, // ✅ Автоматична валюта
      category: _selectedCategory,
      title: _selectedCategory,
    );

    Provider.of<IncomeProvider>(context, listen: false).addIncome(income);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final incomeCategories =
    Provider.of<CategoryProvider>(context).getCategoriesByType(CategoryType.income);

    return Scaffold(
      appBar: AppBar(title: const Text('Додати дохід')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Сума'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Дата: ${DateFormat.yMMMd('uk').format(_selectedDate)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: const Text('Оберіть дату'),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Категорія'),
              items: incomeCategories.map((cat) {
                return DropdownMenuItem(value: cat.name, child: Text(cat.name));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCategory = val);
                }
              },
            ),
            const SizedBox(height: 20),
            Text('Валюта: $_selectedCurrency', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Додати'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
