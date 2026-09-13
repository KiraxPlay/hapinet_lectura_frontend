// lib/screens/visor_pdf_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import '../services/api/api_service.dart';
import '../services/api/factura_api_service.dart';
import '../services/impresora_service.dart';

class VisorPdfScreen extends StatefulWidget {
  final String rutaPdf;
  final String titulo;
  final AppDatabase? db;
  final int? predioId;
  final String? lecturaId;
  final Acueducto? acueducto;
  final Lectura? lectura;
  final List<Map<String, dynamic>> novedades;
  final int? totalAPagar;
  final bool esOficial;
  final int? facturaNumero;

  const VisorPdfScreen({
    super.key,
    required this.rutaPdf,
    required this.titulo,
    this.db,
    this.predioId,
    this.lecturaId,
    this.acueducto,
    this.lectura,
    this.novedades = const [],
    this.totalAPagar,
    this.esOficial = false,
    this.facturaNumero,
  });

  @override
  State<VisorPdfScreen> createState() => _VisorPdfScreenState();
}

class _VisorPdfScreenState extends State<VisorPdfScreen> {
  int _paginaActual = 0;
  int _totalPaginas = 0;
  bool _listo = false;
  bool _imprimiendo = false;

  Future<void> _imprimirESCPOS() async {
    if (widget.acueducto == null || widget.lectura == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay datos para imprimir')),
      );
      return;
    }
    setState(() => _imprimiendo = true);
    try {
      // Si la previsualizacion fue offline, intenta crear la factura oficial
      // antes de enviar el tiquete a la impresora.
        if (!widget.esOficial &&
          widget.predioId != null &&
          widget.db != null) {
        try {
          await ApiService(
            widget.acueducto!,
          ).sincronizarLecturasPendientes(widget.db!);
          await FacturaApiService().generarFactura(
            predioId: widget.predioId!,
          );
        } catch (_) {
          // Sin internet se conserva la impresion del comprobante estimado.
        }
      }

      final service = ImpresoraService(acueducto: widget.acueducto!);
      final resultado = await service.imprimirPdf(rutaPdf: widget.rutaPdf);
      if (mounted) {
        if (resultado.exitoso) {
          await widget.db?.marcarImpreso(widget.lecturaId ?? '');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Impreso en SAT AF330'),
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
      }
    } finally {
      if (mounted) setState(() => _imprimiendo = false);
    }
  }

  Future<void> _imprimir() async {
    await Share.shareXFiles([XFile(widget.rutaPdf)], subject: widget.titulo);
    if (widget.db != null && widget.lecturaId != null) {
      await widget.db!.marcarImpreso(widget.lecturaId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Marcado como impreso'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
        title: Text(widget.titulo, style: const TextStyle(fontSize: 14)),
        actions: [
          if (widget.acueducto != null && widget.lectura != null)
            _imprimiendo
                ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
                : IconButton(
                  icon: const Icon(Icons.print),
                  tooltip: 'Imprimir en SAT AF330',
                  onPressed: _imprimirESCPOS,
                ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir PDF',
            onPressed: _imprimir,
          ),
        ],
        bottom:
            _totalPaginas > 1
                ? PreferredSize(
                  preferredSize: const Size.fromHeight(24),
                  child: Text(
                    'Página ${_paginaActual + 1} de $_totalPaginas',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                )
                : null,
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.rutaPdf,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            fitPolicy: FitPolicy.BOTH,
            onRender: (pages) {
              if (mounted)
                setState(() {
                  _totalPaginas = pages ?? 0;
                  _listo = true;
                });
            },
            onPageChanged: (page, _) {
              if (mounted) setState(() => _paginaActual = page ?? 0);
            },
            onError: (error) {
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $error')));
              }
            },
          ),
          if (!_listo)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
