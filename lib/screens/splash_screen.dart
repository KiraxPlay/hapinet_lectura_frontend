// lib/screens/splash_screen.dart
import 'dart:math';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../data/database.dart';
import '../utils/constantes.dart';
import '../models/acueducto.dart';
import '../services/api/api_service.dart';
import '../services/importar_abonados_service.dart';
import '../services/asr_service.dart';
import '../services/api/tarifas_service.dart';
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
  // Animación de olas dentro de la gota
  late final AnimationController _olaCtrl;
  // Fade general de la pantalla
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  // Progreso real (0.0 → 1.0) — controla el nivel del agua en la gota
  double _progresoReal = 0.0;
  // Progreso animado suavemente hacia _progresoReal
  double _progresoAnimado = 0.0;

  String _mensajeActual = 'Iniciando...';
  int _pasoActual = 0;

  // Pasos y sus umbrales de progreso
  static const _pasos = [
    (label: 'Base de datos', umbral: 0.1),
    (label: 'Abonados', umbral: 0.5),
    (label: 'Motor OCR', umbral: 0.72),
    (label: 'Mapa offline', umbral: 0.92),
    (label: 'Motor de voz', umbral: 1.0),
  ];

  @override
  void initState() {
    super.initState();

    _olaCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

    // Animar el progreso suavemente en cada frame
    _olaCtrl.addListener(() {
      if (!mounted) return;
      final diff = _progresoReal - _progresoAnimado;
      if (diff.abs() > 0.001) {
        setState(() => _progresoAnimado += diff * 0.08);
      }
    });

    _arrancar();
  }

  void _setProgreso(String msg, double progreso, int paso) {
    if (!mounted) return;
    setState(() {
      _mensajeActual = msg;
      _progresoReal = progreso;
      _pasoActual = paso;
    });
  }

  Future<void> _arrancar() async {
    _fadeCtrl.forward();
    _setProgreso('Verificando base de datos...', 0.05, 0);
    await Future.delayed(const Duration(milliseconds: 300));

    // ASR y tarifas en background — no bloquean
    AsrService.instancia.inicializar();
    TarifasService(acueducto: widget.acueducto).sincronizar();
    ApiService(widget.acueducto)
        .sincronizarFechasPeriodoActivo(widget.db)
        .then<void>(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {
            developer.log(
              'No se pudieron actualizar localmente las fechas del período.',
              name: 'periodo.sync',
              error: error,
              stackTrace: stackTrace,
            );
          },
        );
    ApiService(widget.acueducto)
        .sincronizarNombrePeriodoActivo(widget.db)
        .then<void>(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {
            developer.log(
              'No se pudo actualizar localmente el nombre del período activo.',
              name: 'periodo.sync',
              error: error,
              stackTrace: stackTrace,
            );
          },
        );

    // Paso 1 — abonados
    _setProgreso('Cargando abonados...', 0.1, 1);
    await Future.wait([
      ImportarAbonadosService(
        db: widget.db,
        acueducto: widget.acueducto,
      ).importar(),
      Future.delayed(const Duration(milliseconds: 800)),
    ]);
    _setProgreso('Abonados listos ✓', 0.5, 1);

    // Paso 2 — OCR
    _setProgreso('Preparando OCR...', 0.55, 2);
    final ocr = OcrService();
    await Future.wait([
      ocr.precalentarModelo(),
      Future.delayed(const Duration(milliseconds: 400)),
    ]);
    ocr.dispose();
    _setProgreso('Motor OCR listo ', 0.72, 2);

    // Paso 3 — tiles
    _setProgreso('Cargando mapa offline...', 0.75, 3);
    final tiles = TilesService();
    await Future.wait([
      tiles.descargarSiNecesario(),
      Future.delayed(const Duration(milliseconds: 400)),
    ]);
    _setProgreso('Mapa listo ', 0.92, 3);

    // Paso 4 — listo
    _setProgreso('¡Todo listo!', 1.0, 4);
    await Future.delayed(const Duration(milliseconds: 700));

    if (mounted) _irAHome();
  }

  void _irAHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (_, animation, __) => FadeTransition(
              opacity: animation,
              child: HomeScreen(
                db: widget.db,
                acueducto: widget.acueducto,
                onCerrarSesion: widget.onCerrarSesion,
              ),
            ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _olaCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4FD),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con círculos decorativos
          CustomPaint(painter: _FondoSplashPainter()),

          Center(
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  _buildLogo(),
                  const SizedBox(height: 16),

                  const Text(
                    'Medidor de Agua',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.acueducto.nombre,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64B5F6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── GOTA DE AGUA ──
                  _buildGota(),

                  const SizedBox(height: 20),

                  // Mensaje animado
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _mensajeActual,
                      key: ValueKey(_mensajeActual),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Lista de pasos
                  _buildListaPasos(),
                ],
              ),
            ),
          ),

          // Versión
          const Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Text(
              'v$kVersion — $kNombreApp',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF90CAF9)),
            ),
          ),
        ],
      ),
    );
  }

  // ── GOTA DE AGUA con olas animadas ──────────────
  Widget _buildGota() {
    const size = 160.0;
    return AnimatedBuilder(
      animation: _olaCtrl,
      builder: (_, __) {
        return SizedBox(
          width: size,
          height: size * 1.15, // gota es más alta que ancha
          child: CustomPaint(
            painter: _GotaPainter(
              progreso: _progresoAnimado,
              fase: _olaCtrl.value,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Porcentaje dentro de la gota
                  Text(
                    '${(_progresoAnimado * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color:
                          _progresoAnimado > 0.5
                              ? Colors.white
                              : const Color(0xFF1565C0),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── LISTA DE PASOS ──────────────────────────────
  Widget _buildListaPasos() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 52),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            _pasos.asMap().entries.map((entry) {
              final i = entry.key;
              final paso = entry.value;
              final completo = _progresoReal >= paso.umbral;
              final activo = _pasoActual == i && !completo;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child:
                            completo
                                ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF1976D2),
                                  size: 16,
                                  key: ValueKey('check'),
                                )
                                : activo
                                ? const CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  color: Color(0xFF64B5F6),
                                  key: ValueKey('loading'),
                                )
                                : const Icon(
                                  Icons.radio_button_unchecked,
                                  color: Color(0xFFBBDEFB),
                                  size: 16,
                                  key: ValueKey('pending'),
                                ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        paso.label,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              completo
                                  ? const Color(0xFF1976D2)
                                  : activo
                                  ? const Color(0xFF42A5F5)
                                  : const Color(0xFFBBDEFB),
                          fontWeight:
                              completo || activo
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (completo)
                      const Text(
                        '✓',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  // ── LOGO ──────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 90,
      height: 90,
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
        child: Image.asset('assets/images/hapinet_icon.png', fit: BoxFit.cover),
      ),
    );
  }
}

// ── PAINTER DE LA GOTA ──────────────────────────
class _GotaPainter extends CustomPainter {
  final double progreso;
  final double fase;

  const _GotaPainter({required this.progreso, required this.fase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Forma de la gota
    final gotaPath = _buildGotaPath(w, h);

    // Fondo vacío (azul muy claro)
    canvas.drawPath(gotaPath, Paint()..color = const Color(0xFFBBDEFB));

    // Clip a la forma de la gota para el agua
    canvas.save();
    canvas.clipPath(gotaPath);

    // Nivel del agua según progreso — sube desde abajo
    final nivelY = h * 0.84 * (1.0 - progreso) + (h * 0.08);

    // Ola trasera
    final olaPath1 = _buildOlaPath(
      w,
      h,
      nivelY,
      amplitud: h * 0.03,
      frecuencia: 1.5,
      faseOffset: fase,
    );
    canvas.drawPath(
      olaPath1,
      Paint()..color = const Color(0xFF42A5F5).withOpacity(0.7),
    );

    // Ola delantera
    final olaPath2 = _buildOlaPath(
      w,
      h,
      nivelY + h * 0.02,
      amplitud: h * 0.025,
      frecuencia: 2.0,
      faseOffset: fase + 0.3,
    );
    canvas.drawPath(olaPath2, Paint()..color = const Color(0xFF1976D2));

    // Burbujas dentro del agua
    _dibujarBurbujas(canvas, w, h, nivelY);

    canvas.restore();

    // Borde de la gota
    canvas.drawPath(
      gotaPath,
      Paint()
        ..color = const Color(0xFF1565C0).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Brillo en la parte superior izquierda de la gota
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.22),
        width: w * 0.12,
        height: h * 0.06,
      ),
      Paint()..color = Colors.white.withOpacity(0.4),
    );
  }

  // Forma de gota: punta arriba, redonda abajo
  Path _buildGotaPath(double w, double h) {
    final cx = w / 2;
    final base = h * 0.92;
    final path = Path();

    // Punta superior centrada
    path.moveTo(cx, 0);

    // Lado derecho bajando con curva
    path.cubicTo(
      cx + w * 0.6,
      h * 0.35, // control 1
      cx + w * 0.5,
      h * 0.72, // control 2
      cx + w * 0.5,
      h * 0.72, // punto
    );

    // Base redondeada y convexa, como una gota completa.
    path.cubicTo(cx + w * 0.5, h * 0.84, cx + w * 0.32, base, cx, base);
    path.cubicTo(
      cx - w * 0.32,
      base,
      cx - w * 0.5,
      h * 0.84,
      cx - w * 0.5,
      h * 0.72,
    );

    // Lado izquierdo subiendo
    path.cubicTo(
      cx - w * 0.5,
      h * 0.72, // control 1
      cx - w * 0.6,
      h * 0.35, // control 2
      cx,
      0, // punta arriba
    );

    path.close();
    return path;
  }

  Path _buildOlaPath(
    double w,
    double h,
    double nivelY, {
    required double amplitud,
    required double frecuencia,
    required double faseOffset,
  }) {
    final path = Path();
    path.moveTo(0, h);
    path.lineTo(0, nivelY);

    for (double x = 0; x <= w; x += 2) {
      final y =
          nivelY +
          amplitud * sin((x / w * frecuencia * 2 * pi) + (faseOffset * 2 * pi));
      path.lineTo(x, y);
    }

    path.lineTo(w, h);
    path.close();
    return path;
  }

  void _dibujarBurbujas(Canvas canvas, double w, double h, double nivelY) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.35)
          ..style = PaintingStyle.fill;

    for (final b in [
      (rx: 0.25, ry: 0.8, r: 4.0, v: 0.8),
      (rx: 0.6, ry: 0.75, r: 3.0, v: 1.1),
      (rx: 0.4, ry: 0.88, r: 5.0, v: 0.6),
      (rx: 0.7, ry: 0.85, r: 2.5, v: 1.3),
    ]) {
      final bx = w * b.rx;
      final by =
          nivelY +
          (h - nivelY) * b.ry -
          ((h - nivelY) * 0.5 * ((fase * b.v) % 1.0));
      if (by < nivelY) continue;
      canvas.drawCircle(Offset(bx, by), b.r, paint);
    }
  }

  @override
  bool shouldRepaint(_GotaPainter old) =>
      old.progreso != progreso || old.fase != fase;
}

// ── FONDO DECORATIVO ────────────────────────────
class _FondoSplashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final c in [
      (x: 0.9, y: 0.08, r: 80.0, o: 0.12),
      (x: 0.05, y: 0.15, r: 60.0, o: 0.08),
      (x: 0.8, y: 0.88, r: 100.0, o: 0.1),
      (x: 0.1, y: 0.85, r: 70.0, o: 0.07),
      (x: 0.5, y: 0.04, r: 40.0, o: 0.06),
    ]) {
      paint.color = const Color(0xFF1976D2).withOpacity(c.o);
      canvas.drawCircle(
        Offset(size.width * c.x, size.height * c.y),
        c.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
