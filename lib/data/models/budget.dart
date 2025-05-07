import 'package:hive/hive.dart';
import 'transaction.dart';

part 'budget.g.dart';

@HiveType(typeId: 1) // ✅ змінено з 0 на 1
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? category;

  @HiveField(2)
  double maxAmount;

  @HiveField(3)
  String currency;

  @HiveField(4)
  bool isGeneral;

  @HiveField(5)
  DateTime? lastReset;

  Budget({
    required this.id,
    this.category,
    required this.maxAmount,
    required this.currency,
    this.isGeneral = false,
  });

  double getSpentAmount(List<TransactionModel> transactions) {
    return transactions.where((tx) {
      if (isGeneral) {
        return tx.currency == currency;
      } else {
        return tx.category == category && tx.currency == currency;
      }
    }).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getRemainingAmount(List<TransactionModel> transactions) {
    return maxAmount - getSpentAmount(transactions);
  }

  bool isExceeded(List<TransactionModel> transactions) {
    return getRemainingAmount(transactions) < 0;
  }
}
