// Giriş noktası: Firebase ve tarih yerelleştirmesini başlatır, ardından
// app/app.dart içindeki MyApp'i çalıştırır.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:harcama_takip_uygulamasi/app/app.dart';
import 'package:harcama_takip_uygulamasi/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('tr_TR', null);
  runApp(const MyApp());
}