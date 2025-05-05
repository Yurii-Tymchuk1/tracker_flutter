import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Кількість транзакцій: ${transactionProvider.transactions.length}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/transactions'),
              child: const Text('Перейти до транзакцій'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/budget'),
              child: const Text('Перейти до бюджетів'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/statistics'),
              child: const Text('Переглянути статистику'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/budget-stats'),
              child: const Text('Статистика бюджету'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/categories'),
              child: const Text('Категорії'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/incomes');
              },
              child: const Text('Перейти до доходів'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/income-stats'),
              child: const Text('Статистика доходів'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/income-categories'),
              child: const Text('Категорії доходів'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/income-stats'),
              child: const Text('Аналітика доходів'),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
