import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = Provider.of<TransactionProvider>(context).transactions;

    // групуємо транзакції по категоріях
    final Map<String, double> categoryTotals = {};
    for (var tx in transactions) {
      categoryTotals[tx.category] = (categoryTotals[tx.category] ?? 0) + tx.amount;
    }

    // створюємо секції для PieChart
    final List<PieChartSectionData> sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key} (${entry.value.toStringAsFixed(0)})',
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
        color: _getCategoryColor(entry.key),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: transactions.isEmpty
          ? const Center(child: Text('Немає даних для статистики'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }

  // Допоміжна функція: колір для кожної категорії
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Їжа':
        return Colors.green;
      case 'Транспорт':
        return Colors.blue;
      case 'Розваги':
        return Colors.orange;
      case 'Комуналка':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
