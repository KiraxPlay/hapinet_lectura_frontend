// lib/services/exportar_pdf_service.dart
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/database.dart';
import '../models/acueducto.dart';

class ExportarPdfService {
  final AppDatabase _db;
  final Acueducto acueducto;

  ExportarPdfService(this._db, {required this.acueducto});

  static const _formatoTermico = PdfPageFormat(
    80 * PdfPageFormat.mm,
    180 * PdfPageFormat.mm,
    marginAll: 4 * PdfPageFormat.mm,
  );

  // ─────────────────────────────────────────────
  // CARPETA DE DESTINO — dinámica por acueducto
  // facturas/ASOAGUAPO/Tendido/2026-06-10/TEN-201-001.pdf
  // facturas/AGUAVIVA/LaPalma/2026-06-10/PAL-0001.pdf
  // ─────────────────────────────────────────────

  Future<Directory> _carpetaSector(String? sector, DateTime fecha) async {
    final dir = await getApplicationDocumentsDirectory();
    // Nombre de carpeta del sector — reemplaza espacios por guión bajo
    final nombreSector = (sector ?? 'SinSector')
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);
    final carpeta = Directory(
        '${dir.path}/facturas/${acueducto.nombre}/$nombreSector/$fechaStr');
    if (!await carpeta.exists()) await carpeta.create(recursive: true);
    return carpeta;
  }

  // ─────────────────────────────────────────────
  // FACTURA INDIVIDUAL
  // ─────────────────────────────────────────────

  Future<String> exportarFacturaAbonado(Lectura lectura) async {
    final carpeta =
        await _carpetaSector(lectura.sector, lectura.fechaLectura);
    final codigo = (lectura.codigoMedidor ?? 'SIN_CODIGO')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final ruta = '${carpeta.path}/$codigo.pdf';
    final pdf = pw.Document();
    pdf.addPage(_buildPagina(lectura, lectura.fechaLectura));
    await File(ruta).writeAsBytes(await pdf.save());
    return ruta;
  }

  // ─────────────────────────────────────────────
  // TODAS LAS FACTURAS DEL DÍA
  // ─────────────────────────────────────────────

  Future<String> exportarTodasLasFacturasDelDia({DateTime? fecha}) async {
    final dia = fecha ?? DateTime.now();
    final lecturas = await _db.obtenerLecturasRealesDia(dia);
    if (lecturas.isEmpty) throw Exception('No hay lecturas este día');

    for (final lectura in lecturas) {
      await exportarFacturaAbonado(lectura);
    }

    final pdf = pw.Document();
    for (final lectura in lecturas) {
      pdf.addPage(_buildPagina(lectura, dia));
    }

    final dir = await getApplicationDocumentsDirectory();
    final fechaStr = DateFormat('yyyy-MM-dd').format(dia);
    final carpetaRaiz =
        Directory('${dir.path}/facturas/${acueducto.nombre}/$fechaStr');
    if (!await carpetaRaiz.exists()) {
      await carpetaRaiz.create(recursive: true);
    }

    final ruta =
        '${carpetaRaiz.path}/Facturas_${acueducto.nombre}_$fechaStr.pdf';
    await File(ruta).writeAsBytes(await pdf.save());
    return ruta;
  }

  // ─────────────────────────────────────────────
  // PÁGINA DE UNA FACTURA
  // ─────────────────────────────────────────────

  pw.Page _buildPagina(Lectura l, DateTime dia) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final horaFormat = DateFormat('HH:mm');

    final consumo = (l.lecturaAnterior != null && l.lectura > 0)
        ? l.lectura - l.lecturaAnterior!
        : null;

    // Sector tal como viene — funciona con cualquier acueducto
    final sector = l.sector ?? '';

    final estadoTexto = switch (l.estadoMedidor) {
      'bueno' => 'Bueno',
      'danado' => 'Dañado',
      'empanado' => 'Empañado',
      'con_fuga' => 'Con fuga',
      'sin_contador' => 'Sin contador',
      'acceso_denegado' => 'Acceso denegado',
      _ => 'No reportado',
    };

    // Datos del acueducto según el activo
    final datosAcueducto = switch (acueducto.tipo) {
      TipoAcueducto.asoaguapo => (
          nit: 'NIT: 900358329-1',
          telefono: 'Tel: 3018424013',
          correo: 'asoguapo22@gmail.com',
        ),
      TipoAcueducto.aguaviva => (
          nit: 'NIT: 900191061-2',
          telefono: 'Tel: 3219955848',
          correo: 'halvarezyaime@gmail.com',
        ),
    };

    return pw.Page(
      pageFormat: _formatoTermico,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

          // ── ENCABEZADO ──────────────────────────
          pw.Center(
            child: pw.Text(
              acueducto.nombre,
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Center(
            child: pw.Text(
              'Acueducto Comunitario — Gigante, Huila',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Center(
            child: pw.Text(
              datosAcueducto.nit,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Center(
            child: pw.Text(
              datosAcueducto.telefono,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Center(
            child: pw.Text(
              datosAcueducto.correo,
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),

          pw.SizedBox(height: 4),
          _lineaPunteada(),
          pw.SizedBox(height: 4),

          pw.Center(
            child: pw.Text(
              'COMPROBANTE DE LECTURA',
              style: pw.TextStyle(
                  fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 4),
          _lineaPunteada(),
          pw.SizedBox(height: 6),

          // ── DATOS DEL ABONADO ────────────────────
          pw.Text(
            l.nombreAbonado ?? 'Sin nombre',
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          _filaTexto('Codigo:', l.codigoMedidor ?? '-'),
          _filaTexto('Sector:', sector),
          if (l.celular != null) _filaTexto('Celular:', l.celular!),
          _filaTexto('Fecha:', dateFormat.format(dia)),
          _filaTexto('Hora:', horaFormat.format(l.fechaLectura)),

          pw.SizedBox(height: 6),
          _lineaPunteada(),
          pw.SizedBox(height: 6),

          // ── LECTURAS ─────────────────────────────
          _filaTexto(
              'Lectura anterior', l.lecturaAnterior?.toString() ?? '-'),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('LECTURA ACTUAL',
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.Text(l.lectura.toString(),
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          ),

          if (consumo != null) ...[
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('CONSUMO',
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('$consumo m3',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],

          pw.SizedBox(height: 6),
          _lineaPunteada(),
          pw.SizedBox(height: 6),

          // ── ESTADO DEL MEDIDOR ───────────────────
          _filaTexto('Estado medidor:', estadoTexto),

          if (l.notas != null && l.notas!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('Observaciones:',
                style: pw.TextStyle(
                    fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.Text(l.notas!,
                style: const pw.TextStyle(fontSize: 8)),
          ],

          pw.SizedBox(height: 8),
          _lineaPunteada(),
          pw.SizedBox(height: 4),

          // ── PIE ──────────────────────────────────
          pw.Center(
            child: pw.Text('Gracias por su colaboracion',
                style: const pw.TextStyle(fontSize: 8)),
          ),
          pw.Center(
            child: pw.Text(
              'Sistema de lectura ${acueducto.nombre}', // ← dinámico
              style: const pw.TextStyle(fontSize: 7),
            ),
          ),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  pw.Widget _filaTexto(String etiqueta, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$etiqueta ',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Expanded(
            child: pw.Text(valor,
                style: pw.TextStyle(
                    fontSize: 9, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  pw.Widget _lineaPunteada() {
    return pw.Text(
      '- - - - - - - - - - - - - - - - - - - - -',
      style: const pw.TextStyle(fontSize: 8),
    );
  }

  Future<void> compartirPdf(String ruta) async {
    await Share.shareXFiles(
      [XFile(ruta)],
      subject: 'Factura de lectura ${acueducto.nombre}',
    );
  }
}