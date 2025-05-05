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
    final budgets = budgetProvider.budgets;

    return Scaffold(
      appBar: AppBar(title: const Text('Бюджети')),
      body: budgets.isEmpty
          ? const Center(child: Text('Бюджетів ще немає. Додайте новий!'))
          : ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final item = budgets[index];
          final spentAmount = budgetProvider.getSpentAmountFor(item);
          final remainingAmount = budgetProvider.getRemainingAmountFor(item);
          final exceeded = budgetProvider.isBudgetExceeded(item);
          final nearLimit = budgetProvider.isBudgetNearLimit(item);



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
                if (nearLimit && !exceeded)
                  Text(
                    'Увага: залишок майже вичерпано!',
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),

              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditBudgetDialog(context, item);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Підтвердження'),
                        content: const Text('Ви впевнені, що хочете видалити цей бюджет?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Скасувати'),
                          ),
                          TextButton(
                            onPressed: () {
                              budgetProvider.deleteBudget(item);
                              Navigator.of(ctx).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Бюджет видалено')),
                              );
                            },
                            child: const Text('Так'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
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
    final List<String> _currencies = ['UAH', 'USD', 'EUR', 'PLN'];
    String _selectedCurrency = _currencies.first;

    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final categories = categoryProvider.categories.map((c) => c.name).toList();

    bool _isGeneral = true;
    String _selectedCategory = categories.isNotEmpty ? categories.first : '';

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
                  value: categories.contains(_selectedCategory) ? _selectedCategory : null,
                  decoration: const InputDecoration(labelText: 'Категорія'),
                  items: categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
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
                value: _currencies.contains(_selectedCurrency) ? _selectedCurrency : null,
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
                  if (_isGeneral && budget.isGeneral) return true;
                  if (!_isGeneral && budget.category == _selectedCategory) return true;
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

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    final _amountController = TextEditingController(text: budget.maxAmount.toString());
    final List<String> _currencies = ['UAH', 'USD', 'EUR', 'PLN'];
    String _selectedCurrency = budget.currency;
    bool _isGeneral = budget.isGeneral;
    String _selectedCategory = budget.category ?? '';

    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final categories = categoryProvider.categories.map((c) => c.name).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Редагувати бюджет'),
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
                  value: categories.contains(_selectedCategory) ? _selectedCategory : null,
                  decoration: const InputDecoration(labelText: 'Категорія'),
                  items: categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
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
                value: _currencies.contains(_selectedCurrency) ? _selectedCurrency : null,
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
                if (amount > 0) {
                  final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
                  final existingBudgets = budgetProvider.budgets;

                  bool duplicateExists = existingBudgets.any((b) {
                    if (b.id == budget.id) return false; // пропускаємо поточний бюджет
                    if (_isGeneral && b.isGeneral) return true;
                    if (!_isGeneral && b.category == _selectedCategory) return true;
                    return false;
                  });

                  if (duplicateExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Такий бюджет вже існує!')),
                    );
                    return;
                  }

                  final updatedBudget = Budget(
                    id: budget.id,
                    category: _isGeneral ? null : _selectedCategory,
                    maxAmount: amount,
                    currency: _selectedCurrency,
                    isGeneral: _isGeneral,
                  );

                  budgetProvider.addBudget(updatedBudget);
                  Navigator.of(ctx).pop();
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Некоректна сума!')),
                  );
                }
              },
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }
}