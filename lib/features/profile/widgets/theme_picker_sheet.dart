// Tema seçimi (Açık / Koyu / Sistem) için alt sayfa ve tema modunun
// ekranda gösterilen Türkçe etiketi.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:harcama_takip_uygulamasi/core/theme/theme_cubit.dart';

String themeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'Açık';
    case ThemeMode.dark:
      return 'Koyu';
    case ThemeMode.system:
      return 'Sistem';
  }
}

Future<void> showThemePickerSheet(BuildContext context) async {
  final themeCubit = context.read<ThemeCubit>();
  final currentMode = themeCubit.state;

  final selected = await showModalBottomSheet<ThemeMode>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in ThemeMode.values)
              ListTile(
                title: Text(themeLabel(mode)),
                trailing: mode == currentMode ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(context).pop(mode),
              ),
          ],
        ),
      );
    },
  );

  if (selected != null) {
    await themeCubit.setTheme(selected);
  }
}
