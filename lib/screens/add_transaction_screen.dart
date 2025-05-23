import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../data/models/transaction.dart';
import '../data/models/budget.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import 'package:intl/intl.dart';
import '../data/models/category.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = '';
  late String _selectedCurrency;

  final Map<String, String> _currencySymbols = {
    'UAH': '₴',
    'USD': '\$',
    'EUR': '€',
    'PLN': 'zł',
  };

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _selectedCurrency = settings.baseCurrency;

    final categories = context.read<CategoryProvider>().getCategoriesByType(CategoryType.expense);
    if (categories.isNotEmpty) {
      _selectedCategory = categories.first.name;
    }
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _selectedCategory.isEmpty) return;

    final budgetProvider = context.read<BudgetProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final transactions = transactionProvider.transactions;

    final categoryBudget = budgetProvider.budgets.firstWhereOrNull(
          (b) => b.category == _selectedCategory && !b.isGeneral && b.currency == _selectedCurrency,
    );

    final generalBudget = budgetProvider.budgets.firstWhereOrNull(
          (b) => b.isGeneral && b.currency == _selectedCurrency,
    );

    bool isExceeded = false;
    String warningMessage = '';

    if (categoryBudget != null) {
      final spent = categoryBudget.getSpentAmount(transactions) + amount;
      if (spent > categoryBudget.maxAmount) {
        isExceeded = true;
        warningMessage += 'Перевищено бюджет для категорії ${categoryBudget.category}.\n';
      }
    }

    if (generalBudget != null) {
      final spent = generalBudget.getSpentAmount(transactions) + amount;
      if (spent > generalBudget.maxAmount) {
        isExceeded = true;
        warningMessage += 'Перевищено загальний бюджет.';
      }
    }

    if (isExceeded) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Увага'),
          content: Text(warningMessage.trim()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveTransaction(title, amount);
              },
              child: const Text('Додати попри це'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Скасувати'),
            ),
          ],
        ),
      );
      return;
    }

    _saveTransaction(title, amount);
  }

  void _saveTransaction(String title, double amount) {
    final transactionProvider = context.read<TransactionProvider>();
    final budgetProvider = context.read<BudgetProvider>();

    final newTransaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      currency: _selectedCurrency,
    );

    transactionProvider.addTransaction(newTransaction);
    budgetProvider.refresh();
    Navigator.pop(context);
  }

  void _presentDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider
        .getCategoriesByType(CategoryType.expense)
        .map((c) => c.name)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Додати транзакцію')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Назва'),
                validator: (value) => value!.isEmpty ? 'Введіть назву' : null,
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Сума'),
                validator: (value) => value!.isEmpty ? 'Введіть суму' : null,
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
                value: categories.contains(_selectedCategory) ? _selectedCategory : null,
                decoration: const InputDecoration(labelText: 'Категорія'),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Оберіть категорію' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Додати'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
