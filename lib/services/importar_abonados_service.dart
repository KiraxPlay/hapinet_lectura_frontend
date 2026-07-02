// lib/services/importar_abonados_service.dart
import 'package:drift/drift.dart' show Value , InsertMode;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database.dart';
import 'abonados_service.dart';

class ImportarAbonadosService {
  final AppDatabase _db;
  final String _jsonAsset;
  final String _keyImportado;
  final String _keyLimpiado;

  ImportarAbonadosService({
    required AppDatabase db,
    required String jsonAsset,
    required String acueductoId, // 'asoaguapo' o 'aguaviva'
  })  : _db = db,
        _jsonAsset = jsonAsset,
        _keyImportado = 'abonados_importados_${acueductoId}_v8',
        _keyLimpiado = 'abonados_limpiados_${acueductoId}_v4';

  // Genera el ID interno normalizando ceros
  // PUE-101-001 → abonado_pue_101_1
  // PUE-101-120 → abonado_pue_101_120
  static String _generarId(String codigo) {
    final partes = codigo
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .split('_')
        .where((p) => p.isNotEmpty)
        .toList();

    if (partes.isNotEmpty) {
      final ultimo = int.tryParse(partes.last);
      if (ultimo != null) {
        partes[partes.length - 1] = ultimo.toString();
      }
    }

    return 'abonado_${partes.join('_')}';
  }

  Future<ImportacionResult> importar() async {
    final prefs = await SharedPreferences.getInstance();

    // ── Paso 1: limpiar duplicados si nunca se ha hecho ──
    // Esto borra TODOS los abonados sin lectura real
    // y los reimporta limpios desde el JSON
    final yaLimpio = prefs.getBool(_keyLimpiado) ?? false;
    if (!yaLimpio) {
      await _limpiarYReimportar(prefs);
      return const ImportacionResult(total: 0, nuevos: 0, yaExistia: false);
    }

    // ── Paso 2: importación normal (primera vez o nueva versión) ──
    if (prefs.getBool(_keyImportado) == true) {
      return const ImportacionResult(total: 0, nuevos: 0, yaExistia: true);
    }

    await _importarDesdeJson(prefs);
    return const ImportacionResult(total: 0, nuevos: 0, yaExistia: false);
  }

  // Borra todos los abonados de la BD y los reimporta desde el JSON
  // Preserva las lecturas ya tomadas (tieneLecturaReal = true)
  Future<void> _limpiarYReimportar(SharedPreferences prefs) async {
    // Borrar solo abonados SIN lectura real (pendientes)
    // Los que ya tienen lectura se conservan
    await _db.eliminarAbonadosSinLectura();

    // Reimportar desde el JSON
    await _importarDesdeJson(prefs);

    // Marcar como limpio para no volver a hacerlo
    await prefs.setBool(_keyLimpiado, true);
  }

  Future<void> _importarDesdeJson(SharedPreferences prefs) async {
    AbonadosService.limpiarCache(_jsonAsset);
    final service = AbonadosService(jsonAsset: _jsonAsset);
    final abonados = await service.cargarTodos();

    // Eliminar duplicados del JSON por ID normalizado
    final idsVistos = <String>{};
    final abonadosSinDuplicados = abonados.where((a) {
      return idsVistos.add(_generarId(a.codigo));
    }).toList();

    // Preparar todos los companions de una vez
    final companions = <LecturasCompanion>[];
    for (int i = 0; i < abonadosSinDuplicados.length; i++) {
      final abonado = abonadosSinDuplicados[i];
      companions.add(
        LecturasCompanion.insert(
          id: _generarId(abonado.codigo),
          lectura: abonado.lecturaActual ?? 0,
          textoCrudo: '',
          rutaFoto: '',
          latitud: abonado.latitud ?? 0.0,
          longitud: abonado.longitud ?? 0.0,
          fechaLectura: DateTime.now(),
          estadoSync: const Value('pendiente'),
          codigoMedidor: Value(abonado.codigo),
          nombreAbonado: Value(abonado.nombre),
          sector: Value(abonado.sector),
          esAbonado: const Value(true),
          tieneLecturaReal: const Value(false),
          celular: Value(abonado.celular),
          ordenRuta: Value(i + 1),
        ),
      );
    }

    // Insertar todos en una sola transacción con batch
    // Se divide en chunks de 100 para evitar límites de SQLite
    // (SQLite tiene un máximo de ~999 variables por sentencia)
    await _db.transaction(() async {
      const tamanoChunk = 100;
      for (int i = 0; i < companions.length; i += tamanoChunk) {
        final fin = (i + tamanoChunk < companions.length)
            ? i + tamanoChunk
            : companions.length;
        final chunk = companions.sublist(i, fin);

        await _db.batch((batch) {
          batch.insertAll(
            _db.lecturas,
            chunk,
            mode: InsertMode.insertOrIgnore,
          );
        });
      }
    });

    await prefs.setBool(_keyImportado, true);
  }
}

class ImportacionResult {
  final int total;
  final int nuevos;
  final bool yaExistia;

  const ImportacionResult({
    required this.total,
    required this.nuevos,
    this.yaExistia = false,
  });
}