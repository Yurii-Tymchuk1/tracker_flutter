import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';

class BudgetStatsScreen extends StatelessWidget {
  const BudgetStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgets = Provider.of<BudgetProvider>(context).budgets;

    final Map<String, double> categoryTotals = {};
    for (var b in budgets) {
      categoryTotals[b.category] = (categoryTotals[b.category] ?? 0) + b.maxAmount;
    }

    final sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key}\n${entry.value.toStringAsFixed(0)}',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика бюджету')),
      body: Center(
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 4,
          ),
        ),
      ),
    );
  }
}
