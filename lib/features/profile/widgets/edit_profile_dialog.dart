// Ad soyad ve e-posta düzenleme diyaloğu. Alanları doğrular; kaydedilirse
// girilen değerleri döner, vazgeçilirse null döner.
import 'package:flutter/material.dart';

Future<({String name, String email})?> showEditProfileDialog(
  BuildContext context, {
  required String initialName,
  required String initialEmail,
}) async {
  final nameController = TextEditingController(text: initialName);
  final emailController = TextEditingController(text: initialEmail);
  String? nameError;
  String? emailError;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Profili Düzenle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Ad Soyad',
                    errorText: nameError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    errorText: emailError,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  setDialogState(() {
                    nameError = name.isEmpty ? 'Ad Soyad boş olamaz' : null;
                    emailError = (email.isEmpty || !email.contains('@'))
                        ? 'Geçerli bir e-posta girin'
                        : null;
                  });
                  if (nameError == null && emailError == null) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: const Text('Kaydet'),
              ),
            ],
          );
        },
      );
    },
  );

  if (confirmed != true) return null;
  return (
    name: nameController.text.trim(),
    email: emailController.text.trim(),
  );
}
