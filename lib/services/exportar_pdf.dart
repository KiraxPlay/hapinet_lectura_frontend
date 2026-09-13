// lib/services/exportar_pdf.dart
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/database.dart';
import '../models/acueducto.dart';
import '../models/factura_sitio_result.dart';
import 'api/factura_api_service.dart';
import 'api/tarifas_service.dart';

class ExportarPdfService {
  final AppDatabase _db;
  final Acueducto acueducto;
  final _facturaApi = FacturaApiService();
  late final TarifasService _tarifasSvc;

  ExportarPdfService(this._db, {required this.acueducto}) {
    _tarifasSvc = TarifasService(acueducto: acueducto);
  }

  static const _formatoTermico = PdfPageFormat(
    80 * PdfPageFormat.mm,
    double.infinity,
    marginAll: 3 * PdfPageFormat.mm,
  );

  // ─────────────────────────────────────────────
  // FACTURAR EN SITIO
  // ─────────────────────────────────────────────

  Future<FacturaSitioResult> generarFacturaEnSitio({
    required Lectura lectura,
    required int predioId,
  }) async {
    final tieneTarifas = await _tarifasSvc.tieneTarifasLocales();
    if (!tieneTarifas) {
      return FacturaSitioResult.error(
        'Sin tarifas guardadas. Necesitas conectarte al menos una vez.',
      );
    }

    final calculo = await _tarifasSvc.calcularOffline(
      lecturaActual: lectura.lectura,
      lecturaAnterior: lectura.lecturaAnterior ?? 0,
    );

    final ruta = await _generarPdf(
      lectura: lectura,
      fecha: DateTime.now(),
      calculo: calculo,
      facturaNumero: null,
      novedades: const [],
    );

    return FacturaSitioResult.exito(
      rutaPdf: ruta,
      esOficial: false,
      total: calculo.total,
      cargoBasico: calculo.cargoBasico,
      valorConsumo: calculo.valorConsumo,
      consumoEstimado: calculo.consumo,
      aviso:
          'Comprobante estimado. La factura oficial se generará al sincronizar.',
    );
  }

  // ─────────────────────────────────────────────
  // GENERAR PDF
  // ─────────────────────────────────────────────

  Future<String> _generarPdf({
    required Lectura lectura,
    required DateTime fecha,
    required ComprobanteCalculo calculo,
    required List<Map<String, dynamic>> novedades,
    int? facturaNumero,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);
    final sector = (lectura.sector ?? 'SinSector')
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    final carpeta = Directory(
      '${dir.path}/facturas/${acueducto.nombre}/$sector/$fechaStr',
    );
    if (!await carpeta.exists()) await carpeta.create(recursive: true);

    final codigo = (lectura.codigoMedidor ?? 'SIN_CODIGO').replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    final ruta = '${carpeta.path}/$codigo.pdf';

    final empresa = await _tarifasSvc.obtenerLocal();
    final pdf = pw.Document();
    pdf.addPage(
      _buildPagina(
        lectura: lectura,
        calculo: calculo,
        fecha: fecha,
        facturaNumero: facturaNumero,
        empresa: empresa,
        novedades: novedades,
      ),
    );

    await File(ruta).writeAsBytes(await pdf.save());
    return ruta;
  }

  // ─────────────────────────────────────────────
  // COMPROBANTE ABONADO (con novedades)
  // ─────────────────────────────────────────────

  Future<String> exportarFacturaAbonado(
    Lectura lectura, {
    List<Map<String, dynamic>> novedades = const [],
    FacturaSitioResult? resultado,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final fechaStr = DateFormat('yyyy-MM-dd').format(lectura.fechaLectura);
    final sector = (lectura.sector ?? 'SinSector')
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    final carpeta = Directory(
      '${dir.path}/facturas/${acueducto.nombre}/$sector/$fechaStr',
    );
    if (!await carpeta.exists()) await carpeta.create(recursive: true);

    final codigo = (lectura.codigoMedidor ?? 'SIN_CODIGO').replaceAll(
      RegExp(r'[^a-zA-Z0-9_-]'),
      '_',
    );
    final ruta = '${carpeta.path}/$codigo.pdf';

    // Calcular valores para el PDF
    ComprobanteCalculo? calculo;
    if (resultado != null) {
      final tarifas = await _tarifasSvc.obtenerLocal();
      calculo = ComprobanteCalculo(
        consumo:
            resultado.consumo ??
            resultado.consumoEstimado ??
            (lectura.lectura - (lectura.lecturaAnterior ?? 0)).clamp(0, 999999),
        cargoBasico: resultado.cargoBasico,
        valorConsumo: resultado.valorConsumo,
        total: resultado.total,
        esEstimado: !resultado.esOficial,
        tarifas: tarifas,
      );
    }

    final empresa = await _tarifasSvc.obtenerLocal();
    final pdf = pw.Document();
    pdf.addPage(
      _buildPaginaCompleta(
        lectura: lectura,
        empresa: empresa,
        calculo: calculo,
        novedades: novedades,
        esOficial: resultado?.esOficial ?? false,
        facturaNumero: resultado?.facturaNumero,
      ),
    );

    await File(ruta).writeAsBytes(await pdf.save());
    return ruta;
  }

  Future<String> exportarTodasLasFacturasDelDia({DateTime? fecha}) async {
    final dia = fecha ?? DateTime.now();
    final lecturas = await _db.obtenerLecturasRealesDia(dia);
    if (lecturas.isEmpty) throw Exception('No hay lecturas este día');

    final empresa = await _tarifasSvc.obtenerLocal();
    final pdf = pw.Document();
    for (final l in lecturas) {
      pdf.addPage(_buildPaginaCompleta(lectura: l, empresa: empresa));
    }

    final dir = await getApplicationDocumentsDirectory();
    final fechaStr = DateFormat('yyyy-MM-dd').format(dia);
    final carpeta = Directory(
      '${dir.path}/facturas/${acueducto.nombre}/$fechaStr',
    );
    if (!await carpeta.exists()) await carpeta.create(recursive: true);

    final ruta = '${carpeta.path}/Lecturas_${acueducto.nombre}_$fechaStr.pdf';
    await File(ruta).writeAsBytes(await pdf.save());
    return ruta;
  }

  // ─────────────────────────────────────────────
  // PÁGINA PRINCIPAL — diseño tipo factura térmica
  // ─────────────────────────────────────────────

  pw.Page _buildPaginaCompleta({
    required Lectura lectura,
    required TarifasLocal empresa,
    ComprobanteCalculo? calculo,
    List<Map<String, dynamic>> novedades = const [],
    bool esOficial = false,
    int? facturaNumero,
  }) {
    final fmtFecha = DateFormat('yyyy-MM-dd');
    final fmtNum = NumberFormat('#,###', 'es_CO');
    final consumo =
        calculo?.consumo ??
        (lectura.lectura - (lectura.lecturaAnterior ?? 0)).clamp(0, 999999);

    // Calcular total de novedades
    int totalNovedades = 0;
    for (final n in novedades) {
      totalNovedades += (n['total_pendiente'] as int? ?? 0);
    }

    final totalAPagar = (calculo?.total ?? 0) + totalNovedades;

    return pw.Page(
      pageFormat: _formatoTermico,
      build:
          (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // ── ENCABEZADO ─────────────────────────
              pw.Text(
                empresa.empresaNombre.isNotEmpty
                    ? empresa.empresaNombre.toUpperCase()
                    : acueducto.nombre.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              if (empresa.empresaNit.isNotEmpty)
                pw.Text(
                  'NIT: ${empresa.empresaNit}',
                  style: const pw.TextStyle(fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              pw.Text(
                _veredasAcueducto(),
                style: const pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
              ),
              if (empresa.empresaTelefono.isNotEmpty)
                pw.Text(
                  'Cel: ${empresa.empresaTelefono}',
                  style: const pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),
              if (empresa.empresaEmail.isNotEmpty)
                pw.Text(
                  empresa.empresaEmail,
                  style: const pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),

              pw.SizedBox(height: 6),
              _separador(),
              pw.SizedBox(height: 4),

              // ── TIPO DOCUMENTO ──────────────────────
              pw.Text(
                esOficial ? 'FACTURA DE VENTA' : 'COMPROBANTE DE LECTURA',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 6),
              _separador(),
              pw.SizedBox(height: 4),

              // ── DATOS ABONADO ───────────────────────
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'ABONADO:',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  (lectura.nombreAbonado ?? 'Sin nombre').toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 3),
              _filaDatos('CÓDIGO:', lectura.codigoMedidor ?? '-'),
              _filaDatos('SECTOR:', lectura.sector ?? '-'),
              if (lectura.celular != null) _filaDatos('CEL:', lectura.celular!),
              _filaDatos(
                'FECHA EMISIÓN:',
                fmtFecha.format(lectura.fechaLectura),
              ),

              pw.SizedBox(height: 6),
              _separador(),
              pw.SizedBox(height: 4),

              // ── LECTURAS ────────────────────────────
              _filaDatos(
                'LEC. ANTERIOR:',
                lectura.lecturaAnterior?.toString() ?? '-',
              ),
              _filaDatos('LEC. ACTUAL:', lectura.lectura.toString()),
              _filaDatos('CONSUMO:', '$consumo m³'),

              pw.SizedBox(height: 6),
              _separador(),
              pw.SizedBox(height: 4),

              // ── TABLA DE CONCEPTOS ──────────────────
              _encabezadoTabla(),
              pw.SizedBox(height: 2),

              // Cargo básico
              if (calculo != null)
                _filaTabla(
                  'Cargo básico',
                  '$consumo (v.u ${fmtNum.format(calculo.tarifas.tarifaM3.round())})',
                  '\$${fmtNum.format(calculo.cargoBasico)}',
                ),

              // Consumo
              if (calculo != null && calculo.valorConsumo > 0)
                _filaTabla(
                  'Consumo',
                  '$consumo m³',
                  '\$${fmtNum.format(calculo.valorConsumo)}',
                ),

              // Novedades
              ...novedades.map(
                (n) => _filaTabla(
                  n['concepto'] as String,
                  '${n['cuotas_pendientes']}c',
                  '\$${fmtNum.format(n['total_pendiente'])}',
                ),
              ),

              pw.SizedBox(height: 4),
              _separador(),
              pw.SizedBox(height: 4),

              // ── TOTAL ───────────────────────────────
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 5,
                ),
                decoration: pw.BoxDecoration(border: pw.Border.all(width: 1.5)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      esOficial ? 'TOTAL A PAGAR' : 'TOTAL ESTIMADO',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '\$${fmtNum.format(calculo != null ? totalAPagar : 0)}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (!esOficial) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  '⚠ Estimado. La factura oficial se genera al sincronizar.',
                  style: pw.TextStyle(fontSize: 7, color: PdfColors.orange800),
                  textAlign: pw.TextAlign.center,
                ),
              ],

              // ── LUGAR DE PAGO ───────────────────────
              if (esOficial) ...[
                pw.SizedBox(height: 6),
                _separador(),
                pw.SizedBox(height: 4),
                pw.Container(
                  width: double.infinity,
                  color: PdfColors.black,
                  padding: const pw.EdgeInsets.symmetric(vertical: 3),
                  child: pw.Text(
                    'PAGUE EN:',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                ..._lugaresPago().map(
                  (l) => pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      '• $l',
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                ),
              ],

              pw.SizedBox(height: 6),
              _separador(),
              pw.SizedBox(height: 4),

              pw.Text(
                '¡Gracias por su pago oportuno!',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Conserve este recibo.',
                style: const pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
    );
  }

  pw.Page _buildPagina({
    required Lectura lectura,
    required ComprobanteCalculo calculo,
    required DateTime fecha,
    required TarifasLocal empresa,
    required List<Map<String, dynamic>> novedades,
    int? facturaNumero,
  }) {
    return _buildPaginaCompleta(
      lectura: lectura,
      empresa: empresa,
      calculo: calculo,
      novedades: novedades,
      esOficial: facturaNumero != null,
      facturaNumero: facturaNumero,
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  String _veredasAcueducto() => switch (acueducto.tipo) {
    TipoAcueducto.asoaguapo => 'Veredas El Recreo - Pueblo Nuevo - El Tendido',
    TipoAcueducto.temporal => 'Veredas Alto Corozal - Cachaya - La Floresta',
  };

  List<String> _lugaresPago() => switch (acueducto.tipo) {
    TipoAcueducto.asoaguapo => [
      'COONFIE Cooperativa de Ahorro y Crédito',
      'BANCOLOMBIA Cta. Ahorros N° 285-000-032-12',
    ],
    TipoAcueducto.temporal => ['Consignación a la cuenta del acueducto'],
  };

  pw.Widget _separador() => pw.Divider(thickness: 0.5, color: PdfColors.black);

  pw.Widget _filaDatos(String etiqueta, String valor) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 1),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 90,
          child: pw.Text(etiqueta, style: const pw.TextStyle(fontSize: 8)),
        ),
        pw.Expanded(
          child: pw.Text(
            valor,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  pw.Widget _encabezadoTabla() => pw.Container(
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(width: 0.5),
        top: pw.BorderSide(width: 0.5),
      ),
    ),
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 4,
          child: pw.Text(
            'CONCEPTO',
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            'CANT/BASE',
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            'VALOR',
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    ),
  );

  pw.Widget _filaTabla(String concepto, String cantBase, String valor) =>
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 1),
        child: pw.Row(
          children: [
            pw.Expanded(
              flex: 4,
              child: pw.Text(concepto, style: const pw.TextStyle(fontSize: 8)),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                cantBase,
                style: const pw.TextStyle(fontSize: 8),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                valor,
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ],
        ),
      );

  pw.Widget _fila(String etiqueta, String valor) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 1),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('$etiqueta ', style: const pw.TextStyle(fontSize: 9)),
        pw.Expanded(
          child: pw.Text(
            valor,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  pw.Widget _linea() => pw.Text(
    '- - - - - - - - - - - - - - - - - - - - -',
    style: const pw.TextStyle(fontSize: 8),
  );

  pw.Widget _lineaSimple(String texto, {bool bold = false, double size = 9}) =>
      pw.Center(
        child: pw.Text(
          texto,
          style: pw.TextStyle(
            fontSize: size,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );

  Future<void> compartirPdf(String ruta) async {
    await Share.shareXFiles([
      XFile(ruta),
    ], subject: 'Factura ${acueducto.nombre}');
  }
}
