// lib/main.dart
import 'package:flutter/material.dart';
import 'data/database.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MedidorApp());
}

class MedidorApp extends StatelessWidget {
  final AppDatabase db = AppDatabase();
  MedidorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medidores de Agua',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Arranca en el splash — él navega a HomeScreen al terminar
      home: SplashScreen(db: db),
    );
  }
}