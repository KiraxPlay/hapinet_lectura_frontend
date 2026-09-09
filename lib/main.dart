// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/database.dart';
import 'models/acueducto.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'services/sesion_service.dart';
import 'services/api/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno desde .env
  await dotenv.load(fileName: '.env');

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
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Callback para cierre automático cuando el token expira definitivamente
    ApiService.onSesionExpirada = () async {
      if (mounted) await _cerrarSesion();
    };
    if (widget.sesionInicial != null) {
      _activarAcueducto(widget.sesionInicial!);
    }
  }

  void _activarAcueducto(Acueducto acueducto) {
    _db?.close();
    setState(() {
      _acueductoActivo = acueducto;
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
    // Limpiar todo el stack de navegación y volver al login
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/', (route) => false);
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
      navigatorKey: _navigatorKey,
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
          ? LoginScreen(
              onLogin: (acueducto) {
                _activarAcueducto(acueducto);
              },
            )
          : SplashScreen(
              db: _db!,
              acueducto: _acueductoActivo!,
              onCerrarSesion: _cerrarSesion,
            ),
    );
  }
}