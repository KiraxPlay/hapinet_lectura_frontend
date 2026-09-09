// lib/services/abonados_service.dart
import '../models/abonado.dart';
import '../models/acueducto.dart';
import 'api/api_service.dart';

class AbonadosService {
  // Recibe el acueducto para conectarse al API
  final Acueducto acueducto;
  final ApiService _api;

  AbonadosService({required this.acueducto})
      : _api = ApiService(acueducto);

  // Cache en memoria — solo se descarga del API una vez por sesion
  static final Map<String, List<Abonado>> _cache = {};

  // Limpia el cache de un acueducto específico
  static void limpiarCache(String acueductoId) => _cache.remove(acueductoId);

  // Limpia todo el cache
  static void limpiarTodo() => _cache.clear();

  static String _sectorDesdePredio(Map<String, dynamic> predio, String codigo) {
    final veredaId = int.tryParse(predio['vereda_id']?.toString() ?? '');
    switch (veredaId) {
      case 54:
        return 'TENDIDO';
      case 55:
        return 'RECREO';
      case 56:
        return 'PUEBLO NUEVO';
    }

    final sectorApi = predio['sector_abrev']?.toString().trim().toUpperCase();
    if (sectorApi != null && sectorApi.isNotEmpty) {
      return switch (sectorApi) {
        'TEN' || 'TENDIDO' => 'TENDIDO',
        'REC' || 'RECREO' => 'RECREO',
        'PUE' || 'PUEBLO NUEVO' => 'PUEBLO NUEVO',
        _ => sectorApi,
      };
    }

    final prefijo = codigo.trim().toUpperCase().split(RegExp(r'[-_ ]')).first;
    return switch (prefijo) {
      'TEN' || 'TENDIDO' => 'TENDIDO',
      'REC' || 'RECREO' => 'RECREO',
      'PUE' || 'PUEBLO' => 'PUEBLO NUEVO',
      _ => 'OTRO',
    };
  }

  /// Carga todos los abonados desde el API
  /// Los datos se cachean en memoria para evitar descargas repetidas
  Future<List<Abonado>> cargarTodos() async {
    final cacheKey = acueducto.tipo.name;
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey]!;

    // Descargar predios del API
    final predios = await _api.listPredios();

    final lista = <Abonado>[];
    for (final p in predios.cast<Map<String, dynamic>>()) {
      final codigo = p['predio_codigo'] as String;
      final nombre =
          '${p['abonado_nombre']} ${p['abonado_apellido'] ?? ''}'.trim();
      final sector = _sectorDesdePredio(p, codigo);
      final celular = p['abonado_celular'] as String?;
      final lecturaActual = p['predio_lectura_actual'] as int?;
      final latitud = (p['predio_latitud'] as num?)?.toDouble();
      final longitud = (p['predio_longitud'] as num?)?.toDouble();

      lista.add(Abonado(
        codigo: codigo,
        nombre: nombre,
        sector: sector,
        celular: celular,
        lecturaActual: lecturaActual,
        latitud: latitud,
        longitud: longitud,
      ));
    }

    _cache[cacheKey] = lista;
    return lista;
  }

  /// Obtiene abonados filtrados por sector
  Future<List<Abonado>> porSector(String sector) async {
    final todos = await cargarTodos();
    return todos.where((a) => a.sector == sector).toList();
  }

  /// Busca abonados por nombre o código
  Future<List<Abonado>> buscar(String query) async {
    final todos = await cargarTodos();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return todos;
    return todos
        .where((a) =>
            a.nombre.toLowerCase().contains(q) ||
            a.codigo.toLowerCase().contains(q))
        .toList();
  }

  /// Retorna el total de abonados por sector
  Future<Map<String, int>> totalesPorSector() async {
    final todos = await cargarTodos();
    final mapa = <String, int>{};
    for (final a in todos) {
      mapa[a.sector] = (mapa[a.sector] ?? 0) + 1;
    }
    return mapa;
  }
}