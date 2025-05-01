import 'package:hive/hive.dart';
import 'transaction.dart';

part 'budget.g.dart';

@HiveType(typeId: 0)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? category; // Категорія може бути null для загального бюджету

  @HiveField(2)
  double maxAmount;

  @HiveField(3)
  String currency;

  @HiveField(4)
  bool isGeneral; // Додано: чи це загальний бюджет

  Budget({
    required this.id,
    this.category,
    required this.maxAmount,
    required this.currency,
    this.isGeneral = false,
  });

  double getSpentAmount(List<TransactionModel> transactions) {
    return transactions
        .where((tx) {
      if (isGeneral) {
        // Загальний бюджет ➔ всі транзакції тієї ж валюти
        return tx.currency == currency;
      } else {
        // Бюджет на категорію ➔ транзакції тієї ж валюти і категорії
        return tx.category == category && tx.currency == currency;
      }
    })
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getRemainingAmount(List<TransactionModel> transactions) {
    return maxAmount - getSpentAmount(transactions);
  }

  bool isExceeded(List<TransactionModel> transactions) {
    return getRemainingAmount(transactions) < 0;
  }
}
