import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/budget.dart';
import '../data/models/transaction.dart';

class BudgetProvider with ChangeNotifier {
  final Box<Budget> _budgetBox = Hive.box<Budget>('budgets');
  List<TransactionModel> _externalTransactions = [];

  List<Budget> get budgets => _budgetBox.values.toList(); // живий доступ

  void updateTransactions(List<TransactionModel> transactions) {
    _externalTransactions = transactions;
    notifyListeners();
  }

  void addBudget(Budget budget) async {
    await _budgetBox.put(budget.id, budget);
    notifyListeners();
  }

  void deleteBudget(Budget budget) async {
    await _budgetBox.delete(budget.id); // ✅ ключ - це id
    notifyListeners(); // 🔁 оновлює екран
  }

  double getSpentAmountFor(Budget budget) {
    return budget.getSpentAmount(_externalTransactions);
  }

  double getRemainingAmountFor(Budget budget) {
    return budget.getRemainingAmount(_externalTransactions);
  }

  bool isBudgetExceeded(Budget budget) {
    return budget.isExceeded(_externalTransactions);
  }

  bool isBudgetNearLimit(Budget budget, {double threshold = 0.1}) {
    final remaining = budget.getRemainingAmount(_externalTransactions);
    return remaining > 0 && (remaining / budget.maxAmount) < threshold;
  }

  void refresh() {
    notifyListeners();
  }
}
