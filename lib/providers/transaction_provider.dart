import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/transaction.dart';
import 'budget_provider.dart';


class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  TransactionProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadTransactions();
  }

  Future<void> loadTransactions() async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    _transactions = box.values.toList();
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.add(tx);
    _transactions.add(tx);
    notifyListeners();
  }

  Future<void> deleteTransaction(int index) async {
    final box = await Hive.openBox<TransactionModel>('transactions');
    await box.deleteAt(index);
    _transactions.removeAt(index);
    notifyListeners();
  }

  Future<void> deleteTransactionById(String id) async {
    final box = await Hive.openBox<TransactionModel>('transactions');

    final keyToDelete = box.keys.firstWhere(
          (key) => box.get(key)?.id == id,
      orElse: () => null,
    );

    if (keyToDelete != null) {
      await box.delete(keyToDelete);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    }
  }

  Future<void> updateTransaction(TransactionModel updatedTx, BudgetProvider budgetProvider) async {
    final box = await Hive.openBox<TransactionModel>('transactions');

    // Знаходимо стару транзакцію
    final oldTx = _transactions.firstWhere((t) => t.id == updatedTx.id);

    final keyToUpdate = box.keys.firstWhere(
          (key) => box.get(key)?.id == updatedTx.id,
      orElse: () => null,
    );

    if (keyToUpdate != null) {
      await box.put(keyToUpdate, updatedTx);

      final index = _transactions.indexWhere((t) => t.id == updatedTx.id);
      if (index != -1) {
        _transactions[index] = updatedTx;
        notifyListeners();

        // 🔁 Оновлюємо бюджети з урахуванням змін
        budgetProvider.adjustBudgetsOnTransactionEdit(oldTx, updatedTx);
      }
    }
  }


}
