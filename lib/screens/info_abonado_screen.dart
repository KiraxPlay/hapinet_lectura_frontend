// lib/screens/info_abonado_screen.dart
import 'package:flutter/material.dart';
import '../data/database.dart';
import '../components/fondo_gotas.dart';
import '../models/acueducto.dart';
import '../models/estado_medidor.dart';
import '../services/api/factura_api_service.dart';
import 'captura_screen.dart';

/// Pantalla intermedia que muestra info del abonado
/// ANTES de abrir la cámara para tomar la lectura.
///
/// Flujo:
///   lecturas_dia_screen o mapa_screen
///       → InfoAbonadoScreen  (esta pantalla)
///           → CapturaScreen  (cámara)
class InfoAbonadoScreen extends StatefulWidget {
  final AppDatabase db;
  final String? codigoMedidor;
  final String? nombreAbonado;
  final String? celular;
  final int? lecturaAnterior;
  final double? latitud;
  final double? longitud;
  final String? sector;
  final String? estadoMedidorClave; // último estado reportado

  final Acueducto acueducto;
  final int? predioId; // ID del predio en Laravel para facturación

  const InfoAbonadoScreen({
    super.key,
    required this.db,
    required this.acueducto,
    this.codigoMedidor,
    this.nombreAbonado,
    this.celular,
    this.lecturaAnterior,
    this.latitud,
    this.longitud,
    this.sector,
    this.estadoMedidorClave,
    this.predioId,
  });



  @override
  State<InfoAbonadoScreen> createState() => _InfoAbonadoScreenState();
}

class _InfoAbonadoScreenState extends State<InfoAbonadoScreen> {
  DeudaResult? _deuda;
  bool _cargandoDeuda = false;
  int? _predioIdResuelto; // resuelto desde la BD cuando predioId es null

  // Getters del widget padre
  AppDatabase get db => widget.db;
  Acueducto get acueducto => widget.acueducto;
  String? get codigoMedidor => widget.codigoMedidor;
  String? get nombreAbonado => widget.nombreAbonado;
  String? get celular => widget.celular;
  int? get lecturaAnterior => widget.lecturaAnterior;
  double? get latitud => widget.latitud;
  double? get longitud => widget.longitud;
  String? get sector => widget.sector;
  String? get estadoMedidorClave => widget.estadoMedidorClave;
  int? get predioId => widget.predioId;

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
          acueducto: acueducto,
          codigoMedidor: codigoMedidor,
          nombreAbonado: nombreAbonado,
          lecturaAnterior: lecturaAnterior,
          latitudReferencia: latitud,
          longitudReferencia: longitud,
          predioId: predioId ?? _predioIdResuelto,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _resolverPredioId();
    if (predioId != null) _cargarDeuda();
  }

  Future<void> _resolverPredioId() async {
    if (predioId != null) return;
    if (codigoMedidor == null) return;
    // Buscar el id de la lectura en la BD — tiene formato 'predio_123'
    final lectura = await db.obtenerLecturaPorCodigo(codigoMedidor!);
    if (lectura == null) return;
    final match = RegExp(r'predio_(\d+)').firstMatch(lectura.id);
    if (match != null) {
      final id = int.tryParse(match.group(1)!);
      if (id != null && mounted) {
        setState(() => _predioIdResuelto = id);
        _cargarDeuda();
      }
    }
  }

  Future<void> _cargarDeuda() async {
    final id = predioId ?? _predioIdResuelto;
    if (id == null) return;
    setState(() => _cargandoDeuda = true);
    final resultado = await FacturaApiService().deudaAbonado(id);
    if (mounted) setState(() { _deuda = resultado; _cargandoDeuda = false; });
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

              const SizedBox(height: 20),

              // ── Deuda del abonado ─────────────────────
              if (predioId != null || _predioIdResuelto != null) _buildTarjetaDeuda(),

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

  Widget _buildTarjetaDeuda() {
    if (_cargandoDeuda) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (_deuda == null || !_deuda!.exitoso) return const SizedBox.shrink();

    final tieneDeuda = (_deuda!.totalDeuda ?? 0) > 0;
    final color = tieneDeuda ? Colors.red : Colors.green;
    final fmt = _deuda!.totalDeuda ?? 0;
    final totalStr = '\$${fmt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '\${m[1]}.')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            tieneDeuda ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: color, size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tieneDeuda ? 'Tiene deuda pendiente' : 'Sin deuda',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (tieneDeuda) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$totalStr — ${_deuda!.cantidadFacturas} factura(s)',
                    style: TextStyle(color: color, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

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