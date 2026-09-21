import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/exchange_rate_repository.dart';
import 'exchange_rate_state.dart';

class ExchangeRateCubit extends Cubit<ExchangeRateState> {
  final ExchangeRateRepository _repository = ExchangeRateRepository();

  ExchangeRateCubit() : super(ExchangeRateInitial());

  Future<void> loadRates(List<String> currencyCodes) async {
    emit(ExchangeRateLoading());
    try {
      final rates = await _repository.getRates(currencyCodes);
      emit(ExchangeRateLoaded(rates));
    } catch (e) {
      emit(ExchangeRateError(e.toString()));
    }
  }
}