import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Додано!

import 'core/app_routes.dart';
import 'data/models/transaction.dart';
import 'data/models/budget.dart';
import 'data/models/category.dart';
import 'data/models/income.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'providers/income_provider.dart';
import 'data/models/income_category.dart';
import 'providers/income_category_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('uk', null); // ✅ Ініціалізація локалі
  await Hive.initFlutter();

  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(IncomeModelAdapter());
  Hive.registerAdapter(IncomeCategoryModelAdapter());



  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<IncomeModel>('incomes');
  await Hive.openBox<IncomeCategoryModel>('income_categories');

  runApp(const TrackerApp());
}



class TrackerApp extends StatelessWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()), // ✅ ДОДАЙ ОЦЕ
        ChangeNotifierProxyProvider<TransactionProvider, BudgetProvider>(
          create: (_) => BudgetProvider(),
          update: (_, txProvider, budgetProvider) {
            budgetProvider ??= BudgetProvider();
            budgetProvider.updateTransactions(txProvider.transactions);
            return budgetProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final provider = CategoryProvider();
            provider.initializeDefaultCategories();
            return provider;
          },
        ),

        ChangeNotifierProvider(
          create: (_) {
            final provider = IncomeCategoryProvider();
            provider.initializeDefaultCategories();
            return provider;
          },
        ),

      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: AppRoutes.routes,
      ),
    );
  }
}
