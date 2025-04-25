import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Кількість транзакцій: ${transactionProvider.transactions.length}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/transactions'),
              child: Text('Перейти до транзакцій'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/statistics'),
              child: Text('Переглянути статистику'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/budget-stats');
              },
              child: const Text('Статистика бюджету'),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        child: Icon(Icons.add),

      ),
    );
  }

}
