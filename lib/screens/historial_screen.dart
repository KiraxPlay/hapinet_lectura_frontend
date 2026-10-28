// lib/screens/historial_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import '../models/punto_mapa.dart';
import '../components/fondo_gotas.dart';
import '../components/funciones/tarjeta_lectura.dart';
import '../services/exportar_service.dart';
import '../services/exportar_pdf.dart';
import '../services/historial_service.dart';
import '../services/captura_facturacion_service.dart';
import 'visor_pdf_screen.dart';

class HistorialScreen extends StatefulWidget {
  final AppDatabase db;
  final Acueducto acueducto;

  const HistorialScreen({super.key, required this.db, required this.acueducto});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late final ExportarService _exportar;
  late final HistorialService _historialService;
  DateTime? _diaExpandido;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null);
    _exportar = ExportarService(widget.db, acueducto: widget.acueducto);
    _historialService = HistorialService(widget.db);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial — ${widget.acueducto.nombre}')),
      body: FondoConGotas(
        child: StreamBuilder<List<DateTime>>(
          stream: widget.db.watchDiasConLecturas(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final dias = snapshot.data ?? [];

            if (dias.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Sin lecturas registradas',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Las lecturas del día aparecerán aquí',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dias.length,
              itemBuilder: (_, i) {
                final fecha = dias[i];
                final esExpandido =
                    _diaExpandido != null &&
                    _diaExpandido!.year == fecha.year &&
                    _diaExpandido!.month == fecha.month &&
                    _diaExpandido!.day == fecha.day;

                return _TarjetaDia(
                  key: ValueKey(
                    '${fecha.year}-${fecha.month}-${fecha.day}-$esExpandido',
                  ),
                  fecha: fecha,
                  db: widget.db,
                  historialService: _historialService,
                  exportar: _exportar,
                  expandido: esExpandido,
                  onToggle:
                      () => setState(() {
                        _diaExpandido = esExpandido ? null : fecha;
                      }),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TARJETA DE UN DÍA
// ─────────────────────────────────────────────

class _TarjetaDia extends StatefulWidget {
  final DateTime fecha;
  final AppDatabase db;
  final HistorialService historialService;
  final ExportarService exportar;
  final bool expandido;
  final VoidCallback onToggle;

  const _TarjetaDia({
    super.key,
    required this.fecha,
    required this.db,
    required this.historialService,
    required this.exportar,
    required this.expandido,
    required this.onToggle,
  });

  @override
  State<_TarjetaDia> createState() => _TarjetaDiaState();
}

class _TarjetaDiaState extends State<_TarjetaDia> {
  HistorialDia? _historial;
  Object? _errorHistorial;
  StreamSubscription<HistorialDia>? _historialSubscription;
  bool _cargando = false;
  bool _exportando = false;
  bool _exportandoPdf = false;
  bool _facturando = false;

  bool get _esHoy {
    final hoy = DateTime.now();
    return widget.fecha.year == hoy.year &&
        widget.fecha.month == hoy.month &&
        widget.fecha.day == hoy.day;
  }

  @override
  void initState() {
    super.initState();
    if (widget.expandido) _cargar();
  }

  @override
  void didUpdateWidget(_TarjetaDia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expandido && !oldWidget.expandido) {
      _cargar();
    } else if (!widget.expandido && oldWidget.expandido) {
      _historialSubscription?.cancel();
      _historialSubscription = null;
    }
  }

  @override
  void dispose() {
    _historialSubscription?.cancel();
    super.dispose();
  }

  Future<void> _cargar() async {
    await _historialSubscription?.cancel();
    if (!mounted) return;
    setState(() {
      _cargando = true;
      _errorHistorial = null;
    });
    _historialSubscription = widget.historialService
        .watchDia(fecha: widget.fecha)
        .listen(
          (historial) {
            if (!mounted) return;
            setState(() {
              _historial = historial;
              _cargando = false;
              _errorHistorial = null;
            });
          },
          onError: (Object error) {
            if (!mounted) return;
            setState(() {
              _cargando = false;
              _errorHistorial = error;
            });
          },
        );
  }

  Future<void> _exportar(HistorialDia historial) async {
    if (historial.total == 0) return;
    setState(() => _exportando = true);
    try {
      final ruta = await widget.exportar.exportarLecturasDia(
        fecha: widget.fecha,
      );
      await widget.exportar.compartirArchivo(ruta);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al exportar: $e')));
      }
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  Future<void> _exportarPdf(HistorialDia historial) async {
    if (historial.total == 0) return;
    setState(() => _exportandoPdf = true);
    try {
      final pdfService = ExportarPdfService(
        widget.db,
        acueducto: widget.exportar.acueducto,
      );
      final ruta = await pdfService.exportarTodasLasFacturasDelDia(
        fecha: widget.fecha,
      );
      await pdfService.compartirPdf(ruta);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _exportandoPdf = false);
    }
  }

  Future<void> _hacerFactura(Lectura lectura) async {
    final match = RegExp(r'predio_(\d+)').firstMatch(lectura.id);
    final predioId = match == null ? null : int.tryParse(match.group(1)!);
    if (predioId == null || lectura.codigoMedidor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo identificar el predio')),
      );
      return;
    }

    setState(() => _facturando = true);
    try {
      final facturacion = await CapturaFacturacionService().facturar(
        db: widget.db,
        acueducto: widget.exportar.acueducto,
        codigoMedidor: lectura.codigoMedidor!,
        predioId: predioId,
      );
      if (facturacion == null || !mounted) return;

      final novedades = await widget.db.obtenerNovedadesPredio(predioId);
      final rutaPdf = await ExportarPdfService(
        widget.db,
        acueducto: widget.exportar.acueducto,
      ).exportarFacturaAbonado(
        facturacion.lectura,
        novedades: novedades,
        resultado: facturacion.resultado,
      );

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => VisorPdfScreen(
                rutaPdf: rutaPdf,
                titulo:
                    facturacion.resultado.esOficial
                        ? 'Factura N° ${facturacion.resultado.facturaNumero}'
                        : 'Comprobante estimado',
                db: widget.db,
                predioId: predioId,
                lecturaId: facturacion.lectura.id,
                acueducto: widget.exportar.acueducto,
                lectura: facturacion.lectura,
                novedades: novedades,
                totalAPagar: facturacion.resultado.total,
                esOficial: facturacion.resultado.esOficial,
                facturaNumero: facturacion.resultado.facturaNumero,
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al hacer factura: $e')));
      }
    } finally {
      if (mounted) setState(() => _facturando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaStr =
        _esHoy
            ? 'Hoy — ${DateFormat('dd/MM/yyyy').format(widget.fecha)}'
            : DateFormat('EEEE dd/MM/yyyy', 'es').format(widget.fecha);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: widget.expandido ? 3 : 1,
      child: Column(
        children: [
          // ── Header ──────────────────────────────
          InkWell(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(widget.expandido ? 0 : 12),
              bottomRight: Radius.circular(widget.expandido ? 0 : 12),
            ),
            onTap: widget.onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          _esHoy
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _esHoy ? Icons.today : Icons.calendar_month,
                      color: _esHoy ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Fecha + resumen dinámico
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fechaStr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _esHoy ? Colors.blue : Colors.black87,
                          ),
                        ),
                        if (_historial != null && _historial!.total > 0) ...[
                          Text(
                            '${_historial!.total} lecturas',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          // Resumen por sector dinámico
                          Text(
                            _historial!.sectores
                                .map(
                                  (s) =>
                                      '${s[0].toUpperCase()}:${_historial!.porSector[s]!.length}',
                                )
                                .join('  '),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ] else if (_historial != null)
                          const Text(
                            'Sin lecturas este día',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),

                  // Botones exportar
                  if (widget.expandido &&
                      _historial != null &&
                      _historial!.total > 0) ...[
                    _exportando
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : TextButton(
                          onPressed: () => _exportar(_historial!),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'EXCEL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                    const SizedBox(width: 6),
                    _exportandoPdf
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : TextButton(
                          onPressed: () => _exportarPdf(_historial!),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'PDF',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                  ],

                  const SizedBox(width: 8),
                  Icon(
                    widget.expandido
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // ── Contenido expandido ──────────────────
          if (widget.expandido) ...[
            const Divider(height: 1),
            if (_cargando)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorHistorial != null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error al cargar el historial: $_errorHistorial',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else if (_historial == null)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Cargando...',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else if (_historial!.total == 0)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Sin lecturas este día',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              _buildContenido(_historial!),
          ],
        ],
      ),
    );
  }

  // Sectores dinámicos — funciona con ASOAGUAPO y Aguaviva
  Widget _buildContenido(HistorialDia historial) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children:
            historial.sectores.map((sector) {
              final lecturas = historial.porSector[sector]!;
              final color = PuntoMapa.coloresSector[sector] ?? Colors.grey;
              return _buildSeccion(sector, lecturas, color);
            }).toList(),
      ),
    );
  }

  Widget _buildSeccion(String nombre, List<Lectura> lecturas, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                '$nombre (${lecturas.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        ...lecturas.map(
          (l) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TarjetaLectura(
              lectura: l,
              db: widget.db,
              onActualizado: _cargar,
              bloqueada: false,
              acueducto: widget.exportar.acueducto,
              // La factura se procesa aquí; el detalle solo dispara esta acción.
              onFacturar: _facturando ? null : () => _hacerFactura(l),
            ),
          ),
        ),
      ],
    );
  }
}
