import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:harcama_takip_uygulamasi/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'blocs/auth/auth_cubit.dart';

import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('tr_TR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Harcama Takip Uygulaması',

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,

        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
