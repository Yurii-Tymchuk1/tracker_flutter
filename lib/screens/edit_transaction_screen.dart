import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import 'package:intl/intl.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedCurrency;
  late String _selectedCategory;

  final Map<String, String> _currencySymbols = {
    'UAH': '₴',
    'USD': '\$',
    'EUR': '€',
    'PLN': 'zł',
  };

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _selectedDate = widget.transaction.date;
    _selectedCurrency = widget.transaction.currency;
    _selectedCategory = widget.transaction.category;
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

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountController.text) ?? widget.transaction.amount;

    final updatedTransaction = widget.transaction.copyWith(
      amount: amount,
      date: _selectedDate,
      currency: _selectedCurrency,
      category: _selectedCategory,
      title: _selectedCategory, // використовуємо категорію як назву
    );

    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    await txProvider.updateTransaction(updatedTransaction, budgetProvider);
    budgetProvider.updateTransactions(txProvider.transactions); // 🔁 оновлення бюджету

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Підтвердження'),
        content: const Text('Видалити цю транзакцію?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Так'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Provider.of<TransactionProvider>(context, listen: false)
          .deleteTransactionById(widget.transaction.id);

      // 🔄 після видалення — оновити бюджети
      final txProvider = Provider.of<TransactionProvider>(context, listen: false);
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      budgetProvider.updateTransactions(txProvider.transactions);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Транзакцію видалено')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    // ⛔ Уникнення дублікатів
    final categories = categoryProvider.categories
        .map((c) => c.name)
        .toSet()
        .toList(); // 🧼 remove duplicates

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редагувати транзакцію'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTransaction,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // інші поля...
            DropdownButtonFormField<String>(
              value: categories.contains(_selectedCategory) ? _selectedCategory : null,
              decoration: const InputDecoration(labelText: 'Категорія'),
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTransaction,
              child: const Text('Зберегти'),
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
