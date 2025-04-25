import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/transaction.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedMonth = DateTime.now().month; // За замовчуванням поточний місяць

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;

    // Фільтрація транзакцій по місяцю
    final filteredTransactions = transactions.where((tx) {
      return tx.date.month == _selectedMonth;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Транзакції')),
      body: Column(
        children: [
          // Випадаючий список місяців
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<int>(
              value: _selectedMonth,
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(_monthName(index + 1)),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedMonth = value;
                  });
                }
              },
            ),
          ),
          // Список транзакцій
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(child: Text('Немає транзакцій'))
                : ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                TransactionModel tx = filteredTransactions[index];
                return Dismissible(
                  key: Key(tx.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    Provider.of<TransactionProvider>(context, listen: false)
                        .deleteTransaction(
                      transactionProvider.transactions.indexOf(tx),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${tx.amount.toInt()}'),
                    ),
                    title: Text(tx.title),
                    subtitle: Text(
                      '${tx.date.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Допоміжна функція для назв місяців
  String _monthName(int monthNumber) {
    const months = [
      'Січень', 'Лютий', 'Березень', 'Квітень', 'Травень', 'Червень',
      'Липень', 'Серпень', 'Вересень', 'Жовтень', 'Листопад', 'Грудень'
    ];
    return months[monthNumber - 1];
  }
}
