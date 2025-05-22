import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CurrencyService {
  static Future<Map<String, double>> fetchRates(String base) async {
    final apiKey = dotenv.env['CURRENCY_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API ключ не знайдено в .env файлі');
    }

    final url = Uri.parse('https://api.freecurrencyapi.com/v1/latest?apikey=$apiKey&base_currency=$base');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final raw = Map<String, dynamic>.from(data['data']);
      final rates = raw.map((key, value) => MapEntry(key, (value as num).toDouble()));
      return rates;
    } else {
      throw Exception('Помилка при отриманні курсу валют');
    }
  }
}
