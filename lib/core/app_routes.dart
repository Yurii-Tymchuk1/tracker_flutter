import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/statistics_screen.dart';
import '../screens/transactions_screen.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/budget_screen.dart';
import '../screens/budget_stats_screen.dart'; // <-- додано
import '../screens/category_screen.dart';


class AppRoutes {
  static final routes = {
    '/': (context) => HomeScreen(),
    '/transactions': (context) => const TransactionsScreen(),
    '/add': (context) => const AddTransactionScreen(),
    '/budget': (context) => const BudgetScreen(),
    '/budget-stats': (context) => const BudgetStatsScreen(), // <-- додано
    '/statistics': (context) => const StatisticsScreen(),
    '/categories': (context) => const CategoryScreen(),

  };
}
