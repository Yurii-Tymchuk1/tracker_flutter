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

  // 🔥 Видалити тільки при оновленні структури box'ів
  //await Hive.deleteBoxFromDisk('categories'); // 🧼 ПОТІМ МОЖНА ВИДАЛИТИ

  // ✅ Реєстрація адаптерів
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(IncomeModelAdapter());
  Hive.registerAdapter(CategoryTypeAdapter()); // 👈 ДОДАЙ ЦЕ


  // ✅ Відкриття Box'ів
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<IncomeModel>('incomes');

  // ✅ Ініціалізація дефолтних категорій (один раз при запуску)
  final categoryProvider = CategoryProvider();
  await categoryProvider.initializeDefaultCategories(); // 🔁 ПОТРІБНО ЛИШЕ ОДИН РАЗ

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
            // 🟡 МОЖНА ВИДАЛИТИ, якщо вже викликано в main()
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
