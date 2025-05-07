import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String currency;

  @HiveField(4)
  final String category;

  @HiveField(5)
  final String title;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.currency,
    required this.category,
    required this.title,
  });

  TransactionModel copyWith({
    String? id,
    double? amount,
    DateTime? date,
    String? currency,
    String? category,
    String? title,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      title: title ?? this.title,
    );
  }
}
