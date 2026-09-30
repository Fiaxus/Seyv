// Döviz kurları ekranında listelenen para birimlerinin kodu ve Türkçe adı.
class CurrencyInfo {
  final String code;
  final String name;

  const CurrencyInfo(this.code, this.name);
}

const supportedCurrencies = [
  CurrencyInfo('USD', 'Amerikan Doları'),
  CurrencyInfo('EUR', 'Euro'),
  CurrencyInfo('GBP', 'İngiliz Sterlini'),
  CurrencyInfo('CHF', 'İsviçre Frangı'),
];
