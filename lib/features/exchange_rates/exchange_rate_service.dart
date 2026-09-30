import 'dart:convert';

import 'package:http/http.dart' as http;

class ExchangeRateService {
  static const _baseUrl = 'https://api.frankfurter.dev/v1/latest';

  Future<Map<String, double>> getRates(List<String> currencyCodes) async {
    final symbols = currencyCodes.join(',');
    final url = Uri.parse('$_baseUrl?base=TRY&symbols=$symbols');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Kurlar alınamadı (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final rates = data['rates'] as Map<String, dynamic>;

    final Map<String, double> result = {};
    rates.forEach((code, value) {
      result[code] = 1 / (value as num).toDouble();
    });

    return result;
  }
}