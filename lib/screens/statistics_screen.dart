import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/income_provider.dart';
import '../data/models/transaction.dart';
import '../data/models/income.dart';

enum PeriodFilter { day, week, month, year }

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _showExpenses = true;
  PeriodFilter _selectedPeriod = PeriodFilter.month;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);

    bool isSamePeriod(DateTime date) {
      switch (_selectedPeriod) {
        case PeriodFilter.day:
          return date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;
        case PeriodFilter.week:
          final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              date.isBefore(weekEnd.add(const Duration(days: 1)));
        case PeriodFilter.month:
          return date.year == _selectedDate.year && date.month == _selectedDate.month;
        case PeriodFilter.year:
          return date.year == _selectedDate.year;
      }
    }

    final List items = _showExpenses
        ? txProvider.transactions.where((tx) => isSamePeriod(tx.date)).toList()
        : incomeProvider.incomes.where((inc) => isSamePeriod(inc.date)).toList();

    final total = items.fold(0.0, (sum, tx) => sum + (tx as dynamic).amount);

    final Map<String, double> categoryTotals = {};
    for (var tx in items) {
      final dynamic data = tx;
      categoryTotals.update(
        data.category,
            (v) => v + data.amount,
        ifAbsent: () => data.amount,
      );
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
      appBar: AppBar(title: const Text('Статистика')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔁 Перемикач доходи/витрати
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Витрати'),
                  selected: _showExpenses,
                  onSelected: (selected) => setState(() => _showExpenses = true),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Доходи'),
                  selected: !_showExpenses,
                  onSelected: (selected) => setState(() => _showExpenses = false),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📅 Період фільтрації
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: PeriodFilter.values.map((period) {
                String label = period.toString().split('.').last;
                switch (period) {
                  case PeriodFilter.day:
                    label = 'День';
                    break;
                  case PeriodFilter.week:
                    label = 'Тиждень';
                    break;
                  case PeriodFilter.month:
                    label = 'Місяць';
                    break;
                  case PeriodFilter.year:
                    label = 'Рік';
                    break;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: _selectedPeriod == period,
                    onSelected: (_) => setState(() => _selectedPeriod = period),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 📊 Діаграма та категорії
            Expanded(
              child: Column(
                children: [
                  if (categoryTotals.isEmpty)
                    const Text('Немає даних для відображення')
                  else ...[
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                          sections: categoryTotals.entries.toList().asMap().entries.map((entry) {
                            final i = entry.key;
                            final e = entry.value;
                            return PieChartSectionData(
                              value: e.value,
                              color: colors[i % colors.length],
                              title: '${(e.value / total * 100).toStringAsFixed(1)}%',
                              radius: 80,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Загалом: ${total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView(
                        children: categoryTotals.entries.map((e) {
                          final index = categoryTotals.keys.toList().indexOf(e.key);
                          return ListTile(
                            leading: CircleAvatar(backgroundColor: colors[index % colors.length]),
                            title: Text(e.key),
                            trailing: Text('${e.value.toStringAsFixed(2)}'),
                          );
                        }).toList(),
                      ),
                    ),
                  ]
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
