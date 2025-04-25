import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/transaction.dart';
import '../providers/transaction_provider.dart';

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

  final List<String> _categories = ['Їжа', 'Транспорт', 'Розваги', 'Комуналка', 'Інше'];
  String _selectedCategory = 'Інше';

  final Map<String, String> _currencySymbols = {
    'UAH': '₴',
    'USD': '\$',
    'EUR': '€',
    'PLN': 'zł',
  };
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = _currencySymbols.keys.first;
  }

  void _submitData() {
    if (!_formKey.currentState!.validate()) return;

    final newTransaction = TransactionModel(
      id: DateTime.now().toString(),
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      date: _selectedDate,
      category: _selectedCategory,
      currency: _selectedCurrency,
    );

    Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(newTransaction);

    _titleController.clear();
    _amountController.clear();
    _selectedDate = DateTime.now();
    _selectedCategory = 'Інше';
    _selectedCurrency = _currencySymbols.keys.first;

    Navigator.pop(context);
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                validator: (value) =>
                value!.isEmpty ? 'Введіть назву' : null,
              ),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Сума'),
                validator: (value) =>
                value!.isEmpty ? 'Введіть суму' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Дата: ${_selectedDate.toLocal().toString().split(' ')[0]}',
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
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(labelText: 'Валюта'),
                items: _currencySymbols.keys.map((code) {
                  return DropdownMenuItem(
                    value: code,
                    child: Text('$code (${_currencySymbols[code]})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
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
}
