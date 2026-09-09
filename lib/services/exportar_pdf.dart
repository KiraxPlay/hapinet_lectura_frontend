// lib/services/exportar_pdf_service.dart
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:medidor_hapinet_app/services/api/api_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../data/database.dart';
import '../models/acueducto.dart';
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
    180 * PdfPageFormat.mm,
    marginAll: 4 * PdfPageFormat.mm,
  );

  // ─────────────────────────────────────────────
  // FACTURAR EN SITIO
  // Con internet  → servidor calcula (tarifas + novedades) → factura oficial
  // Sin internet  → cálculo local (tarifas guardadas, sin novedades) → estimado
  // ─────────────────────────────────────────────

  Future<FacturaSitioResult> generarFacturaEnSitio({
    required Lectura lectura,
    required int predioId,
  }) async {
    // Intentar con internet primero
    final tieneInternet = await ApiClient.instancia.tieneConexion();

    if (tieneInternet) {
      return await _generarOnline(lectura, predioId);
    } else {
      return await _generarOffline(lectura);
    }
  }

  // ── ONLINE — servidor calcula todo ──────────
  Future<FacturaSitioResult> _generarOnline(
      Lectura lectura, int predioId) async {
    final resultado = await _facturaApi.generarFactura(predioId: predioId);
    if (!resultado.exitoso) {
      // Si falla el servidor, caer a offline
      return await _generarOffline(lectura,
          mensajeExtra: 'Servidor: ${resultado.error}');
    }

    final ruta = await _generarPdf(
      lectura: lectura,
      fecha: DateTime.now(),
      calculo: ComprobanteCalculo(
        consumo:      resultado.consumo ?? 0,
        cargoBasico:  resultado.cargoBasico ?? 0,
        valorConsumo: resultado.valorConsumo ?? 0,
        total:        resultado.total ?? 0,
        esEstimado:   false, // valor oficial
        tarifas:      await _tarifasSvc.obtenerLocal(),
      ),
      facturaNumero: resultado.facturaNumero,
    );

    return FacturaSitioResult.exito(
      rutaPdf: ruta,
      esOficial: true,
      facturaNumero: resultado.facturaNumero,
      total: resultado.total ?? 0,
      cargoBasico: resultado.cargoBasico ?? 0,
      valorConsumo: resultado.valorConsumo ?? 0,
      novedades: resultado.novedades ?? 0,
    );
  }

  // ── OFFLINE — cálculo local ──────────────────
  Future<FacturaSitioResult> _generarOffline(
    Lectura lectura, {
    String? mensajeExtra,
  }) async {
    final tieneTarifas = await _tarifasSvc.tieneTarifasLocales();
    if (!tieneTarifas) {
      return FacturaSitioResult.error(
        'Sin conexión y sin tarifas guardadas.\n'
        'Necesitas conectarte al menos una vez para guardar las tarifas.',
      );
    }

    final calculo = await _tarifasSvc.calcularOffline(
      lecturaActual:   lectura.lectura,
      lecturaAnterior: lectura.lecturaAnterior ?? 0,
    );

    final ruta = await _generarPdf(
      lectura: lectura,
      fecha: DateTime.now(),
      calculo: calculo,
      facturaNumero: null, // sin número oficial offline
    );

    return FacturaSitioResult.exito(
      rutaPdf: ruta,
      esOficial: false,
      facturaNumero: null,
      total: calculo.total,
      cargoBasico: calculo.cargoBasico,
      valorConsumo: calculo.valorConsumo,
      novedades: 0,
      consumoEstimado: calculo.consumo,
      aviso: mensajeExtra ??
          'Comprobante estimado (sin novedades). '
          'Se generará la factura oficial cuando haya conexión.',
    );
  }

  // ─────────────────────────────────────────────
  // GENERAR PDF UNIFICADO
  // ─────────────────────────────────────────────

  Future<String> _generarPdf({
    required Lectura lectura,
    required DateTime fecha,
    required ComprobanteCalculo calculo,
    int? facturaNumero,
  }) async {
    final dir     = await getApplicationDocumentsDirectory();
    final fechaStr = DateFormat('yyyy-MM-dd').format(fecha);
    final sector  = (lectura.sector ?? 'SinSector')
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    final carpeta = Directory(
        '${dir.path}/facturas/${acueducto.nombre}/$sector/$fechaStr');
    if (!await carpeta.exists()) await carpeta.create(recursive: true);

    final codigo = (lectura.codigoMedidor ?? 'SIN_CODIGO')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final ruta = '${carpeta.path}/$codigo.pdf';

    final pdf = pw.Document();
    pdf.addPage(_buildPagina(
      lectura:       lectura,
      calculo:       calculo,
      fecha:         fecha,
      facturaNumero: facturaNumero,
      empresa:       calculo.tarifas,
    ));

    await File(ruta).writeAsBytes(await pdf.save());
    return ruta;
  }

  // ─────────────────────────────────────────────
  // COMPROBANTE SOLO LECTURA (sin cálculo)
  // Para historial cuando no se necesita factura
  // ─────────────────────────────────────────────

  Future<String> exportarFacturaAbonado(
    Lectura lectura, {
    List<Map<String, dynamic>> novedades = const [],
    FacturaSitioResult? resultado,
  }) async {
    print('GENERANDO PDF DE FACTURA PARA ABONADO: ${lectura.codigoMedidor} Y NOVEDADES: ${novedades.length}');
    final dir     = await getApplicationDocumentsDirectory();
    final fechaStr = DateFormat('yyyy-MM-dd').format(lectura.fechaLectura);
    final sector  = (lectura.sector ?? 'SinSector')
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

    final carpeta = Directory(
        '${dir.path}/facturas/${acueducto.nombre}/$sector/$fechaStr');
    if (!await carpeta.exists()) await carpeta.create(recursive: true);

    final codigo = (lectura.codigoMedidor ?? 'SIN_CODIGO')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final ruta = '${carpeta.path}/$codigo.pdf';

    final pdf = pw.Document();
    pdf.addPage(_buildPaginaSoloLectura(lectura, novedades: novedades, resultado: resultado));
    await File(ruta).writeAsBytes(await pdf.save());
    return ruta;
  }

  Future<String> exportarTodasLasFacturasDelDia({DateTime? fecha}) async {
    final dia = fecha ?? DateTime.now();
    final lecturas = await _db.obtenerLecturasRealesDia(dia);
    if (lecturas.isEmpty) throw Exception('No hay lecturas este día');

    final pdf = pw.Document();
    for (final l in lecturas) {
      pdf.addPage(_buildPaginaSoloLectura(l));
    }

    final dir     = await getApplicationDocumentsDirectory();
    final fechaStr = DateFormat('yyyy-MM-dd').format(dia);
    final carpeta = Directory(
        '${dir.path}/facturas/${acueducto.nombre}/$fechaStr');
    if (!await carpeta.exists()) await carpeta.create(recursive: true);

    final ruta =
        '${carpeta.path}/Lecturas_${acueducto.nombre}_$fechaStr.pdf';
    await File(ruta).writeAsBytes(await pdf.save());
    return ruta;
  }

  // ─────────────────────────────────────────────
  // BUILDERS DE PÁGINA
  // ─────────────────────────────────────────────

  pw.Page _buildPagina({
    required Lectura lectura,
    required ComprobanteCalculo calculo,
    required DateTime fecha,
    required TarifasLocal empresa,
    int? facturaNumero,
  }) {
    final fmt     = DateFormat('dd/MM/yyyy');
    final fmtHora = DateFormat('HH:mm');
    final fmtNum  = NumberFormat('#,###', 'es_CO');
    final esOficial = facturaNumero != null;

    return pw.Page(
      pageFormat: _formatoTermico,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Encabezado dinámico desde empresa local
          ..._encabezado(empresa),
          _linea(),
          pw.Center(
            child: pw.Text(
              esOficial ? 'FACTURA DE COBRO' : 'COMPROBANTE DE LECTURA',
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
          if (esOficial)
            pw.Center(
              child: pw.Text('N° $facturaNumero',
                  style: pw.TextStyle(
                      fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ),
          if (!esOficial)
            pw.Center(
              child: pw.Text('VALOR ESTIMADO',
                  style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.orange700)),
            ),
          _linea(),
          pw.SizedBox(height: 4),

          // Datos abonado
          pw.Text(lectura.nombreAbonado ?? 'Sin nombre',
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          _fila('Código:', lectura.codigoMedidor ?? '-'),
          _fila('Sector:', lectura.sector ?? '-'),
          if (lectura.celular != null) _fila('Celular:', lectura.celular!),
          _fila('Fecha:', fmt.format(fecha)),
          _fila('Hora:', fmtHora.format(lectura.fechaLectura)),
          pw.SizedBox(height: 6),
          _linea(),
          pw.SizedBox(height: 4),

          // Lecturas
          _fila('Lectura anterior:', lectura.lecturaAnterior?.toString() ?? '-'),
          _fila('Lectura actual:', lectura.lectura.toString()),
          _fila('Consumo:', '${calculo.consumo} m³'),
          pw.SizedBox(height: 6),
          _linea(),
          pw.SizedBox(height: 4),

          // Desglose
          pw.Text('DESGLOSE',
              style: pw.TextStyle(
                  fontSize: 9, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 3),
          _fila('Cargo básico:',
              '\$${fmtNum.format(calculo.cargoBasico)}'),
          _fila('Consumo (${calculo.consumo} m³):',
              '\$${fmtNum.format(calculo.valorConsumo)}'),
          if (!esOficial)
            pw.Text('* Novedades no incluidas (sin conexión)',
                style: pw.TextStyle(
                    fontSize: 7, color: PdfColors.orange700)),
          pw.SizedBox(height: 4),
          _linea(),
          pw.SizedBox(height: 4),

          // Total
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                esOficial ? 'TOTAL A PAGAR' : 'TOTAL ESTIMADO',
                style: pw.TextStyle(
                    fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('\$${fmtNum.format(calculo.total)}',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),

          if (!esOficial) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              '⚠ Este valor es una estimación. La factura oficial\n'
              'se generará cuando el técnico tenga conexión.',
              style: pw.TextStyle(
                  fontSize: 7, color: PdfColors.orange700),
            ),
          ],

          pw.SizedBox(height: 8),
          _linea(),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text('Gracias por su pago puntual',
                style: const pw.TextStyle(fontSize: 8)),
          ),
          pw.Center(
            child: pw.Text(
              empresa.empresaNombre.isNotEmpty
                  ? empresa.empresaNombre
                  : acueducto.nombre,
              style: const pw.TextStyle(fontSize: 7),
            ),
          ),
        ],
      ),
    );
  }

  pw.Page _buildPaginaSoloLectura(
    Lectura l, {
    List<Map<String, dynamic>> novedades = const [],
    FacturaSitioResult? resultado,
  }) {
    final fmt     = DateFormat('dd/MM/yyyy');
    final fmtHora = DateFormat('HH:mm');
    final estado = switch (l.estadoMedidor) {
      'danado'          => 'Dañado',
      'empanado'        => 'Empañado',
      'con_fuga'        => 'Con fuga',
      'sin_contador'    => 'Sin contador',
      'acceso_denegado' => 'Acceso denegado',
      _                 => 'Sin novedad',
    };

    return pw.Page(
      pageFormat: _formatoTermico,
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _lineaSimple(acueducto.nombre, bold: true, size: 14),
          _lineaSimple('Acueducto Comunitario — Gigante, Huila', size: 8),
          _lineaSimple(_nitAcueducto(), size: 8),
          pw.SizedBox(height: 4),
          _linea(),
          _lineaSimple('COMPROBANTE DE LECTURA', bold: true, size: 10),
          _linea(),
          pw.SizedBox(height: 4),
          pw.Text(l.nombreAbonado ?? 'Sin nombre',
              style: pw.TextStyle(
                  fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          _fila('Código:', l.codigoMedidor ?? '-'),
          _fila('Sector:', l.sector ?? '-'),
          if (l.celular != null) _fila('Celular:', l.celular!),
          _fila('Fecha:', fmt.format(l.fechaLectura)),
          _fila('Hora:', fmtHora.format(l.fechaLectura)),
          pw.SizedBox(height: 6),
          _linea(),
          pw.SizedBox(height: 4),
          _fila('Lectura anterior:', l.lecturaAnterior?.toString() ?? '-'),
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
          pw.SizedBox(height: 6),
          _linea(),
          pw.SizedBox(height: 4),
          _fila('Estado medidor:', estado),
          if (l.notas != null && l.notas!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text('Observaciones:',
                style: pw.TextStyle(
                    fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.Text(l.notas!, style: const pw.TextStyle(fontSize: 8)),
          ],
          // ── NOVEDADES ────────────────────────────
          if (novedades.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            _linea(),
            pw.SizedBox(height: 4),
            pw.Text('NOVEDADES PENDIENTES',
                style: pw.TextStyle(
                    fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 3),
            ...novedades.map((n) {
              final fmtN = NumberFormat('#,###', 'es_CO');
              return _fila(
                '${n['concepto']}:',
                '\$${fmtN.format(n['valor_cuota'])} x'
                '${n['cuotas_pendientes']}c ='
                ' \$${fmtN.format(n['total_pendiente'])}',
              );
            }),
          ],

          // ── TOTAL (si viene del comprobante) ─────
          if (resultado != null) ...[
            pw.SizedBox(height: 6),
            _linea(),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  resultado.esOficial ? 'TOTAL A PAGAR' : 'TOTAL ESTIMADO',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(resultado.totalFormateado,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],

          pw.SizedBox(height: 8),
          _linea(),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text('Gracias por su colaboracion',
                style: const pw.TextStyle(fontSize: 8)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  List<pw.Widget> _encabezado(TarifasLocal empresa) => [
    pw.Center(
      child: pw.Text(
        empresa.empresaNombre.isNotEmpty
            ? empresa.empresaNombre
            : acueducto.nombre,
        style: pw.TextStyle(
            fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    ),
    pw.Center(
      child: pw.Text('Acueducto Comunitario — Gigante, Huila',
          style: const pw.TextStyle(fontSize: 8)),
    ),
    if (empresa.empresaNit.isNotEmpty)
      pw.Center(
        child: pw.Text('NIT: ${empresa.empresaNit}',
            style: const pw.TextStyle(fontSize: 8)),
      ),
    if (empresa.empresaTelefono.isNotEmpty)
      pw.Center(
        child: pw.Text('Tel: ${empresa.empresaTelefono}',
            style: const pw.TextStyle(fontSize: 8)),
      ),
    if (empresa.empresaEmail.isNotEmpty)
      pw.Center(
        child: pw.Text(empresa.empresaEmail,
            style: const pw.TextStyle(fontSize: 8)),
      ),
    pw.SizedBox(height: 4),
  ];

  String _nitAcueducto() => switch (acueducto.tipo) {
        TipoAcueducto.asoaguapo => 'NIT: 900358329-1',
        TipoAcueducto.aguaviva  => 'NIT: 900191061-2',
      };

  pw.Widget _fila(String etiqueta, String valor) => pw.Padding(
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

  pw.Widget _linea() => pw.Text(
        '- - - - - - - - - - - - - - - - - - - - -',
        style: const pw.TextStyle(fontSize: 8),
      );

  pw.Widget _lineaSimple(String texto,
          {bool bold = false, double size = 9}) =>
      pw.Center(
        child: pw.Text(texto,
            style: pw.TextStyle(
                fontSize: size,
                fontWeight:
                    bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      );

  Future<void> compartirPdf(String ruta) async {
    await Share.shareXFiles(
      [XFile(ruta)],
      subject: 'Factura ${acueducto.nombre}',
    );
  }
}

// ─────────────────────────────────────────────
// RESULTADO DE FACTURACIÓN EN SITIO
// ─────────────────────────────────────────────

class FacturaSitioResult {
  final bool exitoso;
  final String? error;
  final String? rutaPdf;
  final bool esOficial;
  final int? facturaNumero;
  final int total;
  final String? aviso;
  // Desglose para mostrar en ComprobanteScreen
  final int cargoBasico;
  final int valorConsumo;
  final int novedades;
  final int? consumoEstimado;

  const FacturaSitioResult._({
    required this.exitoso,
    this.error,
    this.rutaPdf,
    this.esOficial = false,
    this.facturaNumero,
    this.total = 0,
    this.aviso,
    this.cargoBasico = 0,
    this.valorConsumo = 0,
    this.novedades = 0,
    this.consumoEstimado,
  });

  factory FacturaSitioResult.exito({
    required String rutaPdf,
    required bool esOficial,
    required int total,
    int? facturaNumero,
    String? aviso,
    int cargoBasico = 0,
    int valorConsumo = 0,
    int novedades = 0,
    int? consumoEstimado,
  }) =>
      FacturaSitioResult._(
        exitoso: true,
        rutaPdf: rutaPdf,
        esOficial: esOficial,
        facturaNumero: facturaNumero,
        total: total,
        aviso: aviso,
        cargoBasico: cargoBasico,
        valorConsumo: valorConsumo,
        novedades: novedades,
        consumoEstimado: consumoEstimado,
      );

  factory FacturaSitioResult.error(String msg) =>
      FacturaSitioResult._(exitoso: false, error: msg);

  // Getters para ComprobanteScreen
  int get cargoBasicoMostrar => cargoBasico;
  int get valorConsumoMostrar => valorConsumo;
  int get novedadesMostrar => novedades;

  String get totalFormateado => '\$${total.toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.')}';
}