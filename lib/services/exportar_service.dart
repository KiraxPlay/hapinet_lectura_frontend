// lib/services/exportar_service.dart
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/database.dart';
import '../models/acueducto.dart';

class ExportarService {
  final AppDatabase _db;
  final Acueducto acueducto;

  ExportarService(this._db, {required this.acueducto});

  // ─────────────────────────────────────────────
  // EXPORTAR LECTURAS DEL DÍA + FOTOS
  // ─────────────────────────────────────────────

  Future<String> exportarLecturasDia({DateTime? fecha}) async {
    final dia = fecha ?? DateTime.now();
    final nombreBase =
        '${acueducto.nombre}_${DateFormat('yyyy-MM-dd').format(dia)}';

    final todasLecturas = await _db.obtenerLecturasReales();
    final lecturasHoy = todasLecturas
        .where((l) =>
            l.fechaLectura.year == dia.year &&
            l.fechaLectura.month == dia.month &&
            l.fechaLectura.day == dia.day)
        .toList();

    // Agrupar por sector dinámicamente
    final porSector = <String, List<Lectura>>{};
    for (final l in lecturasHoy) {
      final sector = l.sector ?? 'Sin sector';
      porSector.putIfAbsent(sector, () => []).add(l);
    }

    // Crear Excel con una hoja por sector
    final excel = Excel.createExcel();
    excel.delete('Sheet1');
    for (final entry in porSector.entries) {
      _crearHoja(excel, entry.key, entry.value);
    }
    _crearHojaResumen(excel, porSector, dia);

    final rutaZip = await _crearZip(
      excel: excel,
      nombreBase: nombreBase,
      lecturas: lecturasHoy,
    );

    return rutaZip;
  }

  // ─────────────────────────────────────────────
  // CREAR ZIP
  // ─────────────────────────────────────────────

  Future<String> _crearZip({
    required Excel excel,
    required String nombreBase,
    required List<Lectura> lecturas,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final carpeta = Directory('${dir.path}/exportaciones');
    if (!await carpeta.exists()) await carpeta.create(recursive: true);

    final encoder = ZipFileEncoder();
    final rutaZip = '${carpeta.path}/$nombreBase.zip';
    encoder.create(rutaZip);

    final bytesExcel = excel.encode();
    if (bytesExcel == null) throw Exception('Error al generar el Excel');

    final rutaExcelTemp = '${carpeta.path}/${nombreBase}_temp.xlsx';
    await File(rutaExcelTemp).writeAsBytes(bytesExcel);
    encoder.addFile(File(rutaExcelTemp), '$nombreBase.xlsx');

    int contadorFoto = 1;
    for (final lectura in lecturas) {
      if (lectura.rutaFoto.isEmpty) continue;
      final archivo = File(lectura.rutaFoto);
      if (!await archivo.exists()) continue;

      final codigo = (lectura.codigoMedidor ?? 'SIN_CODIGO')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final estado = lectura.estadoMedidor != null
          ? '_${lectura.estadoMedidor!.replaceAll(' ', '_')}'
          : '';
      final fechaFoto =
          DateFormat('yyyyMMdd_HHmm').format(lectura.fechaLectura);
      final nombreFoto =
          'fotos/${codigo}${estado}_${fechaFoto}_${contadorFoto.toString().padLeft(3, '0')}.jpg';

      encoder.addFile(archivo, nombreFoto);
      contadorFoto++;
    }

    encoder.close();
    try { await File(rutaExcelTemp).delete(); } catch (_) {}

    return rutaZip;
  }

  // ─────────────────────────────────────────────
  // CREAR HOJA POR SECTOR — dinámica
  // ─────────────────────────────────────────────

  void _crearHoja(
      Excel excel, String nombreHoja, List<Lectura> lecturas) {
    final hoja = excel[nombreHoja];

    _escribirEncabezado(hoja, [
      'Código', 'Nombre Abonado', 'Lectura Anterior', 'Lectura Actual',
      'Consumo', 'Fecha Lectura', 'Hora Lectura', 'Estado Medidor',
      'Latitud', 'Longitud', 'Precisión GPS (m)', 'Observaciones',
      'Nombre Foto',
    ]);

    int contadorFoto = 1;
    for (int i = 0; i < lecturas.length; i++) {
      final l = lecturas[i];
      final fila = i + 1;
      final consumo = (l.lecturaAnterior != null && l.lectura > 0)
          ? l.lectura - l.lecturaAnterior!
          : null;

      String? nombreFoto;
      if (l.rutaFoto.isNotEmpty && File(l.rutaFoto).existsSync()) {
        final codigo = (l.codigoMedidor ?? 'SIN_CODIGO')
            .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        final estado = l.estadoMedidor != null
            ? '_${l.estadoMedidor!.replaceAll(' ', '_')}'
            : '';
        final fecha = DateFormat('yyyyMMdd_HHmm').format(l.fechaLectura);
        nombreFoto =
            'fotos/${codigo}${estado}_${fecha}_${contadorFoto.toString().padLeft(3, '0')}.jpg';
        contadorFoto++;
      }

      _escribirCelda(hoja, fila, 0, l.codigoMedidor ?? '');
      _escribirCelda(hoja, fila, 1, l.nombreAbonado ?? l.notas ?? '');
      _escribirCeldaNumero(hoja, fila, 2, l.lecturaAnterior);
      _escribirCeldaNumero(hoja, fila, 3, l.lectura);
      _escribirCeldaNumero(hoja, fila, 4, consumo);
      _escribirCelda(hoja, fila, 5,
          DateFormat('dd/MM/yyyy').format(l.fechaLectura));
      _escribirCelda(hoja, fila, 6,
          DateFormat('HH:mm:ss').format(l.fechaLectura));
      _escribirCelda(hoja, fila, 7, l.estadoMedidor ?? 'No reportado');
      _escribirCeldaNumero(hoja, fila, 8, l.latitud != 0 ? l.latitud : null);
      _escribirCeldaNumero(hoja, fila, 9, l.longitud != 0 ? l.longitud : null);
      _escribirCeldaNumero(hoja, fila, 10, l.precision);
      _escribirCelda(hoja, fila, 11, l.notas ?? '');
      _escribirCelda(hoja, fila, 12, nombreFoto ?? 'Sin foto');
    }

    if (lecturas.isNotEmpty) {
      final filaTotales = lecturas.length + 2;
      _escribirCeldaNegrita(hoja, filaTotales, 0, 'TOTAL');
      _escribirCeldaNumero(hoja, filaTotales, 3, lecturas.length);
    }

    _ajustarAnchoColumnas(hoja);
  }

  // ─────────────────────────────────────────────
  // HOJA DE RESUMEN — dinámica
  // ─────────────────────────────────────────────

  void _crearHojaResumen(
    Excel excel,
    Map<String, List<Lectura>> porSector,
    DateTime fecha,
  ) {
    final hoja = excel['Resumen'];

    _escribirCeldaNegrita(
      hoja, 0, 0,
      'REPORTE LECTURAS ${acueducto.nombre} — '
      '${DateFormat('dd/MM/yyyy').format(fecha)}',
    );

    _escribirEncabezadoDesde(hoja, 2, [
      'Sector', 'Total Leídos', 'Sin Lectura (0)',
      'Con Observación', 'Con Foto',
    ]);

    int fila = 3;
    final todos = <Lectura>[];
    for (final entry in porSector.entries) {
      _escribirFilaResumen(hoja, fila, entry.key, entry.value);
      todos.addAll(entry.value);
      fila++;
    }

    final filaTotales = fila + 1;
    _escribirCeldaNegrita(hoja, filaTotales, 0, 'TOTAL GENERAL');
    _escribirCeldaNumero(hoja, filaTotales, 1, todos.length);
    _escribirCeldaNumero(hoja, filaTotales, 2,
        todos.where((l) => l.lectura == 0).length);
    _escribirCeldaNumero(hoja, filaTotales, 3,
        todos.where((l) => l.notas != null && l.notas!.isNotEmpty).length);
    _escribirCeldaNumero(hoja, filaTotales, 4,
        todos.where((l) =>
            l.rutaFoto.isNotEmpty && File(l.rutaFoto).existsSync()).length);

    _ajustarAnchoColumnas(hoja);
  }

  void _escribirFilaResumen(
      Sheet hoja, int fila, String sector, List<Lectura> lecturas) {
    _escribirCelda(hoja, fila, 0, sector);
    _escribirCeldaNumero(hoja, fila, 1, lecturas.length);
    _escribirCeldaNumero(hoja, fila, 2,
        lecturas.where((l) => l.lectura == 0).length);
    _escribirCeldaNumero(hoja, fila, 3,
        lecturas.where((l) => l.notas != null && l.notas!.isNotEmpty).length);
    _escribirCeldaNumero(hoja, fila, 4,
        lecturas.where((l) =>
            l.rutaFoto.isNotEmpty && File(l.rutaFoto).existsSync()).length);
  }

  // ─────────────────────────────────────────────
  // HELPERS DE ESCRITURA
  // ─────────────────────────────────────────────

  void _escribirEncabezado(Sheet hoja, List<String> columnas) =>
      _escribirEncabezadoDesde(hoja, 0, columnas);

  void _escribirEncabezadoDesde(
      Sheet hoja, int fila, List<String> columnas) {
    for (int i = 0; i < columnas.length; i++) {
      final celda = hoja.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: fila));
      celda.value = TextCellValue(columnas[i]);
      celda.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#1976D2'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
      );
    }
  }

  void _escribirCelda(Sheet hoja, int fila, int col, String valor) {
    hoja.cell(CellIndex.indexByColumnRow(
            columnIndex: col, rowIndex: fila))
        .value = TextCellValue(valor);
  }

  void _escribirCeldaNumero(Sheet hoja, int fila, int col, num? valor) {
    if (valor == null) return;
    hoja.cell(CellIndex.indexByColumnRow(
            columnIndex: col, rowIndex: fila))
        .value = DoubleCellValue(valor.toDouble());
  }

  void _escribirCeldaNegrita(
      Sheet hoja, int fila, int col, String valor) {
    final celda = hoja.cell(
        CellIndex.indexByColumnRow(columnIndex: col, rowIndex: fila));
    celda.value = TextCellValue(valor);
    celda.cellStyle = CellStyle(bold: true);
  }

  void _ajustarAnchoColumnas(Sheet hoja) {
    hoja.setColumnWidth(0, 18);
    hoja.setColumnWidth(1, 35);
    hoja.setColumnWidth(2, 16);
    hoja.setColumnWidth(3, 14);
    hoja.setColumnWidth(4, 10);
    hoja.setColumnWidth(5, 14);
    hoja.setColumnWidth(6, 12);
    hoja.setColumnWidth(7, 18);
    hoja.setColumnWidth(8, 14);
    hoja.setColumnWidth(9, 14);
    hoja.setColumnWidth(10, 16);
    hoja.setColumnWidth(11, 40);
    hoja.setColumnWidth(12, 35);
  }

  Future<void> compartirArchivo(String ruta) async {
    await Share.shareXFiles(
      [XFile(ruta)],
      subject: 'Lecturas de medidores ${acueducto.nombre}',
      text: 'Reporte de lecturas generado desde la app',
    );
  }
}