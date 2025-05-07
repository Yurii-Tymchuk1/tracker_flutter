import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/models/income.dart';
import '../providers/income_provider.dart';
import 'add_income_screen.dart';
import 'edit_income_screen.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {
    final incomeProvider = context.watch<IncomeProvider>();
    final allIncomes = incomeProvider.incomes;
    final filteredIncomes =
    allIncomes.where((income) => income.date.month == _selectedMonth).toList();

    final totalMonthly = filteredIncomes.fold(0.0, (sum, i) => sum + i.amount);
    final totalAll = allIncomes.fold(0.0, (sum, i) => sum + i.amount);

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
                final monthName = DateFormat.MMMM('uk').format(DateTime(2020, month));
                return DropdownMenuItem(
                  value: month,
                  child: Text(monthName[0].toUpperCase() + monthName.substring(1)),
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
                  'Сума за місяць: ${totalMonthly.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Загалом: ${totalAll.toStringAsFixed(2)}',
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
                  title: Text(income.title),
                  subtitle: Text(
                    '${income.amount.toStringAsFixed(2)} ${income.currency} — ${DateFormat.yMMMd('uk').format(income.date)}',
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditIncomeScreen(income: income),
                      ),
                    );
                    setState(() {}); // оновлення після редагування
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddIncomeScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
