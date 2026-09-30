// Tek seçimli alt sayfa: en üstte seçimi temizleyen satır, altında
// seçenekler. Ay, kategori ve para birimi çiplerinin ortak seçicisi.
import 'package:flutter/material.dart';

// Sayfadan yapılan seçim. value null ise "temizle" satırı seçilmiştir.
class PickedOption<T> {
  final T? value;

  const PickedOption(this.value);
}

// Sayfa seçim yapılmadan kapatılırsa null döner.
Future<PickedOption<T>?> showOptionPickerSheet<T>(
  BuildContext context, {
  required String clearLabel,
  required List<T> options,
  required String Function(T option) labelOf,
}) {
  return showModalBottomSheet<PickedOption<T>>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(clearLabel),
              onTap: () => Navigator.of(context).pop(PickedOption<T>(null)),
            ),
            for (final option in options)
              ListTile(
                title: Text(labelOf(option)),
                onTap: () => Navigator.of(context).pop(PickedOption<T>(option)),
              ),
          ],
        ),
      );
    },
  );
}
