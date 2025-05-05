import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/income.dart';
import '../providers/income_provider.dart';
import '../providers/income_category_provider.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCurrency = 'UAH';
  String? _selectedCategory;

  final Map<String, String> _currencySymbols = {
    'UAH': '₴',
    'USD': '\$',
    'EUR': '€',
    'PLN': 'zł',
  };

  List<String> get _currencies => _currencySymbols.keys.toList();

  void _submitData() {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;

    final income = IncomeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _selectedCategory!, // використовуємо категорію як назву
      amount: amount,
      date: _selectedDate,
      currency: _selectedCurrency,
      category: _selectedCategory!,
    );

    Provider.of<IncomeProvider>(context, listen: false).addIncome(income);
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
    final categoryProvider = Provider.of<IncomeCategoryProvider>(context);
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: AppBar(title: const Text('Додати дохід')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Сума'),
                validator: (value) => value!.isEmpty ? 'Введіть суму' : null,
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
                items: _currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text('$currency (${_currencySymbols[currency]})'),
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
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) =>
                value == null ? 'Оберіть категорію' : null,
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
    _amountController.dispose();
    super.dispose();
  }
}
