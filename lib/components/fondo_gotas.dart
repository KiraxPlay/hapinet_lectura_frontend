// lib/components/fondo_gotas.dart
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Widget reutilizable de fondo con gotas de agua
// Uso:
//   FondoConGotas(child: tuWidget)
//   FondoConGotas(colorGota: Colors.blue.withOpacity(0.08), child: tuWidget)
// ─────────────────────────────────────────────

class FondoConGotas extends StatelessWidget {
  final Widget child;
  final Color? colorFondo;
  final Color? colorGota;

  const FondoConGotas({
    super.key,
    required this.child,
    this.colorFondo,
    this.colorGota,
  });

  @override
  Widget build(BuildContext context) {
    final fondo = colorFondo ?? Theme.of(context).colorScheme.surface;
    final gota =
        colorGota ?? Theme.of(context).colorScheme.primary.withOpacity(0.06);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: fondo),
        // RepaintBoundary evita que las gotas se redibuje con cada setState
        RepaintBoundary(
          child: CustomPaint(
            painter: _GotasPainter(colorGota: gota),
            child: const SizedBox.expand(),
          ),
        ),
        child,
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Painter — dibuja las gotas una sola vez
// ─────────────────────────────────────────────
class _GotasPainter extends CustomPainter {
  final Color colorGota;
  const _GotasPainter({required this.colorGota});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorGota
      ..style = PaintingStyle.fill;

    for (final g in _gotas) {
      _dibujarGota(canvas, paint,
          Offset(size.width * g.x, size.height * g.y), g.radio.toDouble());
    }
  }

  void _dibujarGota(Canvas canvas, Paint paint, Offset c, double r) {
    final path = Path();
    path.addOval(Rect.fromCircle(center: c, radius: r));
    path.moveTo(c.dx, c.dy - r);
    path.quadraticBezierTo(
        c.dx + r * 0.6, c.dy - r * 1.4, c.dx, c.dy - r * 2.2);
    path.quadraticBezierTo(
        c.dx - r * 0.6, c.dy - r * 1.4, c.dx, c.dy - r);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GotasPainter old) => old.colorGota != colorGota;

  // Posiciones en porcentaje de pantalla — ajusta aquí si quieres más/menos gotas
  static const _gotas = [
    _Gota(x: 0.08, y: 0.05, radio: 18),
    _Gota(x: 0.85, y: 0.03, radio: 12),
    _Gota(x: 0.45, y: 0.08, radio: 22),
    _Gota(x: 0.20, y: 0.18, radio: 10),
    _Gota(x: 0.70, y: 0.14, radio: 16),
    _Gota(x: 0.92, y: 0.22, radio: 9),
    _Gota(x: 0.05, y: 0.35, radio: 14),
    _Gota(x: 0.55, y: 0.28, radio: 20),
    _Gota(x: 0.33, y: 0.42, radio: 11),
    _Gota(x: 0.78, y: 0.38, radio: 17),
    _Gota(x: 0.15, y: 0.55, radio: 13),
    _Gota(x: 0.88, y: 0.52, radio: 21),
    _Gota(x: 0.48, y: 0.60, radio: 9),
    _Gota(x: 0.25, y: 0.70, radio: 16),
    _Gota(x: 0.65, y: 0.65, radio: 12),
    _Gota(x: 0.90, y: 0.72, radio: 10),
    _Gota(x: 0.10, y: 0.80, radio: 19),
    _Gota(x: 0.50, y: 0.78, radio: 14),
    _Gota(x: 0.35, y: 0.88, radio: 11),
    _Gota(x: 0.75, y: 0.85, radio: 18),
    _Gota(x: 0.60, y: 0.94, radio: 13),
    _Gota(x: 0.20, y: 0.95, radio: 8),
  ];
}

class _Gota {
  final double x, y;
  final int radio;
  const _Gota({required this.x, required this.y, required this.radio});
}