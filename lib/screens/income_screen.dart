import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../data/models/income.dart';
import '../providers/income_provider.dart';
import '../providers/settings_provider.dart';
import 'edit_income_screen.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  int _selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final incomeProvider = context.watch<IncomeProvider>();
    final settings = context.watch<SettingsProvider>();
    final baseCurrency = settings.baseCurrency;

    final allIncomes = incomeProvider.incomes;
    final filteredIncomes = allIncomes
        .where((income) => income.date.month == _selectedMonth)
        .toList();

    final totalMonthly = filteredIncomes.fold<double>(
      0.0,
          (sum, income) => sum + settings.convert(income.amount, income.currency),
    );

    final totalAll = allIncomes.fold<double>(
      0.0,
          (sum, income) => sum + settings.convert(income.amount, income.currency),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Усі доходи')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: const InputDecoration(labelText: 'Оберіть місяць'),
              items: List.generate(12, (index) {
                final month = index + 1;
                return DropdownMenuItem(
                  value: month,
                  child: Text(DateFormat.MMMM('uk').format(DateTime(0, month))),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMonth = value);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сума за місяць: ${totalMonthly.toStringAsFixed(2)} $baseCurrency',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Загалом: ${totalAll.toStringAsFixed(2)} $baseCurrency',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredIncomes.isEmpty
                ? const Center(child: Text('Дохід ще не додано'))
                : ListView.builder(
              itemCount: filteredIncomes.length,
              itemBuilder: (context, index) {
                final income = filteredIncomes[index];
                return ListTile(
                  leading:
                  const Icon(Icons.attach_money, color: Colors.green),
                  title: Text(income.title),
                  subtitle: Text(
                    '${income.amount.toStringAsFixed(2)} ${income.currency} — ${DateFormat.yMMMd('uk').format(income.date)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditIncomeScreen(income: income),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
