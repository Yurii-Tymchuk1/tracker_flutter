import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../data/models/budget.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final budgets = budgetProvider.budgets;

    return Scaffold(
      appBar: AppBar(title: const Text('Бюджети')),
      body: ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final item = budgets[index];
          final spent = budgetProvider.getSpentAmountFor(item);
          final remaining = budgetProvider.getRemainingAmountFor(item);
          final isExceeded = budgetProvider.isBudgetExceeded(item);
          final progress = (spent / item.maxAmount).clamp(0.0, 1.0);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 2,
            child: ListTile(
              title: Text(item.category),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: isExceeded ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isExceeded
                        ? 'Перевищено: ${(-remaining).toStringAsFixed(2)} ${item.currency}'
                        : 'Залишок: ${remaining.toStringAsFixed(2)} ${item.currency}',
                    style: TextStyle(
                      color: isExceeded ? Colors.red : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => budgetProvider.deleteBudget(item),
              ),
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
    final _categoryController = TextEditingController();
    final _amountController = TextEditingController();
    final List<String> _currencies = [
      '🇺🇦 UAH', '🇺🇸 USD', '🇪🇺 EUR', '🇬🇧 GBP', '🇵🇱 PLN', '🇨🇭 CHF', '🇯🇵 JPY', '🇨🇳 CNY'
    ];
    String _selectedCurrency = '🇺🇦 UAH';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Новий бюджет'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(labelText: 'Категорія'),
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
                      setState(() {
                        _selectedCurrency = value;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final category = _categoryController.text;
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  final currency = _selectedCurrency;

                  if (category.isNotEmpty && amount > 0 && currency.isNotEmpty) {
                    final newBudget = Budget(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      category: category,
                      maxAmount: amount,
                      currency: currency,
                    );

                    Provider.of<BudgetProvider>(context, listen: false)
                        .addBudget(newBudget);
                  }

                  Navigator.of(ctx).pop();
                },
                child: const Text('Додати'),
              ),
            ],
          ),
        );
      },
    );
  }
}
