import '../services/exchange_rate_service.dart';

class ExchangeRateRepository {
  final ExchangeRateService _service = ExchangeRateService();

  Future<Map<String, double>> getRates(List<String> currencyCodes) {
    return _service.getRates(currencyCodes);
  }
}