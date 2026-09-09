// lib/screens/visor_pdf_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:medidor_hapinet_app/data/database.dart';
import 'package:share_plus/share_plus.dart';
import '../data/database.dart';

class VisorPdfScreen extends StatefulWidget {
  final String rutaPdf;
  final String titulo;
  final AppDatabase? db;
  final String? lecturaId;

  const VisorPdfScreen({
    super.key,
    required this.rutaPdf,
    required this.titulo,
    this.db,
    this.lecturaId,
  });

  @override
  State<VisorPdfScreen> createState() => _VisorPdfScreenState();
}

class _VisorPdfScreenState extends State<VisorPdfScreen> {
  int _paginaActual = 0;
  int _totalPaginas = 0;
  bool _listo = false;

  Future<void> _imprimir() async {
    await Share.shareXFiles(
      [XFile(widget.rutaPdf)],
      subject: widget.titulo,
    );
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
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Imprimir / Compartir',
            onPressed: _imprimir,
          ),
        ],
        bottom: _totalPaginas > 1
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
              if (mounted) setState(() {
                _totalPaginas = pages ?? 0;
                _listo = true;
              });
            },
            onPageChanged: (page, _) {
              if (mounted) setState(() => _paginaActual = page ?? 0);
            },
            onError: (error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $error')),
                );
              }
            },
          ),
          if (!_listo)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }
}