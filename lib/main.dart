import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';
import 'data/models/transaction.dart';
import 'data/models/budget.dart';
import 'providers/transaction_provider.dart';
import 'providers/budget_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(BudgetAdapter());

  // Тепер відкриваємо чисті бокси
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<Budget>('budgets');

  runApp(const TrackerApp());
}

class TrackerApp extends StatelessWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
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
