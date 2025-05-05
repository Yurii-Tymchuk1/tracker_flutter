import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../data/models/budget.dart';

class BudgetStatsScreen extends StatelessWidget {
  const BudgetStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final budgets = budgetProvider.budgets;

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика бюджету')),
      body: budgets.isEmpty
          ? const Center(child: Text('Немає створених бюджетів'))
          : ListView.builder(
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final spent = budgetProvider.getSpentAmountFor(budget);
          final remaining = budgetProvider.getRemainingAmountFor(budget);
          final exceeded = budgetProvider.isBudgetExceeded(budget);
          final nearLimit = budgetProvider.isBudgetNearLimit(budget);

          final progress = (spent / budget.maxAmount).clamp(0.0, 1.0);

          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${budget.category ?? 'Загальний'} (${budget.currency})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      exceeded ? Colors.red : Colors.green,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Витрачено: ${spent.toStringAsFixed(2)} / ${budget.maxAmount.toStringAsFixed(2)} ${budget.currency}',
                  ),
                  Text(
                    'Залишок: ${remaining.toStringAsFixed(2)} ${budget.currency}',
                    style: TextStyle(
                      color: exceeded ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (nearLimit && !exceeded) ...[
                    const SizedBox(height: 4),
                    const Text(
                      'Увага: залишок майже вичерпано!',
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
