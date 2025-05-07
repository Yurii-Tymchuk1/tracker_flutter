import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/home_screen.dart';
import 'data/models/transaction.dart';
import 'data/models/budget.dart';
import 'data/models/category.dart';
import 'data/models/income.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'providers/income_provider.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/add_income_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // 🔥 ВАЖЛИВО: видалити всі box'и, які могли мати старі typeId
  //await Hive.deleteBoxFromDisk('income_categories');

  // ✅ Реєстрація адаптерів
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(IncomeModelAdapter());

  // ✅ Відкриття Box'ів
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<IncomeModel>('incomes');

  // ✅ Локалізація
  await initializeDateFormatting('uk', null);

  // ✅ Скидання бюджетів, якщо потрібно
  final tempBudgetProvider = BudgetProvider();
  await tempBudgetProvider.resetBudgetsIfNeeded();

  runApp(const TrackerApp());
}

class TrackerApp extends StatelessWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => IncomeProvider()),
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tracker',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/add-transaction': (context) => const AddTransactionScreen(),
          '/add-income': (context) => const AddIncomeScreen(),
        },
      ),
    );
  }
}
