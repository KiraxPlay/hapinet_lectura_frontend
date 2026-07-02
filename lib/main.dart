// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/database.dart';
import 'models/acueducto.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/sesion_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación solo vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Verificar si hay sesión activa guardada
  final sesion = await SesionService.sesionActiva();

  runApp(MedidorApp(sesionInicial: sesion));
}

class MedidorApp extends StatefulWidget {
  final Acueducto? sesionInicial;
  const MedidorApp({super.key, this.sesionInicial});

  @override
  State<MedidorApp> createState() => _MedidorAppState();
}

class _MedidorAppState extends State<MedidorApp> {
  Acueducto? _acueductoActivo;
  AppDatabase? _db;

  @override
  void initState() {
    super.initState();
    if (widget.sesionInicial != null) {
      _activarAcueducto(widget.sesionInicial!);
    }
  }

  // Crea la BD específica del acueducto y activa la sesión
  void _activarAcueducto(Acueducto acueducto) {
    _db?.close();
    setState(() {
      _acueductoActivo = acueducto;
      // Cada acueducto tiene su propia BD separada
      _db = AppDatabase(nombreBd: acueducto.nombreBd);
    });
  }

  Future<void> _cerrarSesion() async {
    await SesionService.cerrarSesion();
    _db?.close();
    setState(() {
      _acueductoActivo = null;
      _db = null;
    });
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medidor Hapinet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _acueductoActivo != null
              ? Color(int.parse(
                  '0xFF${_acueductoActivo!.colorHex.replaceAll('#', '')}'))
              : const Color(0xFF1565C0),
        ),
        useMaterial3: true,
      ),
      home: _acueductoActivo == null
          // Sin sesión → pantalla de login
          ? LoginScreen(
              onLogin: (acueducto) {
                _activarAcueducto(acueducto);
              },
            )
          // Con sesión → splash que importa abonados y va al home
          : SplashScreen(
              db: _db!,
              acueducto: _acueductoActivo!,
              onCerrarSesion: _cerrarSesion,
            ),
    );
  }
}