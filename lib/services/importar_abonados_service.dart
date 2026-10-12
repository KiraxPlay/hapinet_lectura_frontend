// lib/services/importar_abonados_service.dart
import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import '../models/importacionResult.dart';
import '../services/api/api_service.dart';

class ImportarAbonadosService {
  final AppDatabase _db;
  final Acueducto acueducto;

  String get _keyImportado => 'abonados_importados_${acueducto.tipo.name}_v12';

  static List<Map<String, dynamic>> normalizarNovedades(
    List<dynamic> novedades, {
    int? predioId,
  }) {
    final normalizadas = <Map<String, dynamic>>[];

    for (final item in novedades) {
      if (item is! Map) continue;

      final map = Map<String, dynamic>.from(item);
      final predioIdItem =
          _parseInt(
            map['predio_id'] ?? map['predioId'] ?? map['novedad_predio_id'],
          ) ??
          predioId;
      if (predioIdItem == null) continue;

      final concepto =
          (map['concepto'] ?? map['concepto_descripcion'] ?? 'Sin concepto')
              .toString();

      final valorCuota =
          _parseInt(map['valor_cuota'] ?? map['valorCuota']) ??
          _calcularValorCuota(
            _parseNum(
              map['novedad_valor'] ?? map['valor_total'] ?? map['valor'],
            ),
            _parseNum(
              map['novedad_cuotas'] ?? map['cuotas_totales'] ?? map['cuotas'],
            ),
          );

      final cuotasTotales = _parseInt(
        map['novedad_cuotas'] ?? map['cuotas_totales'] ?? map['cuotas'],
      );
      final cuotasLiquidadas =
          _parseInt(map['novedad_liquidadas'] ?? map['liquidadas'] ?? 0) ?? 0;
      final cuotasPendientes =
          _parseInt(map['cuotas_pendientes'] ?? map['cuotasPendientes']) ??
          (cuotasTotales != null
              ? (cuotasTotales - cuotasLiquidadas).clamp(0, cuotasTotales)
              : 0);

      final totalPendiente =
          _parseInt(map['total_pendiente'] ?? map['totalPendiente']) ??
          (valorCuota * cuotasPendientes).toInt();

      normalizadas.add({
        'predio_id': predioIdItem,
        'concepto': concepto,
        'valor_cuota': valorCuota,
        'cuotas_pendientes': cuotasPendientes,
        'total_pendiente': totalPendiente,
      });
    }

    return normalizadas;
  }

  static int _calcularValorCuota(num? total, num? cuotasTotales) {
    if (total == null || total <= 0) return 0;
    final divisor =
        cuotasTotales != null && cuotasTotales > 0 ? cuotasTotales.toInt() : 1;
    return (total / divisor).round();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static num? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  ImportarAbonadosService({required AppDatabase db, required this.acueducto})
    : _db = db;

  /// Descarga y guarda las novedades de un predio para consulta offline.
  Future<void> actualizarNovedadesPredio(int predioId) async {
    final api = ApiService(acueducto);
    final novedades = await api
        .novedadesPredio(predioId)
        .timeout(const Duration(seconds: 30));
    final normalizadas = normalizarNovedades(novedades, predioId: predioId);
    await _db.guardarNovedadesPredio(predioId, normalizadas);
  }

  Future<ImportacionResult> importar({bool forzar = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Ya importado → retorno instantáneo
    if (!forzar && prefs.getBool(_keyImportado) == true) {
      return const ImportacionResult(total: 0, nuevos: 0, yaExistia: true);
    }

    // Intentar API con timeout de 10 segundos
    try {
      final api = ApiService(acueducto);
      developer.log(
        'Intentando descargar predios desde ${acueducto.apiUrl}',
        name: 'ImportarAbonadosService',
      );
      final t = DateTime.now();

      final predios = await api.listPredios().timeout(
        const Duration(seconds: 30),
      );
      List<dynamic> novedades = [];
      try {
        novedades = await api.novedadesMasivas().timeout(
          const Duration(seconds: 30),
        );
      } catch (e) {
        developer.log(
          'No se pudieron descargar novedades; se continuará con predios',
          name: 'ImportarAbonadosService',
          error: e,
        );
      }

      final novedadesNormalizadas = normalizarNovedades(novedades);
      developer.log(
        'Predios: ${predios.length}, Novedades: ${novedadesNormalizadas.length} '
        'en ${DateTime.now().difference(t).inMilliseconds}ms',
        name: 'ImportarAbonadosService',
      );

      var totalImportados = 0;
      if (predios.isNotEmpty) {
        final companions =
            predios.asMap().entries.map((entry) {
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
                codigoMedidor: Value(p['predio_contador']?.toString()),
                predioCodigo: Value(p['predio_codigo']?.toString()),
                nombreAbonado: Value(nombre),
                celular: Value(p['abonado_telefono'] as String?),
                sector: Value(_sectorDesdeVereda(p['vereda_id'])),
                esAbonado: const Value(true),
                tieneLecturaReal: const Value(false),
                ordenRuta: Value(i + 1),
                lecturaAnterior: Value(
                  (p['predio_lectura_anterior'] as num?)?.toInt(),
                ),
              );
            }).toList();

        await _db.insertarAbonadosEnBatch(companions);
        totalImportados = companions.length;
      }

      if (novedadesNormalizadas.isNotEmpty) {
        final novedadesPorPredio = <int, List<Map<String, dynamic>>>{};
        for (final n in novedadesNormalizadas) {
          final predioId = n['predio_id'] as int;
          novedadesPorPredio.putIfAbsent(predioId, () => []).add(n);
        }
        for (final entry in novedadesPorPredio.entries) {
          await _db.guardarNovedadesPredio(entry.key, entry.value);
        }
      }

      if (predios.isNotEmpty || novedadesNormalizadas.isNotEmpty) {
        await prefs.setBool(_keyImportado, true);
        return ImportacionResult(
          total: totalImportados,
          nuevos: totalImportados,
        );
      }
    } catch (e) {
      developer.log(
        'Error importando predios',
        name: 'ImportarAbonadosService',
        error: e,
      );
      // Sin internet, timeout o error — no bloquear el splash
      return ImportacionResult(
        total: 0,
        nuevos: 0,
        yaExistia: false,
        error: 'No se pudo descargar el período: $e',
      );
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
        _ => 'Sin sector',
      },
      TipoAcueducto.temporal => switch (id) {
        '54' => 'Alto Corozal',
        '55' => 'Cachaya',
        '56' => 'La Floresta',
        '68' => 'La Palma',
        '69' => 'Los Cafetos',
        _ => 'Sin sector',
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
