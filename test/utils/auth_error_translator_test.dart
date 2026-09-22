import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harcama_takip_uygulamasi/utils/auth_error_translator.dart';

void main() {
  group('translateAuthError', () {
    test('email-already-in-use doğru mesajı döner', () {
      final error = FirebaseAuthException(code: 'email-already-in-use');
      expect(
        translateAuthError(error),
        'Bu e-posta adresi zaten kullanımda.',
      );
    });

    test('wrong-password ve invalid-credential aynı mesajı döner', () {
      final wrongPassword = FirebaseAuthException(code: 'wrong-password');
      final invalidCredential = FirebaseAuthException(
        code: 'invalid-credential',
      );
      expect(
        translateAuthError(wrongPassword),
        translateAuthError(invalidCredential),
      );
    });

    test('bilinmeyen bir kod için genel mesaj döner', () {
      final error = FirebaseAuthException(code: 'bilinmeyen-kod-123');
      expect(translateAuthError(error), 'Bir hata oluştu, lütfen tekrar deneyin.');
    });

    test('FirebaseAuthException olmayan bir hata için de genel mesaj döner', () {
      final error = Exception('rastgele bir hata');
      expect(translateAuthError(error), 'Bir hata oluştu, lütfen tekrar deneyin.');
    });
  });
}