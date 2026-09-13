// lib/services/importar_abonados_service.dart
import 'dart:async';
import 'package:drift/drift.dart' show Value, InsertMode;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import '../services/api/api_service.dart';

class ImportarAbonadosService {
  final AppDatabase _db;
  final Acueducto acueducto;

  String get _keyImportado =>
      'abonados_importados_${acueducto.tipo.name}_v10';

  ImportarAbonadosService({
    required AppDatabase db,
    required this.acueducto,
  }) : _db = db;

  Future<ImportacionResult> importar() async {
    final prefs = await SharedPreferences.getInstance();

    // Ya importado → retorno instantáneo
    if (prefs.getBool(_keyImportado) == true) {
      return const ImportacionResult(total: 0, nuevos: 0, yaExistia: true);
    }

    // Intentar API con timeout de 10 segundos
    try {
      final api = ApiService(acueducto);
      print('🔄 Intentando descargar predios desde ${acueducto.apiUrl}');
      final t = DateTime.now();

      // Descargar predios y novedades en paralelo
      final results = await Future.wait([
        api.listPredios(),
        api.novedadesMasivas(),
      ]).timeout(const Duration(seconds: 30));

      final predios   = results[0];
      final novedades = results[1];
      print('✓ Predios: ${predios.length}, Novedades: ${novedades.length} en ${DateTime.now().difference(t).inMilliseconds}ms');

      if (predios.isNotEmpty) {
        final companions = predios.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value as Map<String, dynamic>;
          final id = 'predio_${p['predio_id']}';
          final nombre =
              '${p['abonado_nombre'] ?? ''} ${p['abonado_apellido'] ?? ''}'
                  .trim();
          return LecturasCompanion.insert(
            id: id,
            lectura: 0,
            textoCrudo: '',
            rutaFoto: '',
            latitud: _parseDouble(p['predio_latitud']) ?? 0.0,
            longitud: _parseDouble(p['predio_longitud']) ?? 0.0,
            fechaLectura: DateTime.now(),
            estadoSync: const Value('pendiente'),
            codigoMedidor: Value(p['predio_codigo'] as String? ?? id),
            nombreAbonado: Value(nombre),
            celular: Value(p['abonado_telefono'] as String?),
            sector: Value(_sectorDesdeVereda(p['vereda_id'])),
            esAbonado: const Value(true),
            tieneLecturaReal: const Value(false),
            ordenRuta: Value(i + 1),
            lecturaAnterior: Value((p['predio_lectura_anterior'] as num?)?.toInt()),
          );
        }).toList();

        await _db.insertarAbonadosEnBatch(companions);

        // Agrupar novedades por predio_id y guardar en BD local
        if (novedades.isNotEmpty) {
          final novedadesPorPredio = <int, List<Map<String, dynamic>>>{};
          for (final n in novedades) {
            final map = n as Map<String, dynamic>;
            final id  = map['predio_id'] as int;
            novedadesPorPredio.putIfAbsent(id, () => []).add(map);
          }
          for (final entry in novedadesPorPredio.entries) {
            await _db.guardarNovedadesPredio(entry.key, entry.value);
          }
        }

        await prefs.setBool(_keyImportado, true);
        return ImportacionResult(
            total: companions.length, nuevos: companions.length);
      }
    } catch (e) {
      print('✗ Error importando predios: $e');
      // Sin internet, timeout o error — no bloquear el splash
    }

    // Sin datos del API — NO marcar como importado
    // El próximo arranque reintentará la descarga
    return const ImportacionResult(total: 0, nuevos: 0, yaExistia: false);
  }

  String _sectorDesdeVereda(dynamic veredaId) {
    final id = veredaId?.toString();
    return switch (acueducto.tipo) {
      TipoAcueducto.asoaguapo => switch (id) {
          '54' => 'TENDIDO',
          '55' => 'RECREO',
          '56' => 'PUEBLO NUEVO',
          _    => 'Sin sector',
        },
      TipoAcueducto.temporal => switch (id) {
          '54' => 'Alto Corozal',
          '55' => 'Cachaya',
          '56' => 'La Floresta',
          '68' => 'La Palma',
          '69' => 'Los Cafetos',
          _    => 'Sin sector',
        },
    };
  }

  double? _parseDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val);
    return null;
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