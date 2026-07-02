// lib/services/mapa_service.dart
import '../data/database.dart';
import '../models/punto_mapa.dart';
import '../services/abonados_service.dart';

class MapaService {
  final AppDatabase _db;
  final AbonadosService _abonadosService;

  // Recibe el jsonAsset del acueducto activo para cargar los abonados correctos
  MapaService(this._db, {required String jsonAsset})
      : _abonadosService = AbonadosService(jsonAsset: jsonAsset);

  Future<List<PuntoMapa>> cargarPuntos() async {
    final abonados = await _abonadosService.cargarTodos();
    final lecturas = await _db.obtenerTodasLecturas();

    final lecturasMap = {
      for (final l in lecturas)
        if (l.codigoMedidor != null) l.codigoMedidor!: l
    };

    final puntos = <PuntoMapa>[];

    // Abonados del JSON con coordenadas
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

    // Lecturas de la BD con coordenadas GPS registradas al momento de leer
    // Esto permite ver en el mapa los medidores de Aguaviva que
    // no tienen coords en el JSON pero sí las tomó el técnico con GPS
    for (final lectura in lecturas) {
      if (lectura.latitud == 0 || lectura.codigoMedidor == null) continue;
      final yaEsta = puntos.any((p) => p.codigo == lectura.codigoMedidor);
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

  /// Calcula el centro geográfico de los puntos de un sector
  /// Si no hay puntos con coords, retorna null
  static ({double lat, double lon})? centroDelSector(
      List<PuntoMapa> puntos, String sector) {
    final validos = puntos
        .where((p) =>
            p.sector == sector && p.latitud != 0 && p.longitud != 0)
        .toList();
    if (validos.isEmpty) return null;
    final lat =
        validos.map((p) => p.latitud).reduce((a, b) => a + b) /
            validos.length;
    final lon =
        validos.map((p) => p.longitud).reduce((a, b) => a + b) /
            validos.length;
    return (lat: lat, lon: lon);
  }

  static ({double lat, double lon}) centroDePoints(
      List<PuntoMapa> puntos) {
    final validos = puntos
        .where((p) => p.latitud != 0 && p.longitud != 0)
        .toList();
    if (validos.isEmpty) {
      return (lat: 2.3845, lon: -75.5429); // fallback Gigante, Huila
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