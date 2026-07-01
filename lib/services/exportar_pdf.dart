import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/database.dart';

class ExportarPdfService {
  final AppDatabase _db;

  ExportarPdfService(this._db);

  // ─────────────────────────────────────────────
  // FORMATO DE PÁGINA — Impresora térmica 80mm
  // Mobilink TM-P8011 (3")
  // Para cambiar el tamaño del papel, ajusta estos valores
  // ─────────────────────────────────────────────
  static const _formatoTermico = PdfPageFormat(
    80 * PdfPageFormat.mm,  // ancho del papel
    180 * PdfPageFormat.mm, // alto (se puede dejar más largo, se recorta)
    marginAll: 4 * PdfPageFormat.mm,
  );

  // ─────────────────────────────────────────────
  // CARPETA DE DESTINO
  // facturas/Tendido/2026-06-10/TEN-201-2.pdf
  // ─────────────────────────────────────────────

  Future<Directory> _carpetaSector(String? sector, DateTime fecha) async {
    final dir = await getApplicationDocumentsDirectory();
    final nombreSector = switch (sector) {
      'TENDIDO' => 'Tendido',
      'RECREO' => 'Recreo',
      'PUEBLO NUEVO' => 'PuebloNuevo',
      _ => 'SinSector',
    };
    final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);
    final carpeta =
        Directory('${dir.path}/facturas/$nombreSector/$fechaStr');
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }
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
    final carpetaRaiz = Directory('${dir.path}/facturas/$fechaStr');
    if (!await carpetaRaiz.exists()) {
      await carpetaRaiz.create(recursive: true);
    }

    final ruta =
        '${carpetaRaiz.path}/Facturas_ASOAGUAPO_$fechaStr.pdf';
    await File(ruta).writeAsBytes(await pdf.save());
    return ruta;
  }

  // ─────────────────────────────────────────────
  // PÁGINA DE UNA FACTURA — diseño tipo recibo térmico
  // ─────────────────────────────────────────────
  //
  // GUÍA RÁPIDA PARA AJUSTAR ESTILOS:
  //   - Ancho del papel  → _formatoTermico (arriba)
  //   - Tamaños de letra → cada `fontSize:` abajo
  //   - Negrita          → pw.FontWeight.bold
  //   - Líneas separadoras → pw.Divider o '------------------------------'
  //   - Todo en escala de grises (sin fondos de color) para impresión térmica

  pw.Page _buildPagina(Lectura l, DateTime dia) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final horaFormat = DateFormat('HH:mm');

    final consumo = (l.lecturaAnterior != null && l.lectura > 0)
        ? l.lectura - l.lecturaAnterior!
        : null;

    final sector = switch (l.sector) {
      'TENDIDO' => 'El Tendido',
      'RECREO' => 'El Recreo',
      'PUEBLO NUEVO' => 'Pueblo Nuevo',
      _ => l.sector ?? '',
    };

    final estadoTexto = switch (l.estadoMedidor) {
      'bueno' => 'Bueno',
      'danado' => 'Dañado',
      'empanado' => 'Empañado',
      'con_fuga' => 'Con fuga',
      'sin_contador' => 'Sin contador',
      'acceso_denegado' => 'Acceso denegado',
      _ => 'No reportado',
    };

    return pw.Page(
      pageFormat: _formatoTermico,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [

          // ── ENCABEZADO ──────────────────────────
          pw.Center(
            child: pw.Text(
              'ASOAGUAPO',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Center(
            child: pw.Text(
              'Acueducto Comunitario',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Center(
            child: pw.Text(
              'Gigante, Huila',
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
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 4),
          _lineaPunteada(),
          pw.SizedBox(height: 6),

          // ── DATOS DEL ABONADO ────────────────────
          pw.Text(
            l.nombreAbonado ?? 'Sin nombre',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
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
          _filaTexto('Lectura anterior',
              l.lecturaAnterior?.toString() ?? '-'),
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
            pw.Text(l.notas!, style: const pw.TextStyle(fontSize: 8)),
          ],

          pw.SizedBox(height: 8),
          _lineaPunteada(),
          pw.SizedBox(height: 4),

          // ── PIE ──────────────────────────────────
          pw.Center(
            child: pw.Text(
              'Gracias por su colaboracion',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.Center(
            child: pw.Text(
              'Sistema de lectura ASOAGUAPO',
              style: const pw.TextStyle(fontSize: 7),
            ),
          ),
          // Espacio extra al final para el corte del papel
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS DE DISEÑO
  // ─────────────────────────────────────────────

  /// Fila etiqueta-valor en una sola línea
  pw.Widget _filaTexto(String etiqueta, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 1),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$etiqueta ',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Expanded(
            child: pw.Text(
              valor,
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Línea punteada de separación — ancho total del papel
  pw.Widget _lineaPunteada() {
    return pw.Text(
      '- - - - - - - - - - - - - - - - - - - - -',
      style: const pw.TextStyle(fontSize: 8),
    );
  }

  // ─────────────────────────────────────────────
  // COMPARTIR / IMPRIMIR
  // ─────────────────────────────────────────────

  Future<void> compartirPdf(String ruta) async {
    await Share.shareXFiles(
      [XFile(ruta)],
      subject: 'Factura de lectura ASOAGUAPO',
    );
  }
}