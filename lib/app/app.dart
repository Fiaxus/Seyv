// Uygulamanın kök widget'ı: global Cubit'leri sağlar, temayı ve
// go_router yapılandırmasını MaterialApp'e bağlar.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:harcama_takip_uygulamasi/app/app_router.dart';
import 'package:harcama_takip_uygulamasi/core/theme/app_theme.dart';
import 'package:harcama_takip_uygulamasi/core/theme/theme_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/auth/cubit/auth_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/budget/cubit/budget_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/exchange_rates/cubit/exchange_rate_cubit.dart';
import 'package:harcama_takip_uygulamasi/features/expenses/cubit/expense_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => ExpenseCubit()),
        BlocProvider(create: (context) => BudgetCubit()),
        BlocProvider(create: (context) => ExchangeRateCubit()),
        BlocProvider(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Harcama Takip Uygulaması',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
