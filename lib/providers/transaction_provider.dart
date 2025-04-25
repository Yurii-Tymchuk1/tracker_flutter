import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/transaction.dart';

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
}
