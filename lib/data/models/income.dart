import 'package:hive/hive.dart';

part 'income.g.dart';

@HiveType(typeId: 3)
class IncomeModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String currency;

  @HiveField(5)
  final String category; // ✅ ДОДАЙ ЦЕ

  IncomeModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.currency,
    required this.category, // ✅ ДОДАЙ ЦЕ
  });

  IncomeModel copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? currency,
    String? category, // ✅ ДОДАЙ ЦЕ
  }) {
    return IncomeModel(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      currency: currency ?? this.currency,
      category: category ?? this.category, // ✅ ДОДАЙ ЦЕ
    );
  }
}

