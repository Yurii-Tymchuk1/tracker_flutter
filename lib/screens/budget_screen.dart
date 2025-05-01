import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../data/models/budget.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final budgets = budgetProvider.budgets;

    return Scaffold(
      appBar: AppBar(title: const Text('Бюджети')),
      body: budgets.isEmpty
          ? const Center(child: Text('Бюджетів ще немає. Додайте новий!'))
          : ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final item = budgets[index];
          final transactions = transactionProvider.transactions;
          final spentAmount = item.getSpentAmount(transactions);
          final remainingAmount = item.getRemainingAmount(transactions);
          final exceeded = item.isExceeded(transactions);

          return ListTile(
            title: Text(
              item.isGeneral
                  ? 'Загальний бюджет (${item.currency})'
                  : '${item.category} (${item.currency})',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Витрачено: ${spentAmount.toStringAsFixed(2)} ${item.currency}'),
                Text(
                  'Залишок: ${remainingAmount.toStringAsFixed(2)} ${item.currency}',
                  style: TextStyle(
                    color: exceeded ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => budgetProvider.deleteBudget(item),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final _amountController = TextEditingController();
    final List<String> _currencies = [
      '🇺🇦 UAH', '🇺🇸 USD', '🇪🇺 EUR', '🇬🇧 GBP', '🇵🇱 PLN'
    ];

    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final categories = categoryProvider.categories.map((c) => c.name).toList();

    bool _isGeneral = true;
    String _selectedCategory = categories.isNotEmpty ? categories.first : '';
    String _selectedCurrency = '🇺🇦 UAH';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Новий бюджет'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Загальний бюджет'),
                value: _isGeneral,
                onChanged: (value) {
                  setState(() {
                    _isGeneral = value;
                  });
                },
              ),
              if (!_isGeneral)
                DropdownButtonFormField<String>(
                  value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                  decoration: const InputDecoration(labelText: 'Категорія'),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedCategory = value;
                    }
                  },
                ),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Максимальна сума'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(labelText: 'Валюта'),
                items: _currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _selectedCurrency = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text) ?? 0;
                final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
                final existingBudgets = budgetProvider.budgets;

                bool exists = existingBudgets.any((budget) {
                  if (_isGeneral && budget.isGeneral) {
                    return true; // Вже існує загальний бюджет
                  }
                  if (!_isGeneral && budget.category == _selectedCategory) {
                    return true; // Вже існує бюджет для цієї категорії
                  }
                  return false;
                });

                if (amount > 0 && !exists) {
                  final newBudget = Budget(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    category: _isGeneral ? null : _selectedCategory,
                    maxAmount: amount,
                    currency: _selectedCurrency,
                    isGeneral: _isGeneral,
                  );

                  budgetProvider.addBudget(newBudget);
                  Navigator.of(ctx).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Такий бюджет вже існує або неправильна сума!')),
                  );
                }
              },
              child: const Text('Додати'),
            ),
          ],
        ),
      ),
    );
  }
}
