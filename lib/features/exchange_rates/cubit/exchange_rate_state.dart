sealed class ExchangeRateState {}

class ExchangeRateInitial extends ExchangeRateState {}

class ExchangeRateLoading extends ExchangeRateState {}

class ExchangeRateLoaded extends ExchangeRateState {
  final Map<String, double> rates;

  ExchangeRateLoaded(this.rates);
}

class ExchangeRateError extends ExchangeRateState {
  final String message;

  ExchangeRateError(this.message);
}