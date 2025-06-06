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

class BottomCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width, size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
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
    final settings = context.watch<SettingsProvider>();
    final baseCurrency = settingsProvider.baseCurrency;
    final totalExpenses = txProvider.transactions.fold<double>(
      0.0,
          (sum, tx) => sum + settings.convert(tx.amount, tx.currency),
    );

    final totalIncomes = incomeProvider.incomes.fold<double>(
      0.0,
          (sum, inc) => sum + settings.convert(inc.amount, inc.currency),
    );

    final netBalance = totalIncomes - totalExpenses;


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
        categoryTotals.update(tx.category, (prev) => prev + amountConverted,
            ifAbsent: () => amountConverted);

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
        categoryTotals.update(inc.category, (prev) => prev + amountConverted,
            ifAbsent: () => amountConverted);

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
        title: Text(
          '${netBalance.toStringAsFixed(2)} $baseCurrency',
          style: const TextStyle(fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),

      body: Stack(
        children: [
          ClipPath(
            clipper: BottomCircleClipper(),
            child: Container(
              width: double.infinity,
              height: 220,
              color: const Color(0xFF04266F),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showExpenses = true),
                        child: Column(
                          children: [
                            Text(
                              'ВИТРАТИ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: _showExpenses ? Colors.white : Colors.white70,
                              ),
                            ),
                            if (_showExpenses)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                height: 2.5,
                                width: 70,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showExpenses = false),
                        child: Column(
                          children: [
                            Text(
                              'ДОХІД',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: !_showExpenses ? Colors.white : Colors.white70,
                              ),
                            ),
                            if (!_showExpenses)
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                height: 2.5,
                                width: 70,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B3F),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: PeriodFilter.values.map((period) {
                            final label = switch (period) {
                              PeriodFilter.day => 'День',
                              PeriodFilter.week => 'Тиждень',
                              PeriodFilter.month => 'Місяць',
                              PeriodFilter.year => 'Рік',
                            };
                            final isSelected = _selectedPeriod == period;

                            return ChoiceChip(
                              label: Text(
                                label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: Colors.blueAccent,
                              backgroundColor: const Color(0xFF1A2B52),
                              showCheckmark: false, // ❌ Вимикає галочку
                              onSelected: (_) => setState(() => _selectedPeriod = period),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20), // трохи менше, щоб підняти
                        Container(
                          height: 240,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1B3F),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  centerSpaceRadius: 60, // дирка
                                  sectionsSpace: 2,
                                  sections: categoryTotals.entries.map((entry) {
                                    final color = Color(categoryColors[entry.key] ?? Colors.grey.value);
                                    final value = entry.value;
                                    final percentage = (value / total * 100).toStringAsFixed(0);

                                    return PieChartSectionData(
                                      value: value,
                                      color: color,
                                      title: '$percentage%', // 🟢 відсоток
                                      radius: 60,
                                      titleStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList(),

                                ),
                              ),
                              Text(
                                '${total.toStringAsFixed(2)} $baseCurrency',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('Немає транзакцій'))
                      : ListView.builder(
                    itemCount: items.length,
                      itemBuilder: (context, index) {
                        if (_showExpenses) {
                          final tx = items[index] as TransactionModel; // ✅ Необхідне оголошення
                          final color = Color(categoryColors[tx.category] ?? Colors.grey.value);
                          final amount = settings.convert(tx.amount, tx.currency);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(backgroundColor: color, radius:17),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.category,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.yMMMMd('uk').format(tx.date),
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${amount.toStringAsFixed(2)} $baseCurrency',
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    fontSize: 15,
                                  ),
                                )
                              ],
                            ),
                          );
                        } else {
                          final inc = items[index] as IncomeModel;
                          final color = Color(categoryColors[inc.category] ?? Colors.grey.value);
                          final amount = settings.convert(inc.amount, inc.currency);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color,
                                  radius: 17,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        inc.category,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        DateFormat.yMMMMd('uk').format(inc.date),
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${amount.toStringAsFixed(2)} $baseCurrency',
                                      style: const TextStyle(color: Colors.black, fontSize: 15),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/edit-income',
                                          arguments: inc,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }


                      }
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
