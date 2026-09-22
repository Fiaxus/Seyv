import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('themeMode');
    if (saved == 'light') {
      emit(ThemeMode.light);
    } else if (saved == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }
}