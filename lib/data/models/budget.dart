import 'package:hive/hive.dart';
import 'transaction.dart';

part 'budget.g.dart';

@HiveType(typeId: 0)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String category;

  @HiveField(2)
  double maxAmount;

  @HiveField(3)
  String currency;

  Budget({
    required this.id,
    required this.category,
    required this.maxAmount,
    required this.currency,
  });

  double getSpentAmount(List<TransactionModel> transactions) {
    return transactions
        .where((tx) => tx.category == category)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getRemainingAmount(List<TransactionModel> transactions) {
    return maxAmount - getSpentAmount(transactions);
  }

  bool isExceeded(List<TransactionModel> transactions) {
    return getRemainingAmount(transactions) < 0;
  }
}
