// Şifre değiştirme diyaloğu: mevcut şifreyle yeniden kimlik doğrular,
// alanları kontrol eder ve yeni şifreyi kaydeder.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:harcama_takip_uygulamasi/core/utils/auth_error_translator.dart';
import 'package:harcama_takip_uygulamasi/core/widgets/app_snackbar.dart';
import 'package:harcama_takip_uygulamasi/features/auth/cubit/auth_cubit.dart';

Future<void> showChangePasswordDialog(BuildContext context) async {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  final authCubit = context.read<AuthCubit>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      String? currentError;
      String? newError;
      String? confirmError;
      bool isSubmitting = false;

      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> submit() async {
            final current = currentController.text;
            final newPassword = newController.text;
            final confirm = confirmController.text;

            setDialogState(() {
              currentError = current.isEmpty ? 'Mevcut şifreni gir' : null;
              newError = newPassword.length < 6
                  ? 'En az 6 karakter olmalı'
                  : (newPassword == current
                        ? 'Yeni şifre eskisiyle aynı olamaz'
                        : null);
              confirmError = confirm != newPassword
                  ? 'Şifreler eşleşmiyor'
                  : null;
            });

            if (currentError != null ||
                newError != null ||
                confirmError != null) {
              return;
            }

            setDialogState(() => isSubmitting = true);

            try {
              await authCubit.reauthenticate(password: current);
            } on FirebaseAuthException catch (e) {
              setDialogState(() {
                isSubmitting = false;
                currentError =
                    (e.code == 'wrong-password' ||
                        e.code == 'invalid-credential')
                    ? 'Mevcut şifre yanlış.'
                    : translateAuthError(e);
              });
              return;
            } catch (e) {
              setDialogState(() {
                isSubmitting = false;
                currentError = translateAuthError(e);
              });
              return;
            }

            try {
              await authCubit.updatePassword(newPassword: newPassword);
            } catch (e) {
              setDialogState(() {
                isSubmitting = false;
                newError = translateAuthError(e);
              });
              return;
            }

            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
            if (context.mounted) {
              AppSnackBar.show(
                context,
                message: 'Şifre güncellendi.',
                icon: Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              );
            }
          }

          return AlertDialog(
            title: const Text('Şifre Değiştir'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  obscureText: true,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Mevcut şifre',
                    errorText: currentError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Yeni şifre',
                    errorText: newError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    labelText: 'Yeni şifre (tekrar)',
                    errorText: confirmError,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: isSubmitting ? null : submit,
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Kaydet'),
              ),
            ],
          );
        },
      );
    },
  );
}
