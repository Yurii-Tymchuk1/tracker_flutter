import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/income_provider.dart';
import '../providers/category_provider.dart';
import '../providers/settings_provider.dart';
import '../data/models/category.dart';
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
    final txProvider = context.watch<TransactionProvider>();
    final incomeProvider = context.watch<IncomeProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = context.watch<SettingsProvider>(); // 🟢 потрібна змінна для convert()
    final baseCurrency = settingsProvider.baseCurrency;

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

    final items = _showExpenses
        ? txProvider.transactions.where((tx) => isSamePeriod(tx.date)).toList()
        : incomeProvider.incomes.where((inc) => isSamePeriod(inc.date)).toList();

    final Map<String, double> categoryTotals = {};
    final Map<String, int> categoryColors = {};

    double total = 0.0;

    for (var item in items) {
      if (_showExpenses) {
        final tx = item as TransactionModel;
        final amountConverted = settings.convert(tx.amount, tx.currency);
        total += amountConverted;

        categoryTotals.update(
          tx.category,
              (prev) => prev + amountConverted,
          ifAbsent: () => amountConverted,
        );

        final cat = categoryProvider.categories.firstWhere(
              (c) => c.name == tx.category,
          orElse: () => CategoryModel(
            id: 'unknown',
            name: tx.category,
            type: CategoryType.expense,
            color: Colors.grey.value,
          ),
        );
        categoryColors[tx.category] = cat.color;
      } else {
        final inc = item as IncomeModel;
        final amountConverted = settings.convert(inc.amount, inc.currency);
        total += amountConverted;

        categoryTotals.update(
          inc.category,
              (prev) => prev + amountConverted,
          ifAbsent: () => amountConverted,
        );

        final cat = categoryProvider.categories.firstWhere(
              (c) => c.name == inc.category,
          orElse: () => CategoryModel(
            id: 'unknown',
            name: inc.category,
            type: CategoryType.income,
            color: Colors.grey.value,
          ),
        );
        categoryColors[inc.category] = cat.color;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Витрати'),
                  selected: _showExpenses,
                  onSelected: (_) => setState(() => _showExpenses = true),
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Доходи'),
                  selected: !_showExpenses,
                  onSelected: (_) => setState(() => _showExpenses = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: PeriodFilter.values.map((period) {
                final label = switch (period) {
                  PeriodFilter.day => 'День',
                  PeriodFilter.week => 'Тиждень',
                  PeriodFilter.month => 'Місяць',
                  PeriodFilter.year => 'Рік',
                };
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
            Expanded(
              child: categoryTotals.isEmpty
                  ? const Center(child: Text('Немає даних для відображення'))
                  : Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        sections: categoryTotals.entries.map((entry) {
                          final color = Color(categoryColors[entry.key] ?? Colors.grey.value);
                          return PieChartSectionData(
                            value: entry.value,
                            color: color,
                            title: '${(entry.value / total * 100).toStringAsFixed(1)}%',
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
                    'Загалом: ${total.toStringAsFixed(2)} $baseCurrency',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: categoryTotals.entries.map((e) {
                        final color = Color(categoryColors[e.key] ?? Colors.grey.value);
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: color),
                          title: Text(e.key),
                          trailing: Text(
                            '${e.value.toStringAsFixed(2)} $baseCurrency',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
