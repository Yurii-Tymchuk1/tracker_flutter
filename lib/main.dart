import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/add_income_screen.dart';
import 'screens/income_screen.dart';
import 'screens/settings_screen.dart';

import 'data/models/transaction.dart';
import 'data/models/budget.dart';
import 'data/models/category.dart';
import 'data/models/income.dart';

import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/category_provider.dart';
import 'providers/income_provider.dart';
import 'providers/settings_provider.dart';

import 'core/app_theme.dart'; // ✅ підключаємо тему

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await dotenv.load(fileName: ".env");

  // 🔁 Реєстрація адаптерів
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  Hive.registerAdapter(IncomeModelAdapter());
  Hive.registerAdapter(CategoryTypeAdapter());

  // 📦 Відкриття box'ів
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<Budget>('budgets');
  await Hive.openBox<CategoryModel>('categories');
  await Hive.openBox<IncomeModel>('incomes');
  await Hive.openBox('settings');

  // 🌐 Локалізація
  await initializeDateFormatting('uk', null);

  // 🏁 Дефолтні категорії
  final categoryProvider = CategoryProvider();
  await categoryProvider.initializeDefaultCategories();

  // 🔄 Скидання бюджетів
  final tempBudgetProvider = BudgetProvider();
  await tempBudgetProvider.resetBudgetsIfNeeded();

  // 💱 Завантаження курсів валют
  final settingsProvider = SettingsProvider();
  await settingsProvider.updateRates();

  runApp(TrackerApp(settingsProvider: settingsProvider));
}

class TrackerApp extends StatelessWidget {
  final SettingsProvider settingsProvider;

  const TrackerApp({super.key, required this.settingsProvider});

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
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => settingsProvider),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tracker',
        theme: AppTheme.lightTheme, // ✅ глобальна тема
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/add-transaction': (context) => const AddTransactionScreen(),
          '/add-income': (context) => const AddIncomeScreen(),
          '/incomes': (context) => const IncomeScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
