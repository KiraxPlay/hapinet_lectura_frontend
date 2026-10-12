// lib/services/impresora_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import '../models/resultado_impresion.dart';
import 'api/tarifas_service.dart';

class ImpresoraService {
  static const _keyMac = 'impresora_mac_address';
  static const _keyNombre = 'impresora_nombre';
  final Acueducto acueducto;

  ImpresoraService({required this.acueducto});

  // ─────────────────────────────────────────────
  // PERSISTENCIA
  // ─────────────────────────────────────────────

  Future<void> guardarImpresora(String mac, String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMac, mac);
    await prefs.setString(_keyNombre, nombre);
  }

  Future<String?> obtenerMacGuardada() async =>
      (await SharedPreferences.getInstance()).getString(_keyMac);

  Future<String?> obtenerNombreGuardado() async =>
      (await SharedPreferences.getInstance()).getString(_keyNombre);

  // ─────────────────────────────────────────────
  // IMPRIMIR COMPROBANTE
  // ─────────────────────────────────────────────

  Future<ResultadoImpresion> imprimir({
    required Lectura lectura,
    required List<Map<String, dynamic>> novedades,
    int total = 0,
    bool esOficial = false,
    int? facturaNumero,
    String? macAddress,
  }) async {
    try {
      final mac = macAddress ?? await obtenerMacGuardada();
      if (mac == null) {
        return ResultadoImpresion.error(
          'No hay impresora configurada. Ve a Ajustes → Impresora.',
        );
      }

      final empresa = await TarifasService(acueducto: acueducto).obtenerLocal();
      final bytes = _generarESCPOS(
        lectura: lectura,
        empresa: empresa,
        novedades: novedades,
        total: total,
        esOficial: esOficial,
        facturaNumero: facturaNumero,
      );

      await FlutterBluetoothPrinter.printBytes(
        address: mac,
        data: bytes,
        keepConnected: false,
      );

      return ResultadoImpresion.exito();
    } catch (e) {
      return ResultadoImpresion.error('Error al imprimir: $e');
    }
  }

  Future<ResultadoImpresion> imprimirPdf({required String rutaPdf}) async {
    try {
      final pdf = await File(rutaPdf).readAsBytes();
      final impreso = await Printing.layoutPdf(
        name: 'Factura',
        format: const PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 3 * PdfPageFormat.mm,
        ),
        onLayout: (_) async => pdf,
      );

      return impreso
          ? ResultadoImpresion.exito()
          : ResultadoImpresion.error('La impresión fue cancelada');
    } catch (e) {
      return ResultadoImpresion.error('Error al imprimir el PDF: $e');
    }
  }

  // ─────────────────────────────────────────────
  // PRUEBA DE IMPRESIÓN
  // ─────────────────────────────────────────────

  Future<ResultadoImpresion> imprimirPrueba(String mac) async {
    try {
      final bytes = _prueba();
      await FlutterBluetoothPrinter.printBytes(
        address: mac,
        data: bytes,
        keepConnected: false,
      );
      return ResultadoImpresion.exito();
    } catch (e) {
      return ResultadoImpresion.error('Error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // GENERADOR ESC/POS
  // ─────────────────────────────────────────────

  Uint8List _generarESCPOS({
    required Lectura lectura,
    required TarifasLocal empresa,
    required List<Map<String, dynamic>> novedades,
    required int total,
    required bool esOficial,
    int? facturaNumero,
  }) {
    final fmtNum = NumberFormat('#,###', 'es_CO');
    final fmtFecha = DateFormat('yyyy-MM-dd');
    final consumo = (lectura.lectura - (lectura.lecturaAnterior ?? 0)).clamp(
      0,
      999999,
    );

    final buf = <int>[];

    // ESC @ — inicializar impresora
    buf.addAll([0x1B, 0x40]);

    void addText(String text) {
      buf.addAll(text.codeUnits);
      buf.add(0x0A); // LF
    }

    void bold(bool on) => buf.addAll([0x1B, 0x45, on ? 1 : 0]);
    void alignCenter() => buf.addAll([0x1B, 0x61, 1]);
    void alignLeft() => buf.addAll([0x1B, 0x61, 0]);
    void alignRight() => buf.addAll([0x1B, 0x61, 2]);
    void doubleSize(bool on) => buf.addAll([0x1D, 0x21, on ? 0x11 : 0x00]);
    void feed(int n) => buf.addAll([0x1B, 0x64, n]);
    void cut() => buf.addAll([0x1D, 0x56, 0x41, 0x00]);
    void hr() {
      alignLeft();
      addText('--------------------------------');
    }

    String centered(String text, int width) {
      final value = text.length > width ? text.substring(0, width) : text;
      final leftPadding = (width - value.length) ~/ 2;
      return value.padLeft(leftPadding + value.length).padRight(width);
    }

    // ── ENCABEZADO ──────────────────────────────
    alignCenter();
    bold(true);
    doubleSize(true);
    addText(
      empresa.empresaNombre.isNotEmpty
          ? empresa.empresaNombre.toUpperCase()
          : acueducto.nombre.toUpperCase(),
    );
    doubleSize(false);
    bold(false);

    addText('ASOCIACION DE AGUA POTABLE');
    if (empresa.empresaNit.isNotEmpty) addText('NIT: ${empresa.empresaNit}');
    addText(_veredas());
    if (empresa.empresaTelefono.isNotEmpty) {
      addText('Cel: ${empresa.empresaTelefono}');
    }

    hr();

    // ── TIPO DOCUMENTO ───────────────────────────
    bold(true);
    addText(esOficial ? 'FACTURA DE VENTA' : 'COMPROBANTE DE LECTURA');
    bold(false);
    if (facturaNumero != null) addText('No. $facturaNumero');
    if (!esOficial) addText('*** VALOR ESTIMADO ***');

    hr();

    // ── DATOS ABONADO ────────────────────────────
    alignLeft();
    addText('ABONADO:');
    bold(true);
    addText((lectura.nombreAbonado ?? '').toUpperCase());
    bold(false);
    addText('CODIGO:   ${lectura.codigoMedidor ?? '-'}');
    addText('SECTOR:   ${lectura.sector ?? '-'}');
    addText('FECHA:    ${fmtFecha.format(lectura.fechaLectura)}');

    hr();

    // ── LECTURAS ─────────────────────────────────
    const anchoAnterior = 14;
    const anchoActual = 13;
    const anchoConsumo = 15;
    addText(
      centered('LEC. ANTERIOR', anchoAnterior) +
          centered('LEC. ACTUAL', anchoActual) +
          centered('CONSUMO', anchoConsumo),
    );
    bold(true);
    addText(
      centered('${lectura.lecturaAnterior ?? '-'}', anchoAnterior) +
          centered('${lectura.lectura}', anchoActual) +
          centered('$consumo m3', anchoConsumo),
    );
    bold(false);

    hr();

    // ── TABLA CONCEPTOS ──────────────────────────
    bold(true);
    addText('CONCEPTO        CANT    VALOR');
    bold(false);
    hr();

    // Cargo básico
    addText(_col3('Cargo basico', '$consumo', '\$${fmtNum.format(total)}'));

    // Novedades
    for (final n in novedades) {
      addText(
        _col3(
          '${n['concepto']}',
          '${n['cuotas_pendientes']}c',
          '\$${fmtNum.format(n['total_pendiente'])}',
        ),
      );
    }

    hr();

    // ── TOTAL ────────────────────────────────────
    bold(true);
    doubleSize(true);
    addText(esOficial ? 'TOTAL A PAGAR' : 'TOTAL');
    alignRight();
    addText('\$${fmtNum.format(total)}');
    doubleSize(false);
    bold(false);
    alignLeft();

    hr();

    // ── CÓDIGO ───────────────────────────────────
    alignCenter();
    addText(
      '*${lectura.codigoMedidor}-'
      '${DateFormat('yyyyMM').format(lectura.fechaLectura)}*',
    );

    hr();

    bold(true);
    addText('Gracias por su pago oportuno!');
    bold(false);
    addText('Conserve este tiquete.');

    feed(3);

    buf.add(0x0A);
    buf.add(0x0A);

    buf.addAll([0x1D, 0x56, 0x41, 0x00]); // Cortar papel
    cut();

    return Uint8List.fromList(buf);
  }


  //para la prueba de impresion pero dentro de la app
  //no el de la app oficial de la impresora
  Uint8List _prueba() {
    final buf = <int>[];
    buf.addAll([0x1B, 0x40]); // Inicializar impresora
    buf.addAll([0x1B, 0x61, 1]); // Centrar texto
    buf.addAll([0x1B, 0x45, 1]); // Activar negrita
    buf.addAll('PRUEBA DE IMPRESION'.codeUnits);
    buf.add(0x0A);
    buf.addAll([0x1B, 0x45, 0]); // Desactivar negrita
    buf.addAll('CONEXION EXITOSA CON SAT AF330'.codeUnits);
    buf.add(0x0A); // Salto de línea
    buf.addAll([0x1B, 0x64, 3]); // Avanzar 3 líneas
    buf.addAll([0x1B, 0x61, 0]); // Alinear a la izquierda
    buf.addAll([0x1B, 0x45, 1]);
    buf.addAll('HAPINET S.A.S'.codeUnits);
    buf.add(0x0A);
    buf.addAll([0x1B, 0x64, 3]); // Avanzar antes de cortar
    buf.addAll([0x1D, 0x56, 0x41, 0x00]); // Cortar papel
    return Uint8List.fromList(buf);
  }

  // Columna 3 — ancho fijo 32 chars
  String _col3(String c1, String c2, String c3) {
    final s1 = c1.padRight(16).substring(0, 16);
    final s2 = c2.padLeft(6);
    final s3 = c3.padLeft(10);
    return '$s1$s2$s3';
  }

  String _veredas() => switch (acueducto.tipo) {
    TipoAcueducto.asoaguapo => 'Veredas El Recreo - Pueblo Nuevo - El Tendido',
    TipoAcueducto.temporal => 'Veredas Alto Corozal - Cachaya - La Floresta',//esto seria temporal todo lo de tipo de 
    // TipoAcueducto.temporal es temporal 
  };
}
