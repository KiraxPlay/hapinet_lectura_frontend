// lib/services/exportar_service.dart
// es para la exportacion de lecturas a excel y fotos a zip
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import '../models/calculo_consumo.dart';
import '../models/estado_medidor.dart';

class ExportarService {
  final AppDatabase _db;
  final Acueducto acueducto;

  ExportarService(this._db, {required this.acueducto});

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

    final porSector = <String, List<Lectura>>{};
    for (final l in lecturasHoy) {
      final sector = l.sector ?? 'Sin sector';
      porSector.putIfAbsent(sector, () => []).add(l);
    }

    final abonados = await _db.obtenerAbonados();
    final padronPorSector = <String, int>{};
    for (final abonado in abonados) {
      final sector = abonado.sector ?? 'Sin sector';
      padronPorSector[sector] = (padronPorSector[sector] ?? 0) + 1;
    }

    final excel = Excel.createExcel();

    // Crear primero todas las hojas de datos
    for (final entry in porSector.entries) {
      _crearHoja(excel, entry.key, entry.value);
    }
    _crearHojaResumen(excel, porSector, padronPorSector, dia);
    _crearHojaEstadisticas(excel, lecturasHoy, porSector, padronPorSector, dia);

    // Eliminar Sheet1 AL FINAL — después de crear todas las hojas
    // Si se elimina antes, Excel puede recrearlo al acceder a la primera hoja
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final rutaZip = await _crearZip(
      excel: excel,
      nombreBase: nombreBase,
      lecturas: lecturasHoy,
    );

    return rutaZip;
  }

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
          'fotos/$codigo${estado}_${fechaFoto}_${contadorFoto.toString().padLeft(3, '0')}.jpg';

      encoder.addFile(archivo, nombreFoto);
      contadorFoto++;
    }

    encoder.close();
    try { await File(rutaExcelTemp).delete(); } catch (_) {}

    return rutaZip;
  }

  void _crearHoja(Excel excel, String nombreHoja, List<Lectura> lecturas) {
    final hoja = excel[nombreHoja];

    _escribirEncabezado(hoja, [
      'Código', 'Nombre Abonado', 'Lectura Anterior', 'Lectura Actual',
      'Consumo', 'Fecha Lectura', 'Hora Lectura', 'Estado Medidor',
      'Latitud', 'Longitud', 'Observaciones', 'Nombre Foto',
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
            'fotos/$codigo${estado}_${fecha}_${contadorFoto.toString().padLeft(3, '0')}.jpg';
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
      _escribirCeldaNumero(
          hoja, fila, 8, l.latitud != 0 ? l.latitud : null);
      _escribirCeldaNumero(
          hoja, fila, 9, l.longitud != 0 ? l.longitud : null);
      _escribirCelda(hoja, fila, 10, l.notas ?? '');
      _escribirCelda(hoja, fila, 11, nombreFoto ?? 'Sin foto');
    }

    if (lecturas.isNotEmpty) {
      final filaTotales = lecturas.length + 2;
      _escribirCeldaNegrita(hoja, filaTotales, 0, 'TOTAL');
      _escribirCeldaNumero(hoja, filaTotales, 3, lecturas.length);
    }

    _ajustarAnchoColumnas(hoja);
  }

  void _crearHojaResumen(
    Excel excel,
    Map<String, List<Lectura>> porSector,
    Map<String, int> padronPorSector,
    DateTime fecha,
  ) {
    final hoja = excel['Resumen'];

    _escribirCeldaNegrita(
      hoja, 0, 0,
      'REPORTE LECTURAS ${acueducto.nombre} — '
      '${DateFormat('dd/MM/yyyy').format(fecha)}',
    );

    _escribirEncabezadoDesde(hoja, 2, [
      'Sector', 'Padrón Total', 'Leídos', 'Pendientes', 'Cobertura %',
      'Consumo Total', 'Consumo Promedio', 'Sin Lectura (0)',
      'Con Observación', 'Con Foto', 'Con GPS', 'Alertas',
    ]);

    int fila = 3;
    final todos = <Lectura>[];
    final sectores = {...padronPorSector.keys, ...porSector.keys}.toList()..sort();
    for (final sector in sectores) {
      final lecturas = porSector[sector] ?? <Lectura>[];
      _escribirFilaResumen(
        hoja,
        fila,
        sector,
        lecturas,
        padronPorSector[sector] ?? 0,
      );
      todos.addAll(lecturas);
      fila++;
    }

    final filaTotales = fila + 1;
    _escribirCeldaNegrita(hoja, filaTotales, 0, 'TOTAL GENERAL');
    final padronTotal = padronPorSector.values.fold(0, (total, cantidad) => total + cantidad);
    final consumoValido = todos.map(_obtenerConsumoValido).whereType<int>().toList();
    final consumoTotal = consumoValido.fold(0, (total, consumo) => total + consumo);
    _escribirCeldaNumero(hoja, filaTotales, 1, padronTotal);
    _escribirCeldaNumero(hoja, filaTotales, 2, todos.length);
    _escribirCeldaNumero(
      hoja,
      filaTotales,
      3,
      (padronTotal - todos.length).clamp(0, padronTotal),
    );
    _escribirCeldaNumero(
      hoja,
      filaTotales,
      4,
      padronTotal == 0 ? 0 : todos.length * 100 / padronTotal,
    );
    _escribirCeldaNumero(hoja, filaTotales, 5, consumoTotal);
    _escribirCeldaNumero(
      hoja,
      filaTotales,
      6,
      consumoValido.isEmpty ? 0 : consumoTotal / consumoValido.length,
    );
    _escribirCeldaNumero(hoja, filaTotales, 7,
        todos.where((l) => l.lectura == 0).length);
    _escribirCeldaNumero(hoja, filaTotales, 8,
        todos.where((l) => l.notas != null && l.notas!.isNotEmpty).length);
    _escribirCeldaNumero(
        hoja,
        filaTotales,
        9,
        todos
            .where((l) =>
                l.rutaFoto.isNotEmpty && File(l.rutaFoto).existsSync())
            .length);
    _escribirCeldaNumero(hoja, filaTotales, 10, todos.where(_tieneGps).length);
    _escribirCeldaNumero(hoja, filaTotales, 11, todos.where(_tieneAlerta).length);

    _ajustarAnchoColumnas(hoja);
  }

  void _escribirFilaResumen(
      Sheet hoja,
      int fila,
      String sector,
      List<Lectura> lecturas,
      int totalPadron) {
    final consumoValido = lecturas.map(_obtenerConsumoValido).whereType<int>().toList();
    final consumoTotal = consumoValido.fold(0, (total, consumo) => total + consumo);
    _escribirCelda(hoja, fila, 0, sector);
    _escribirCeldaNumero(hoja, fila, 1, totalPadron);
    _escribirCeldaNumero(hoja, fila, 2, lecturas.length);
    _escribirCeldaNumero(
      hoja,
      fila,
      3,
      (totalPadron - lecturas.length).clamp(0, totalPadron),
    );
    _escribirCeldaNumero(
      hoja,
      fila,
      4,
      totalPadron == 0 ? 0 : lecturas.length * 100 / totalPadron,
    );
    _escribirCeldaNumero(hoja, fila, 5, consumoTotal);
    _escribirCeldaNumero(
      hoja,
      fila,
      6,
      consumoValido.isEmpty ? 0 : consumoTotal / consumoValido.length,
    );
    _escribirCeldaNumero(
        hoja, fila, 7, lecturas.where((l) => l.lectura == 0).length);
    _escribirCeldaNumero(
        hoja,
        fila,
        8,
        lecturas
            .where((l) => l.notas != null && l.notas!.isNotEmpty)
            .length);
    _escribirCeldaNumero(
        hoja,
        fila,
        9,
        lecturas
            .where(
                (l) => l.rutaFoto.isNotEmpty && File(l.rutaFoto).existsSync())
            .length);
    _escribirCeldaNumero(hoja, fila, 10, lecturas.where(_tieneGps).length);
    _escribirCeldaNumero(hoja, fila, 11, lecturas.where(_tieneAlerta).length);
  }

  void _crearHojaEstadisticas(
    Excel excel,
    List<Lectura> lecturas,
    Map<String, List<Lectura>> porSector,
    Map<String, int> padronPorSector,
    DateTime fecha,
  ) {
    final hoja = excel['Estadisticas'];
    final consumos = lecturas.map(_obtenerConsumoValido).whereType<int>().toList();
    final consumoTotal = consumos.fold(0, (total, consumo) => total + consumo);
    final padronTotal = padronPorSector.values.fold(0, (total, cantidad) => total + cantidad);
    final estados = <String, int>{};
    final lecturasPorHora = <int, int>{};

    for (final lectura in lecturas) {
      final estado = lectura.estadoMedidor ?? 'No reportado';
      estados[estado] = (estados[estado] ?? 0) + 1;
      final hora = lectura.fechaLectura.hour;
      lecturasPorHora[hora] = (lecturasPorHora[hora] ?? 0) + 1;
    }

    _escribirCeldaNegrita(
      hoja,
      0,
      0,
      'ESTADÍSTICAS ${acueducto.nombre} - ${DateFormat('dd/MM/yyyy').format(fecha)}',
    );
    _escribirEncabezadoDesde(hoja, 2, ['Indicador', 'Valor']);

    final indicadores = <String, num>{
      'Padrón total': padronTotal,
      'Lecturas realizadas': lecturas.length,
      'Lecturas pendientes': (padronTotal - lecturas.length).clamp(0, padronTotal),
      'Cobertura (%)': padronTotal == 0 ? 0 : lecturas.length * 100 / padronTotal,
      'Consumo total válido': consumoTotal,
      'Consumo promedio': consumos.isEmpty ? 0 : consumoTotal / consumos.length,
      'Consumo máximo': consumos.isEmpty ? 0 : consumos.reduce((a, b) => a > b ? a : b),
      'Lecturas en cero': lecturas.where((l) => l.lectura == 0).length,
      'Consumos negativos': lecturas.where((l) => _tieneConsumoNegativo(l)).length,
      'Con fotografía': lecturas.where(_tieneFoto).length,
      'Con GPS': lecturas.where(_tieneGps).length,
      'Con observación': lecturas.where(_tieneObservacion).length,
      'Con alerta': lecturas.where(_tieneAlerta).length,
    };

    var fila = 3;
    for (final entry in indicadores.entries) {
      _escribirCelda(hoja, fila, 0, entry.key);
      _escribirCeldaNumero(hoja, fila, 1, entry.value);
      fila++;
    }

    _escribirEncabezadoDesde(hoja, 2, ['Indicador', 'Valor', 'Estados del medidor', 'Cantidad']);
    var filaEstado = 3;
    for (final entry in estados.entries) {
      _escribirCelda(hoja, filaEstado, 2, entry.key);
      _escribirCeldaNumero(hoja, filaEstado, 3, entry.value);
      filaEstado++;
    }

    const filaHora = 18;
    final primeraHora = lecturasPorHora.keys.isEmpty
        ? 0
        : lecturasPorHora.keys.reduce((a, b) => a < b ? a : b);
    _escribirEncabezadoDesde(hoja, filaHora, ['Hora', 'Lecturas']);
    for (final entry in lecturasPorHora.entries.toList()..sort((a, b) => a.key.compareTo(b.key))) {
      final filaDatos = filaHora + 1 + entry.key - primeraHora;
      _escribirCelda(hoja, filaDatos, 0, '${entry.key}:00');
      _escribirCeldaNumero(hoja, filaDatos, 1, entry.value);
    }

    const filaSector = filaHora + 1 + 24;
    _escribirEncabezadoDesde(hoja, filaSector, ['Sector', 'Lecturas', 'Consumo total', 'Alertas']);
    var filaSectorDatos = filaSector + 1;
    for (final entry in porSector.entries) {
      final consumosSector = entry.value.map(_obtenerConsumoValido).whereType<int>();
      _escribirCelda(hoja, filaSectorDatos, 0, entry.key);
      _escribirCeldaNumero(hoja, filaSectorDatos, 1, entry.value.length);
      _escribirCeldaNumero(
        hoja,
        filaSectorDatos,
        2,
        consumosSector.fold<int>(0, (total, consumo) => total + consumo),
      );
      _escribirCeldaNumero(hoja, filaSectorDatos, 3, entry.value.where(_tieneAlerta).length);
      filaSectorDatos++;
    }

    for (var columna = 0; columna < 4; columna++) {
      hoja.setColumnWidth(columna, columna == 0 ? 32 : 18);
    }
  }

  int? _obtenerConsumoValido(Lectura lectura) {
    return CalculoConsumo.calcular(
      estado:
          EstadoMedidor.desdeClave(lectura.estadoMedidor) ??
          EstadoMedidor.lecturaRealizada,
      lecturaAnterior: lectura.lecturaAnterior,
      lecturaActual: lectura.lectura,
      consumoAnterior: lectura.consumoAnteriorServidor,
    );
  }

  bool _tieneConsumoNegativo(Lectura lectura) =>
      lectura.lecturaAnterior != null && lectura.lectura < lectura.lecturaAnterior!;

  bool _tieneFoto(Lectura lectura) =>
      lectura.rutaFoto.isNotEmpty && File(lectura.rutaFoto).existsSync();

  bool _tieneGps(Lectura lectura) => lectura.latitud != 0 && lectura.longitud != 0;

  bool _tieneObservacion(Lectura lectura) =>
      lectura.notas != null && lectura.notas!.trim().isNotEmpty;

  bool _tieneAlerta(Lectura lectura) =>
      _tieneConsumoNegativo(lectura) ||
      lectura.lectura == 0 ||
      (lectura.estadoMedidor != null && lectura.estadoMedidor != 'bueno');

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
    hoja
        .cell(CellIndex.indexByColumnRow(
            columnIndex: col, rowIndex: fila))
        .value = TextCellValue(valor);
  }

  void _escribirCeldaNumero(Sheet hoja, int fila, int col, num? valor) {
    if (valor == null) return;
    hoja
        .cell(CellIndex.indexByColumnRow(
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