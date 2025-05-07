import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../providers/income_provider.dart';
import '../data/models/transaction.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);

    final expenses = txProvider.transactions
        .where((tx) => tx.date.month == _selectedMonth)
        .toList();
    final incomes = incomeProvider.incomes
        .where((inc) => inc.date.month == _selectedMonth)
        .toList();

    final totalExpenses = expenses.fold(0.0, (sum, tx) => sum + tx.amount);
    final totalIncome = incomes.fold(0.0, (sum, inc) => sum + inc.amount);
    final balance = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Загальна'),
            Tab(text: 'Категорії'),
            Tab(text: 'Динаміка'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedMonth,
              decoration: const InputDecoration(labelText: 'Оберіть місяць'),
              items: List.generate(12, (i) {
                final month = i + 1;
                return DropdownMenuItem(
                  value: month,
                  child: Text(DateFormat.MMMM('uk').format(DateTime(0, month))),
                );
              }),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMonth = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralStats(totalIncome, totalExpenses, balance, expenses.length),
                  _buildCategoryChart(expenses),
                  _buildBarChart(expenses),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStats(double income, double expenses, double balance, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Доходи: ${income.toStringAsFixed(2)}'),
        Text('Витрати: ${expenses.toStringAsFixed(2)}'),
        Text(
          'Баланс: ${balance.toStringAsFixed(2)}',
          style: TextStyle(
              color: balance >= 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold),
        ),
        Text('Кількість транзакцій: $count'),
      ],
    );
  }

  Widget _buildCategoryChart(List<TransactionModel> expenses) {
    final categoryTotals = <String, double>{};
    for (var tx in expenses) {
      categoryTotals.update(tx.category, (v) => v + tx.amount,
          ifAbsent: () => tx.amount);
    }

    if (categoryTotals.isEmpty) {
      return const Center(child: Text('Немає даних для категорій'));
    }

    final sections = categoryTotals.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value,
        title: '${entry.key} (${entry.value.toStringAsFixed(0)})',
        radius: 60,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildBarChart(List<TransactionModel> expenses) {
    final Map<int, double> dailyTotals = {};
    for (var tx in expenses) {
      final day = tx.date.day;
      dailyTotals.update(day, (v) => v + tx.amount, ifAbsent: () => tx.amount);
    }
    final sortedDays = dailyTotals.keys.toList()..sort();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2,
              getTitlesWidget: (value, _) => Text('${value.toInt()}'),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: sortedDays.map((day) {
          final amount = dailyTotals[day]!;
          return BarChartGroupData(
            x: day,
            barRods: [
              BarChartRodData(toY: amount, width: 8, color: Colors.blue),
            ],
          );
        }).toList(),
      ),
    );
  }
}
