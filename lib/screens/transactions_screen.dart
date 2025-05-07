import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'edit_transaction_screen.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _selectedMonth = DateTime.now().month;

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;

    final filteredTransactions = transactions.where((tx) {
      return tx.date.month == _selectedMonth;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Транзакції')),
      body: Column(
        children: [
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
                  setState(() => _selectedMonth = value);
                }
              },
            ),
          ),
          Expanded(
            child: filteredTransactions.isEmpty
                ? const Center(child: Text('Немає транзакцій'))
                : ListView.builder(
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
                return Dismissible(
                  key: Key(tx.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await Provider.of<TransactionProvider>(context, listen: false)
                        .deleteTransactionById(tx.id);
                    await transactionProvider.loadTransactions();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Транзакцію видалено')),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${tx.amount.toInt()}'),
                    ),
                    title: Text(tx.title),
                    subtitle: Text(DateFormat.yMMMd('uk').format(tx.date)),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditTransactionScreen(transaction: tx),
                        ),
                      );
                      await transactionProvider.loadTransactions();
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

  String _monthName(int monthNumber) {
    const months = [
      'Січень', 'Лютий', 'Березень', 'Квітень', 'Травень', 'Червень',
      'Липень', 'Серпень', 'Вересень', 'Жовтень', 'Листопад', 'Грудень'
    ];
    return months[monthNumber - 1];
  }
}
