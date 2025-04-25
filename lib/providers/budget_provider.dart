import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/budget.dart';
import '../data/models/transaction.dart';

class BudgetProvider with ChangeNotifier {
  final Box<Budget> _budgetBox = Hive.box<Budget>('budgets');
  final Box<TransactionModel> _transactionBox = Hive.box<TransactionModel>('transactions');

  List<Budget> get budgets => _budgetBox.values.toList();
  List<TransactionModel> get transactions => _transactionBox.values.toList();

  void addBudget(Budget budget) async {
    await _budgetBox.put(budget.id, budget);
    notifyListeners();
  }

  void deleteBudget(Budget budget) async {
    await budget.delete();
    notifyListeners();
  }

  double getSpentAmountFor(Budget budget) {
    return budget.getSpentAmount(transactions);
  }

  double getRemainingAmountFor(Budget budget) {
    return budget.getRemainingAmount(transactions);
  }

  bool isBudgetExceeded(Budget budget) {
    return budget.isExceeded(transactions);
  }
}
