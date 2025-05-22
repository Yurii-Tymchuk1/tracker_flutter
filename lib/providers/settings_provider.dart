import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../services/currency_service.dart';

class SettingsProvider with ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _baseCurrencyKey = 'baseCurrency';
  static const String _ratesKey = 'currencyRates';

  String _baseCurrency = 'EUR';
  Map<String, double> _rates = {};

  String get baseCurrency => _baseCurrency;
  Map<String, double> get rates => _rates;

  SettingsProvider() {
    _loadBaseCurrency().then((_) => updateRates());
  }

  Future<void> _loadBaseCurrency() async {
    final box = await Hive.openBox(_boxName);
    _baseCurrency = box.get(_baseCurrencyKey, defaultValue: 'EUR');

    final rawRates = Map<String, dynamic>.from(box.get(_ratesKey, defaultValue: {}));
    _rates = rawRates.map((key, value) => MapEntry(key, (value as num).toDouble()));

    notifyListeners();
  }

  Future<void> setBaseCurrency(String currency) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_baseCurrencyKey, currency);
    _baseCurrency = currency;
    notifyListeners();

    await updateRates();
  }

  Future<void> updateRates() async {
    try {
      final newRates = await CurrencyService.fetchRates(_baseCurrency);

      final box = await Hive.openBox(_boxName);
      await box.put(_ratesKey, newRates);
      _rates = newRates;

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Помилка завантаження курсів валют: $e');
    }
  }

  double convert(double amount, String fromCurrency) {
    if (fromCurrency == _baseCurrency) return amount;
    if (!_rates.containsKey(fromCurrency)) return amount;
    return amount / (_rates[fromCurrency] ?? 1);
  }
}
