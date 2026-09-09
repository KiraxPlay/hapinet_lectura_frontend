// lib/services/mapa_service.dart
// Usa la BD local — no llama al API directamente
import '../data/database.dart';
import '../models/punto_mapa.dart';

class MapaService {
  final AppDatabase _db;

  MapaService(this._db);

  /// Carga puntos del mapa desde la BD local
  /// No depende del API — funciona offline
  Future<List<PuntoMapa>> cargarPuntos() async {
    try {
      final lecturas = await _db.obtenerTodasLecturas();
      final puntos = <PuntoMapa>[];

      for (final l in lecturas) {
        if (l.codigoMedidor == null) continue;
        puntos.add(PuntoMapa(
          codigo: l.codigoMedidor!,
          nombre: l.nombreAbonado ?? l.codigoMedidor!,
          sector: l.sector ?? 'Sin sector',
          latitud: l.latitud,
          longitud: l.longitud,
          lecturaActual: l.lectura,
          fechaLectura: l.fechaLectura,
          estadoSync: l.estadoSync,
          tieneLecturaReal: l.tieneLecturaReal,
          estadoMedidorClave: l.estadoMedidor,
        ));
      }

      return puntos;
    } catch (_) {
      return [];
    }
  }

  static ({double lat, double lon}) centroDePoints(List<PuntoMapa> puntos) {
    final validos = puntos
        .where((p) => p.latitud != 0 && p.longitud != 0)
        .toList();

    if (validos.isEmpty) return (lat: 2.3845, lon: -75.5429);

    final lat = validos.map((p) => p.latitud).reduce((a, b) => a + b) /
        validos.length;
    final lon = validos.map((p) => p.longitud).reduce((a, b) => a + b) /
        validos.length;
    return (lat: lat, lon: lon);
  }
}