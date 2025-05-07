import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/income_provider.dart';

class IncomeStatsScreen extends StatelessWidget {
  const IncomeStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incomes = context.watch<IncomeProvider>().incomes;

    final categoryTotals = <String, double>{};
    for (final income in incomes) {
      categoryTotals.update(
        income.category,
            (value) => value + income.amount,
        ifAbsent: () => income.amount,
      );
    }

    final totalIncome = categoryTotals.values.fold(0.0, (a, b) => a + b);

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
      body: incomes.isEmpty
          ? const Center(child: Text('Немає доходів для відображення'))
          : Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: categoryTotals.entries.toList().asMap().entries.map((entry) {
                  final i = entry.key;
                  final category = entry.value.key;
                  final value = entry.value.value;
                  final color = colors[i % colors.length];

                  return PieChartSectionData(
                    color: color,
                    value: value,
                    title: totalIncome == 0
                        ? '0%'
                        : '${(value / totalIncome * 100).toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );

                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Зведення по категоріях',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categoryTotals.length,
              itemBuilder: (context, index) {
                final entry = categoryTotals.entries.elementAt(index);
                final percent = (entry.value / totalIncome) * 100;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colors[index % colors.length],
                  ),
                  title: Text(entry.key),
                  subtitle: Text('${entry.value.toStringAsFixed(2)} (${percent.toStringAsFixed(1)}%)'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
