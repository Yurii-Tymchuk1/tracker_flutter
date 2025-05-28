import 'package:flutter/material.dart';
import 'package:tracker/screens/statistics_screen.dart';
import 'package:tracker/screens/transactions_screen.dart';
import 'package:tracker/screens/budget_screen.dart';
import 'package:tracker/screens/category_screen.dart';

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
    const SizedBox.shrink(), // FAB
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey.shade100,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16, // 🔽 додає відступ знизу
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.remove_circle, color: Colors.red),
                title: const Text('Додати витрату'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add-transaction');
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle, color: Colors.green),
                title: const Text('Додати дохід'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/add-income');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Статистика',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Транзакції',
          ),
          // FAB займає місце сам — сюди нічого не треба
          BottomNavigationBarItem(
            icon: SizedBox(height: 0), // або SizedBox.shrink()
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Бюджети',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Категорії',
          ),
        ],
      ),
    );


  }

  Widget _navIcon(IconData icon, int index) {
    return Column(
      children: [
        if (_selectedIndex == index)
          Container(
            height: 4,
            width: 4,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        Icon(icon),
      ],
    );
  }
}
