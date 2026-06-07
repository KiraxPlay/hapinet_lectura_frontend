// lib/services/importar_abonados_service.dart
import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database.dart';
import 'abonados_service.dart';

class ImportarAbonadosService {
  final AppDatabase _db;

  // ← Cambia v4 → v5 cada vez que actualices el abonados.json
  static const _keyImportado = 'abonados_importados_v4';

  ImportarAbonadosService(this._db);

  Future<ImportacionResult> importar() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_keyImportado) == true) {
      return const ImportacionResult(total: 0, nuevos: 0, yaExistia: true);
    }

    // Limpiar cache para que lea el JSON fresco
    AbonadosService.limpiarCache();

    final service = AbonadosService();
    final abonados = await service.cargarTodos();

    await _db.transaction(() async {
      for (int i = 0; i < abonados.length; i++) {
        final abonado = abonados[i];
        final id =
            'abonado_${abonado.codigo.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase()}';
        await _db.insertarAbonadoSiNoExiste(
          LecturasCompanion.insert(
            id: id,
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
            // Posicion en el JSON = orden de la ruta del tecnico
            ordenRuta: Value(i + 1),
          ),
        );
      }
    });

    await prefs.setBool(_keyImportado, true);

    return ImportacionResult(total: abonados.length, nuevos: abonados.length);
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