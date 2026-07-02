// lib/screens/splash_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import '../services/importar_abonados_service.dart';
import '../services/ocr_service.dart';
import '../services/tiles_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final AppDatabase db;
  final Acueducto acueducto;
  final VoidCallback onCerrarSesion;

  const SplashScreen({
    super.key,
    required this.db,
    required this.acueducto,
    required this.onCerrarSesion,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animación del progreso de carga ──
  late final AnimationController _progresoCtrl;
  late final Animation<double> _progreso;

  // ── Animación de las olas dentro de la barra ──
  late final AnimationController _olaCtrl;

  // ── Animación de fade del logo ──
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // Progreso: 0 → 1 en 3 segundos con curva suave
    _progresoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _progreso = CurvedAnimation(
      parent: _progresoCtrl,
      curve: Curves.easeInOut,
    );

    // Olas: loop infinito mientras carga
    _olaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // Fade del logo: aparece en 800ms
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    _arrancar();
  }

  Future<void> _arrancar() async {
    _fadeCtrl.forward();
    _progresoCtrl.forward();

    final ocr = OcrService();
    final tiles = TilesService();

    // Todo en paralelo mientras se muestra la animación:
    // 1. Importar abonados del JSON a la BD
    // 2. Pre-calentar el modelo OCR
    // 3. Pre-descargar tiles de Gigante, Huila (solo la primera vez)
    // 4. Esperar el tiempo mínimo de la animación
    await Future.wait([
      ImportarAbonadosService(
        db: widget.db,
        jsonAsset: widget.acueducto.jsonAsset,
        acueductoId: widget.acueducto.tipo.name,
      ).importar(),
      ocr.precalentarModelo(),
      tiles.descargarSiNecesario(),
      Future.delayed(const Duration(milliseconds: 3200)),
    ]);

    ocr.dispose();

    if (mounted) _irAHome();
  }

  void _irAHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => FadeTransition(
          opacity: animation,
          child: HomeScreen(db: widget.db, acueducto: widget.acueducto, onCerrarSesion: widget.onCerrarSesion),
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _progresoCtrl.dispose();
    _olaCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FD),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fondo con gotas decorativas ──
          CustomPaint(painter: _FondoSplashPainter()),

          // ── Contenido centrado ──
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono / logo
                  _buildLogo(),
                  const SizedBox(height: 16),

                  // Nombre de la app
                  const Text(
                    'Medidores de Agua',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Lectura inteligente offline',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64B5F6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Barra de carga con textura de agua ──
                  _buildBarraAgua(size),
                  const SizedBox(height: 16),

                  // Texto de estado
                  AnimatedBuilder(
                    animation: _progreso,
                    builder: (_, __) => Text(
                      _mensajeCarga(_progreso.value),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64B5F6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Versión en esquina inferior ──
          const Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF90CAF9)),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // LOGO
  // ─────────────────────────────────────────────

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/hapinet_icon.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BARRA DE AGUA
  // ─────────────────────────────────────────────

  Widget _buildBarraAgua(Size size) {
    final barraAncho = size.width * 0.72;
    const barraAlto = 28.0;

    return AnimatedBuilder(
      animation: Listenable.merge([_progreso, _olaCtrl]),
      builder: (_, __) {
        return SizedBox(
          width: barraAncho,
          height: barraAlto,
          child: Stack(
            children: [
              // Fondo de la barra (pista vacía)
              Container(
                width: barraAncho,
                height: barraAlto,
                decoration: BoxDecoration(
                  color: const Color(0xFFBBDEFB),
                  borderRadius: BorderRadius.circular(barraAlto / 2),
                ),
              ),

              // Relleno de agua con olas
              ClipRRect(
                borderRadius: BorderRadius.circular(barraAlto / 2),
                child: SizedBox(
                  width: barraAncho,
                  height: barraAlto,
                  child: CustomPaint(
                    painter: _AguaPainter(
                      progreso: _progreso.value,
                      fase: _olaCtrl.value,
                    ),
                  ),
                ),
              ),

              // Brillo encima de la barra
              Container(
                width: barraAncho,
                height: barraAlto / 2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(barraAlto / 2),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Borde de la barra
              Container(
                width: barraAncho,
                height: barraAlto,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(barraAlto / 2),
                  border: Border.all(
                    color: const Color(0xFF1976D2).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),

              // Porcentaje centrado
              Center(
                child: Text(
                  '${(_progreso.value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _progreso.value > 0.45
                        ? Colors.white
                        : const Color(0xFF1565C0),
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _mensajeCarga(double progreso) {
    if (progreso < 0.3) return 'Iniciando base de datos...';
    if (progreso < 0.6) return 'Cargando servicios...';
    if (progreso < 0.9) return 'Preparando interfaz...';
    return '¡Listo!';
  }
}

// ─────────────────────────────────────────────
// PAINTER: AGUA CON OLAS
// ─────────────────────────────────────────────

class _AguaPainter extends CustomPainter {
  final double progreso; // 0.0 → 1.0
  final double fase;     // 0.0 → 1.0 loop de animación

  const _AguaPainter({required this.progreso, required this.fase});

  @override
  void paint(Canvas canvas, Size size) {
    final anchoRelleno = size.width * progreso;
    if (anchoRelleno <= 0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    // ── Color base del agua ──
    paint.color = const Color(0xFF1976D2);
    canvas.drawRect(Rect.fromLTWH(0, 0, anchoRelleno, size.height), paint);

    // ── Ola 1 (delantera, más visible) ──
    paint.color = const Color(0xFF42A5F5);
    final path1 = _buildOla(
      size: size,
      anchoRelleno: anchoRelleno,
      amplitud: size.height * 0.35,
      frecuencia: 1.8,
      fase: fase,
      offsetY: size.height * 0.3,
    );
    canvas.drawPath(path1, paint);

    // ── Ola 2 (trasera, más oscura) ──
    paint.color = const Color(0xFF1565C0).withOpacity(0.6);
    final path2 = _buildOla(
      size: size,
      anchoRelleno: anchoRelleno,
      amplitud: size.height * 0.25,
      frecuencia: 2.2,
      fase: fase + 0.4, // desfasada
      offsetY: size.height * 0.5,
    );
    canvas.drawPath(path2, paint);

    // ── Burbujas pequeñas ──
    _dibujarBurbujas(canvas, anchoRelleno, size.height, fase);
  }

  Path _buildOla({
    required Size size,
    required double anchoRelleno,
    required double amplitud,
    required double frecuencia,
    required double fase,
    required double offsetY,
  }) {
    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= anchoRelleno; x++) {
      final y = offsetY +
          amplitud * sin((x / size.width * frecuencia * 2 * pi) +
              (fase * 2 * pi));
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(anchoRelleno, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  void _dibujarBurbujas(
      Canvas canvas, double anchoRelleno, double alto, double fase) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Posiciones fijas de burbujas — se mueven verticalmente con la fase
    final burbujas = [
      _Burbuja(xPct: 0.15, radio: 2.5, velocidad: 1.0),
      _Burbuja(xPct: 0.35, radio: 2.0, velocidad: 0.7),
      _Burbuja(xPct: 0.55, radio: 3.0, velocidad: 1.2),
      _Burbuja(xPct: 0.72, radio: 1.8, velocidad: 0.9),
      _Burbuja(xPct: 0.88, radio: 2.2, velocidad: 1.1),
    ];

    for (final b in burbujas) {
      final x = anchoRelleno * b.xPct;
      if (x > anchoRelleno) continue;

      // Movimiento vertical cíclico
      final y = alto * 0.8 -
          (alto * 0.6 * ((fase * b.velocidad) % 1.0));

      canvas.drawCircle(Offset(x, y), b.radio, paint);
    }
  }

  @override
  bool shouldRepaint(_AguaPainter old) =>
      old.progreso != progreso || old.fase != fase;
}

class _Burbuja {
  final double xPct;
  final double radio;
  final double velocidad;
  const _Burbuja(
      {required this.xPct, required this.radio, required this.velocidad});
}

// ─────────────────────────────────────────────
// PAINTER: FONDO DEL SPLASH
// ─────────────────────────────────────────────

class _FondoSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Círculos decorativos de fondo
    final circulos = [
      _CirculoDeco(x: 0.9, y: 0.08, radio: 80, opacidad: 0.15),
      _CirculoDeco(x: 0.05, y: 0.15, radio: 60, opacidad: 0.1),
      _CirculoDeco(x: 0.8, y: 0.85, radio: 100, opacidad: 0.12),
      _CirculoDeco(x: 0.1, y: 0.88, radio: 70, opacidad: 0.08),
      _CirculoDeco(x: 0.5, y: 0.05, radio: 40, opacidad: 0.07),
    ];

    for (final c in circulos) {
      paint.color = const Color(0xFF1976D2).withOpacity(c.opacidad);
      canvas.drawCircle(
        Offset(size.width * c.x, size.height * c.y),
        c.radio,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_FondoSplashPainter _) => false;
}

class _CirculoDeco {
  final double x, y, radio, opacidad;
  const _CirculoDeco(
      {required this.x,
      required this.y,
      required this.radio,
      required this.opacidad});
}