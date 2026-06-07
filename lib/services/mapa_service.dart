// lib/services/mapa_service.dart
import '../data/database.dart';
import '../models/punto_mapa.dart';
import '../services/abonados_service.dart';

class MapaService {
  final AppDatabase _db;
  final AbonadosService _abonadosService;

  MapaService(this._db) : _abonadosService = AbonadosService();

  /// Combina abonados del JSON con lecturas reales de la BD
  Future<List<PuntoMapa>> cargarPuntos() async {
    // 1. Abonados del JSON con coordenadas
    final abonados = await _abonadosService.cargarTodos();

    // 2. Lecturas reales de la BD
    final lecturas = await _db.obtenerTodasLecturas();

    // 3. Mapa rápido código → lectura
    final lecturasMap = {
      for (final l in lecturas)
        if (l.codigoMedidor != null) l.codigoMedidor!: l
    };

    final puntos = <PuntoMapa>[];

    // 4. Combinar abonados con su lectura si existe
    for (final abonado in abonados) {
      if (!abonado.tieneCoordenadas) continue;
      final lectura = lecturasMap[abonado.codigo];
      puntos.add(PuntoMapa(
        codigo: abonado.codigo,
        nombre: abonado.nombre,
        sector: abonado.sector,
        latitud: abonado.latitud!,
        longitud: abonado.longitud!,
        lecturaActual: lectura?.lectura ?? abonado.lecturaActual,
        fechaLectura: lectura?.fechaLectura,
        estadoSync: lectura?.estadoSync,
        tieneLecturaReal: lectura?.tieneLecturaReal ?? false,
        estadoMedidorClave: lectura?.estadoMedidor,
      ));
    }

    // 5. Lecturas de la BD que no están en el JSON
    for (final lectura in lecturas) {
      if (lectura.latitud == 0 || lectura.codigoMedidor == null) continue;
      final yaEsta =
          puntos.any((p) => p.codigo == lectura.codigoMedidor);
      if (!yaEsta) {
        puntos.add(PuntoMapa(
          codigo: lectura.codigoMedidor!,
          nombre: lectura.nombreAbonado ??
              lectura.notas ??
              lectura.codigoMedidor!,
          sector: lectura.sector ?? 'OTRO',
          latitud: lectura.latitud,
          longitud: lectura.longitud,
          lecturaActual: lectura.lectura,
          fechaLectura: lectura.fechaLectura,
          estadoSync: lectura.estadoSync,
          tieneLecturaReal: lectura.tieneLecturaReal,
          estadoMedidorClave: lectura.estadoMedidor,
        ));
      }
    }

    return puntos;
  }

  /// Calcula el centro geográfico de un conjunto de puntos
  /// Solo usa puntos con coordenadas válidas (lat/lon != 0)
  static ({double lat, double lon}) centroDePoints(
      List<PuntoMapa> puntos) {
    final validos = puntos
        .where((p) => p.latitud != 0 && p.longitud != 0)
        .toList();

    if (validos.isEmpty) {
      // Fallback — centro de todos sin filtrar
      final lat =
          puntos.map((p) => p.latitud).reduce((a, b) => a + b) /
              puntos.length;
      final lon =
          puntos.map((p) => p.longitud).reduce((a, b) => a + b) /
              puntos.length;
      return (lat: lat, lon: lon);
    }

    final lat =
        validos.map((p) => p.latitud).reduce((a, b) => a + b) /
            validos.length;
    final lon =
        validos.map((p) => p.longitud).reduce((a, b) => a + b) /
            validos.length;
    return (lat: lat, lon: lon);
  }
}