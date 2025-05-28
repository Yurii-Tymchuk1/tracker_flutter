import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/budget.dart';
import '../data/models/transaction.dart';

class BudgetProvider with ChangeNotifier {
  final Box<Budget> _budgetBox = Hive.box<Budget>('budgets');
  List<TransactionModel> _externalTransactions = [];

  List<Budget> get budgets => _budgetBox.values.toList();

  /// 🔄 Оновлення транзакцій для обчислення витрат
  void updateTransactions(List<TransactionModel> transactions) {
    _externalTransactions = transactions;
    notifyListeners();
  }

  Future<void> addBudget(Budget budget) async {
    await _budgetBox.put(budget.id, budget);
    notifyListeners();
  }

  Future<void> deleteBudget(Budget budget) async {
    await _budgetBox.delete(budget.id);
    notifyListeners();
  }

  /// ✅ Обнулення бюджету при новому місяці
  Future<void> resetBudgetsIfNeeded() async {
    final now = DateTime.now();

    for (var budget in _budgetBox.values) {
      final lastReset = budget.lastReset;
      final shouldReset = lastReset == null ||
          (lastReset.month != now.month || lastReset.year != now.year);

      if (shouldReset) {
        budget.lastReset = now;
        await budget.save();
        // (не обнуляємо витрати напряму, бо вони обчислюються динамічно)
      }
    }

    notifyListeners();
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

  /// 🔁 При редагуванні транзакції — просто перераховуємо бюджети
  void adjustBudgetsOnTransactionEdit(TransactionModel oldTx, TransactionModel newTx) {
    // Витрати рахуються через _externalTransactions, тому просто оновлюємо UI
    notifyListeners();
  }

  Future<void> updateBudget(Budget updatedBudget) async {
    final keyToUpdate = _budgetBox.keys.firstWhere(
          (key) => _budgetBox.get(key)?.id == updatedBudget.id,
      orElse: () => null,
    );

    if (keyToUpdate != null) {
      await _budgetBox.put(keyToUpdate, updatedBudget);
    } else {
      await _budgetBox.put(updatedBudget.id, updatedBudget); // додавання
    }

    notifyListeners(); // важливо для оновлення UI
  }


}
