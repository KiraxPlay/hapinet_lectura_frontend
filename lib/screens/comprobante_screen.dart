// lib/screens/comprobante_screen.dart
// Pantalla de comprobante estimado con deuda anterior + consumo + total
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import '../models/factura_sitio_result.dart';
import '../components/comprobante/comprobante_section.dart';
import '../services/api/factura_api_service.dart';
import '../services/comprobante_service.dart';
import '../services/impresora_service.dart';
import 'visor_pdf_screen.dart';

class ComprobanteScreen extends StatefulWidget {
  final Lectura lectura;
  final FacturaSitioResult resultado;
  final AppDatabase db;
  final Acueducto acueducto;
  final int? predioId;

  const ComprobanteScreen({
    super.key,
    required this.lectura,
    required this.resultado,
    required this.db,
    required this.acueducto,
    required this.predioId,
  });

  @override
  State<ComprobanteScreen> createState() => _ComprobanteScreenState();
}

class _ComprobanteScreenState extends State<ComprobanteScreen> {
  DeudaResult? _deuda;
  bool _cargandoDeuda = false;
  List<Map<String, dynamic>> _novedades = [];
  bool _cargandoNovedades = false;
  bool _generandoPdf = false;
  bool _imprimiendo = false;

  final _fmt = NumberFormat('#,###', 'es_CO');
  final _comprobanteService = ComprobanteService();

  @override
  void initState() {
    super.initState();
    if (widget.predioId != null) {
      _cargarDeuda();
      _cargarNovedades();
    }
  }

  Future<void> _cargarDeuda() async {
    setState(() => _cargandoDeuda = true);
    try {
      final resultado = await _comprobanteService.cargarDeuda(widget.predioId!);
      if (mounted) setState(() => _deuda = resultado);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _cargandoDeuda = false);
    }
  }

  Future<void> _cargarNovedades() async {
    setState(() => _cargandoNovedades = true);
    try {
      final novedades = await _comprobanteService.cargarNovedades(
        predioId: widget.predioId!,
        acueducto: widget.acueducto,
        db: widget.db,
      );
      if (mounted) setState(() => _novedades = novedades);
    } finally {
      if (mounted) setState(() => _cargandoNovedades = false);
    }
  }

  Future<void> _verPdf() async {
    setState(() => _generandoPdf = true);
    try {
      final ruta = await _comprobanteService.generarPdf(
        db: widget.db,
        acueducto: widget.acueducto,
        lectura: widget.lectura,
        novedades: _novedades,
        resultado: widget.resultado,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => VisorPdfScreen(
                rutaPdf: ruta,
                titulo:
                    widget.resultado.esOficial
                        ? 'Factura N° ${widget.resultado.facturaNumero}'
                        : 'Comprobante estimado — ${widget.lectura.codigoMedidor}',
                db: widget.db,
                lecturaId: widget.lectura.id,
                acueducto: widget.acueducto,
                lectura: widget.lectura,
                novedades: _novedades,
                totalAPagar: widget.resultado.total,
              ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
      }
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  Future<void> _imprimirDirecto() async {
    setState(() => _imprimiendo = true);
    try {
      final resultado = await ImpresoraService(
        acueducto: widget.acueducto,
      ).imprimir(
        lectura: widget.lectura,
        novedades: _novedades,
        total: widget.resultado.total,
        esOficial: widget.resultado.esOficial,
        facturaNumero: widget.resultado.facturaNumero,
      );

      if (!mounted) return;
      if (resultado.exitoso) {
        await widget.db.marcarImpreso(widget.lectura.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impreso correctamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado.error ?? 'Error al imprimir'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _imprimiendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultado = widget.resultado;
    final lectura = widget.lectura;
    final consumo =
        resultado.esOficial
            ? null
            : (lectura.lectura - (lectura.lecturaAnterior ?? 0)).clamp(
              0,
              999999,
            );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          resultado.esOficial ? 'Factura generada' : 'Comprobante estimado',
        ),
        backgroundColor:
            resultado.esOficial
                ? Colors.green.shade700
                : Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header abonado ─────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          resultado.esOficial
                              ? Icons.receipt_long
                              : Icons.receipt,
                          color:
                              resultado.esOficial
                                  ? Colors.green
                                  : Colors.orange,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lectura.nombreAbonado ?? 'Sin nombre',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                lectura.codigoMedidor ?? '',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!resultado.esOficial) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Valor estimado — no incluye novedades. '
                                'La factura oficial se genera al sincronizar.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (resultado.facturaNumero != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Factura N° ${resultado.facturaNumero}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Deuda anterior ──────────────────────
            if (_cargandoDeuda)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_deuda != null && _deuda!.exitoso) ...[
              ComprobanteSection(
                titulo: 'DEUDA ANTERIOR',
                icono: Icons.account_balance_wallet_outlined,
                color:
                    (_deuda!.totalDeuda ?? 0) > 0 ? Colors.red : Colors.green,
                filas: [
                  ComprobanteFila(
                    'Facturas pendientes',
                    '${_deuda!.cantidadFacturas}',
                  ),
                  ComprobanteFila(
                    'Total deuda',
                    '\$${_fmt.format(_deuda!.totalDeuda ?? 0)}',
                    negrita: true,
                    color:
                        (_deuda!.totalDeuda ?? 0) > 0
                            ? Colors.red
                            : Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // ── Novedades pendientes ────────────────
            if (_cargandoNovedades)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_novedades.isNotEmpty) ...[
              ComprobanteSection(
                titulo: 'NOVEDADES PENDIENTES',
                icono: Icons.assignment_outlined,
                color: Colors.deepOrange,
                filas:
                    _novedades
                        .map(
                          (n) => ComprobanteFila(
                            n['concepto'] as String,
                            '\$${_fmt.format(n['valor_cuota'])} × '
                            '${n['cuotas_pendientes']} cuota(s) = '
                            '\$${_fmt.format(n['total_pendiente'])}',
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // ── Lecturas y consumo ──────────────────
            ComprobanteSection(
              titulo: 'LECTURA ACTUAL',
              icono: Icons.speed,
              color: Colors.blue,
              filas: [
                ComprobanteFila(
                  'Lectura anterior',
                  '${lectura.lecturaAnterior ?? 0}',
                ),
                ComprobanteFila(
                  'Lectura actual',
                  '${lectura.lectura}',
                  negrita: true,
                ),
                ComprobanteFila(
                  'Consumo',
                  '${consumo ?? resultado.consumoEstimado ?? 0} m³',
                  negrita: true,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Desglose ────────────────────────────
            ComprobanteSection(
              titulo:
                  resultado.esOficial
                      ? 'DESGLOSE FACTURA'
                      : 'DESGLOSE ESTIMADO',
              icono: Icons.list_alt,
              color: Colors.indigo,
              filas: [
                ComprobanteFila(
                  'Cargo básico',
                  '\$${_fmt.format(resultado.cargoBasicoMostrar)}',
                ),
                ComprobanteFila(
                  'Valor consumo',
                  '\$${_fmt.format(resultado.valorConsumoMostrar)}',
                ),
                if (resultado.novedadesMostrar > 0)
                  ComprobanteFila(
                    'Novedades',
                    '\$${_fmt.format(resultado.novedadesMostrar)}',
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Total ───────────────────────────────
            Card(
              color:
                  resultado.esOficial
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      resultado.esOficial ? 'TOTAL A PAGAR' : 'TOTAL ESTIMADO',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      resultado.totalFormateado,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            resultado.esOficial
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Imprimir directamente ───────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _imprimiendo ? null : _imprimirDirecto,
                icon:
                    _imprimiendo
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.print),
                label: Text(_imprimiendo ? 'Imprimiendo...' : 'Imprimir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      resultado.esOficial ? Colors.green : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Botón ver PDF ───────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generandoPdf ? null : _verPdf,
                icon:
                    _generandoPdf
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.picture_as_pdf),
                label: Text(
                  _generandoPdf ? 'Generando...' : 'Ver comprobante completo',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      resultado.esOficial ? Colors.green : Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                icon: const Icon(Icons.check),
                label: const Text('Finalizar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
