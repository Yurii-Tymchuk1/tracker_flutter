import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker/providers/budget_provider.dart';
import 'package:tracker/providers/transaction_provider.dart';
import 'package:tracker/data/models/budget.dart';
import 'package:tracker/data/models/transaction.dart';

class BudgetStatsScreen extends StatelessWidget {
  const BudgetStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    final budgets = budgetProvider.budgets;
    final transactions = transactionProvider.transactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика бюджету'),
      ),
      body: budgets.isEmpty
          ? const Center(
        child: Text('Бюджети відсутні. Додайте хоча б один!'),
      )
          : ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final spent = budget.getSpentAmount(transactions);
          final remaining = budget.getRemainingAmount(transactions);
          final exceeded = budget.isExceeded(transactions);

          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text('${budget.category} (${budget.currency})'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: (spent / budget.maxAmount).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      exceeded ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Витрачено: ${spent.toStringAsFixed(2)} / ${budget.maxAmount.toStringAsFixed(2)} ${budget.currency}',
                    style: TextStyle(
                      color: exceeded ? Colors.red : Colors.black,
                    ),
                  ),
                  Text(
                    'Залишок: ${remaining.toStringAsFixed(2)} ${budget.currency}',
                    style: TextStyle(
                      color: exceeded ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
