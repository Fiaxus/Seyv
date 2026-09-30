// Aylık bütçe veya kategori limiti için tutar giriş diyaloğu. Alt/üst
// sınırı yazarken doğrular; "Tamam" ile girilen tutarı döner.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../budget_formatters.dart';

Future<double?> showAmountInputDialog(
  BuildContext context, {
  required String title,
  required double initial,
  double min = 0,
  double? max,
  String? helper,
  String? maxError,
}) {
  final controller = TextEditingController(
    text: initial > 0 ? plainAmount(initial) : '',
  );
  String? error;

  return showDialog<double>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          void validate() {
            final value = double.tryParse(controller.text) ?? 0;
            if (max != null && value > max) {
              error =
                  maxError ?? 'En fazla ${groupedAmount(max)} ₺ girebilirsin.';
            } else if (value < min) {
              error =
                  'Aylık bütçe, kategorilere dağıtılan ${groupedAmount(min)} ₺ '
                  'tutarından az olamaz.';
            } else {
              error = null;
            }
          }

          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setDialogState(validate),
              decoration: InputDecoration(
                suffixText: '₺',
                helperText: helper,
                helperMaxLines: 2,
                errorText: error,
                errorMaxLines: 3,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Vazgeç'),
              ),
              TextButton(
                onPressed: error != null
                    ? null
                    : () => Navigator.of(
                        dialogContext,
                      ).pop(double.tryParse(controller.text) ?? 0),
                child: const Text('Tamam'),
              ),
            ],
          );
        },
      );
    },
  );
}
