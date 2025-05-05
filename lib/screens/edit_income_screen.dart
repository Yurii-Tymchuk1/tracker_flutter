import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/income.dart';
import '../providers/income_provider.dart';
import '../providers/income_category_provider.dart';

class EditIncomeScreen extends StatefulWidget {
  final IncomeModel income;

  const EditIncomeScreen({super.key, required this.income});

  @override
  State<EditIncomeScreen> createState() => _EditIncomeScreenState();
}

class _EditIncomeScreenState extends State<EditIncomeScreen> {
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
    _amountController = TextEditingController(text: widget.income.amount.toString());
    _selectedDate = widget.income.date;
    _selectedCurrency = widget.income.currency;
    _selectedCategory = widget.income.category;
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

  Future<void> _saveIncome() async {
    final amount = double.tryParse(_amountController.text) ?? widget.income.amount;

    final updatedIncome = widget.income.copyWith(
      amount: amount,
      date: _selectedDate,
      currency: _selectedCurrency,
      category: _selectedCategory,
      title: _selectedCategory, // зберігаємо категорію як назву
    );

    await Provider.of<IncomeProvider>(context, listen: false)
        .updateIncome(updatedIncome);

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteIncome() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Підтвердження'),
        content: const Text('Видалити цей дохід?'),
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
      await Provider.of<IncomeProvider>(context, listen: false).deleteIncome(widget.income);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Дохід видалено')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<IncomeCategoryProvider>(context);
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редагувати дохід'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteIncome,
          ),
        ],
      ),
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
                  child: Text('Дата: ${_selectedDate.toLocal().toString().split(" ")[0]}'),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: const Text('Оберіть дату'),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(labelText: 'Валюта'),
              items: _currencySymbols.keys.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text('$currency (${_currencySymbols[currency]})'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCurrency = value);
                }
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Категорія'),
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.name,
                  child: Text(cat.name),
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
              onPressed: _saveIncome,
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
