// Hassas işlemlerden (e-posta değiştirme, hesap silme) önce kullanıcıdan
// şifresini tekrar isteyen diyalog. Girilen şifreyi döner, vazgeçilirse null.
import 'package:flutter/material.dart';

Future<String?> showPasswordConfirmDialog(
  BuildContext context, {
  required String reason,
}) async {
  final controller = TextEditingController();
  bool showError = false;

  return showDialog<String>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Şifreni Doğrula'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reason),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Şifre',
                    errorText: showError ? 'Şifre boş olamaz' : null,
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
                  if (controller.text.isEmpty) {
                    setDialogState(() {
                      showError = true;
                    });
                    return;
                  }
                  Navigator.of(context).pop(controller.text);
                },
                child: const Text('Onayla'),
              ),
            ],
          );
        },
      );
    },
  );
}
