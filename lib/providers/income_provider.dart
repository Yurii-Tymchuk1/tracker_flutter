import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../data/models/income.dart';

class IncomeProvider with ChangeNotifier {
  final Box<IncomeModel> _incomeBox = Hive.box<IncomeModel>('incomes');

  List<IncomeModel> get incomes => _incomeBox.values.toList();

  Future<void> addIncome(IncomeModel income) async {
    await _incomeBox.put(income.id, income);
    notifyListeners();
  }

  Future<void> deleteIncome(IncomeModel income) async {
    await _incomeBox.delete(income.id);
    notifyListeners();
  }

  double getTotalIncomeByCurrency(String currency) {
    return incomes
        .where((income) => income.currency == currency)
        .fold(0.0, (sum, i) => sum + i.amount);
  }

  Future<void> updateIncome(IncomeModel updated) async {
    final keyToUpdate = _incomeBox.keys.firstWhere(
          (key) => _incomeBox.get(key)?.id == updated.id,
      orElse: () => null,
    );

    if (keyToUpdate != null) {
      await _incomeBox.put(keyToUpdate, updated);
      notifyListeners(); // оновлює графіки, списки, суми тощо
    }
  }



}
