import 'package:flutter/material.dart';
import 'package:tracker/screens/statistics_screen.dart';
import 'package:tracker/screens/transactions_screen.dart';
import 'package:tracker/screens/budget_screen.dart';
import 'package:tracker/screens/category_screen.dart';
import 'package:tracker/screens/income_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const StatisticsScreen(),
    const TransactionsScreen(),
    const SizedBox.shrink(),
    const BudgetScreen(),
    const CategoryScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showAddMenu();
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.remove),
            title: const Text('Додати витрату'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add-transaction');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Додати дохід'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/add-income');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Статистика'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Транзакції'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Бюджети'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Категорії'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
