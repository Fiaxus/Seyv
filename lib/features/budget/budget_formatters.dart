// Bütçe planı ekranı ve widget'larının ortak kullandığı görüntüleme
// biçimlendiricileri (tutar ve yüzde metinleri).
import 'package:intl/intl.dart';

// Binlik ayırıcı olmadan tam sayı: 12500 -> "12500"
String plainAmount(double value) => value.round().toString();

// Binlik ayırıcılı tam sayı: 12500 -> "12.500"
String groupedAmount(double value) =>
    NumberFormat.decimalPattern('tr_TR').format(value.round());

// Yüzdeyi Türkçe iyelik ekiyle yazar: 25 -> "Bütçenin %25'i"
String budgetPercentText(int percent) {
  final p = percent.clamp(0, 100);
  const tens = {
    0: 'ı',
    10: 'u',
    20: 'si',
    30: 'u',
    40: 'ı',
    50: 'si',
    60: 'ı',
    70: 'i',
    80: 'i',
    90: 'ı',
  };
  const ones = {
    1: 'i',
    2: 'si',
    3: 'ü',
    4: 'ü',
    5: 'i',
    6: 'sı',
    7: 'si',
    8: 'i',
    9: 'u',
  };

  final String suffix;
  if (p == 100) {
    suffix = 'ü';
  } else if (p % 10 == 0) {
    suffix = tens[p]!;
  } else {
    suffix = ones[p % 10]!;
  }
  return "Bütçenin %$p'$suffix";
}
