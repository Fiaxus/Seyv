// "Şifremi unuttum" diyaloğu: sıfırlama bağlantısının gönderileceği
// e-postayı sorar. Geçerli bir adres girilirse onu döner, vazgeçilirse null.
import 'package:flutter/material.dart';

Future<String?> showForgotPasswordDialog(
  BuildContext context, {
  required String initialEmail,
}) {
  final controller = TextEditingController(text: initialEmail);
  bool showError = false;

  return showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Şifremi Unuttum'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Şifre sıfırlama bağlantısı gönderilecek e-posta adresini girin.',
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'ornek@mail.com',
                    errorText: showError ? 'Geçerli bir e-posta girin' : null,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () {
                  final value = controller.text.trim();
                  if (value.isEmpty || !value.contains('@')) {
                    setDialogState(() {
                      showError = true;
                    });
                    return;
                  }
                  Navigator.of(context).pop(value);
                },
                child: const Text('Gönder'),
              ),
            ],
          );
        },
      );
    },
  );
}
