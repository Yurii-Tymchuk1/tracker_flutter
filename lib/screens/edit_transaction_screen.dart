import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _selectedDate = widget.transaction.date;
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
    final title = _titleController.text.trim();

    final updatedTransaction = widget.transaction.copyWith(
      title: title,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
    );

    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    await txProvider.updateTransaction(updatedTransaction, budgetProvider);
    budgetProvider.updateTransactions(txProvider.transactions);

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
      final txProvider = Provider.of<TransactionProvider>(context, listen: false);
      await txProvider.deleteTransactionById(widget.transaction.id);

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
    final categories = categoryProvider.categories.map((c) => c.name).toSet().toList();

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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Назва'),
            ),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Сума'),
            ),
            Row(
              children: [
                Expanded(
                  child: Text('Дата: ${_selectedDate.toLocal().toString().split(" ")[0]}'),
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
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
