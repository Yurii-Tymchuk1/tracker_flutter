import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/income_provider.dart';
import '../data/models/income.dart';

class IncomeChartScreen extends StatelessWidget {
  const IncomeChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incomes = context.watch<IncomeProvider>().incomes;

    final categoryTotals = <String, double>{};
    for (final income in incomes) {
      categoryTotals.update(income.category, (value) => value + income.amount,
          ifAbsent: () => income.amount);
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Аналітика доходів')),
      body: Center(
        child: categoryTotals.isEmpty
            ? const Text('Немає доходів для відображення')
            : PieChart(
          PieChartData(
            sections: categoryTotals.entries.toList().asMap().entries.map((e) {
              final i = e.key;
              final entry = e.value;
              final color = colors[i % colors.length];
              return PieChartSectionData(
                color: color,
                value: entry.value,
                title: '${entry.key}\n${entry.value.toStringAsFixed(0)}',
                radius: 80,
                titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList()
          ),
        ),
      ),
    );
  }
}
