// lib/screens/info_abonado_screen.dart
import 'package:flutter/material.dart';
import '../data/database.dart';
import '../components/fondo_gotas.dart';
import '../models/estado_medidor.dart';
import 'captura_screen.dart';

/// Pantalla intermedia que muestra info del abonado
/// ANTES de abrir la cámara para tomar la lectura.
///
/// Flujo:
///   lecturas_dia_screen o mapa_screen
///       → InfoAbonadoScreen  (esta pantalla)
///           → CapturaScreen  (cámara)
class InfoAbonadoScreen extends StatelessWidget {
  final AppDatabase db;
  final String? codigoMedidor;
  final String? nombreAbonado;
  final String? celular;
  final int? lecturaAnterior;
  final double? latitud;
  final double? longitud;
  final String? sector;
  final String? estadoMedidorClave; // último estado reportado

  const InfoAbonadoScreen({
    super.key,
    required this.db,
    this.codigoMedidor,
    this.nombreAbonado,
    this.celular,
    this.lecturaAnterior,
    this.latitud,
    this.longitud,
    this.sector,
    this.estadoMedidorClave,
  });

  // ── Helpers de color/nombre por sector ──
  Color get _colorSector => switch (sector) {
        'TENDIDO' => const Color(0xFF1976D2),
        'RECREO' => const Color(0xFF388E3C),
        'PUEBLO NUEVO' => const Color(0xFF7B1FA2),
        _ => const Color(0xFF607D8B),
      };

  String get _nombreSector => switch (sector) {
        'TENDIDO' => 'El Tendido',
        'RECREO' => 'El Recreo',
        'PUEBLO NUEVO' => 'Pueblo Nuevo',
        _ => 'Sin sector',
      };

  EstadoMedidor? get _estado =>
      EstadoMedidor.desdeClave(estadoMedidorClave);

  // ── Navegar a la cámara ──
  Future<void> _irACaptura(BuildContext context) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CapturaScreen(
          db: db,
          codigoMedidor: codigoMedidor,
          nombreAbonado: nombreAbonado,
          lecturaAnterior: lecturaAnterior,
          latitudReferencia: latitud,
          longitudReferencia: longitud,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información del abonado'),
        backgroundColor: _colorSector,
        foregroundColor: Colors.white,
      ),
      body: FondoConGotas(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Avatar + nombre + sector ──────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _colorSector.withOpacity(0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _colorSector.withOpacity(0.4),
                            width: 2),
                      ),
                      child: Center(
                        child: Text(
                          (sector ?? 'O')[0],
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: _colorSector,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nombreAbonado ?? 'Sin nombre',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Badge sector
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _colorSector.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _colorSector.withOpacity(0.3)),
                      ),
                      child: Text(
                        _nombreSector,
                        style: TextStyle(
                          color: _colorSector,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Tarjeta de datos ──────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    // Código
                    _fila(
                      icono: Icons.qr_code,
                      label: 'Código medidor',
                      valor: codigoMedidor ?? 'Sin código',
                      color: _colorSector,
                    ),
                    _divisor(),

                    // Celular
                    _fila(
                      icono: Icons.phone_outlined,
                      label: 'Celular',
                      valor: celular ?? 'Sin registrar',
                      color: celular != null
                          ? Colors.green
                          : Colors.grey,
                    ),
                    _divisor(),

                    // Lectura anterior
                    _fila(
                      icono: Icons.history,
                      label: 'Lectura anterior',
                      valor: lecturaAnterior != null
                          ? lecturaAnterior.toString()
                          : 'Sin lectura registrada',
                      color: _colorSector,
                      valorGrande: lecturaAnterior != null,
                    ),
                    _divisor(),

                    // Estado del medidor
                    _filaEstado(),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Botón tomar lectura ───────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _irACaptura(context),
                  icon: const Icon(Icons.camera_alt, size: 22),
                  label: const Text(
                    'Tomar lectura',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorSector,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón volver
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(
                        color: _colorSector.withOpacity(0.5)),
                  ),
                  child: Text('Volver',
                      style: TextStyle(color: _colorSector)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets internos ─────────────────────────

  Widget _fila({
    required IconData icono,
    required String label,
    required String valor,
    required Color color,
    bool valorGrande = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: valorGrande ? 22 : 15,
                    fontWeight: valorGrande
                        ? FontWeight.bold
                        : FontWeight.w500,
                    color: color,
                    letterSpacing: valorGrande ? 2 : 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaEstado() {
    final estado = _estado;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: (estado?.colorBadge ?? Colors.grey)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              estado?.icono ?? Icons.info_outline,
              color: estado?.colorBadge ?? Colors.grey,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estado del medidor',
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              if (estado != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: estado.colorBadge.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: estado.colorBadge.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(estado.icono,
                          size: 13, color: estado.colorBadge),
                      const SizedBox(width: 5),
                      Text(
                        estado.etiqueta,
                        style: TextStyle(
                          fontSize: 13,
                          color: estado.colorBadge,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text(
                  'No reportado',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divisor() => const Divider(height: 1, indent: 16, endIndent: 16);
}