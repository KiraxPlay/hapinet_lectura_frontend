// lib/services/mapa_service.dart
// Usa la BD local — no llama al API directamente
import 'dart:developer' as developer;

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
        final predioMatch = RegExp(r'predio_(\d+)').firstMatch(l.id);
        final predioId =
            predioMatch == null ? null : int.tryParse(predioMatch.group(1)!);
        final capturaLocalPendiente =
            l.tieneLecturaReal && l.estadoSync != 'sincronizado';
        final tieneLecturaActual =
            capturaLocalPendiente ||
            l.lecturaActualServidor != null ||
            l.tieneLecturaReal;
        puntos.add(
          PuntoMapa(
            codigo: l.codigoMedidor!,
            predioId: predioId,
            nombre: l.nombreAbonado ?? l.codigoMedidor!,
            sector: l.sector ?? 'Sin sector',
            latitud: l.latitud,
            longitud: l.longitud,
            lecturaActual:
                capturaLocalPendiente
                    ? l.lectura
                    : l.lecturaActualServidor ?? l.lectura,
            fechaLectura: l.fechaLectura,
            estadoSync:
                !capturaLocalPendiente && l.lecturaActualServidor != null
                    ? 'sincronizado'
                    : l.estadoSync,
            tieneLecturaReal: tieneLecturaActual,
            estadoMedidorClave:
                capturaLocalPendiente && l.estadoMedidor != null
                    ? l.estadoMedidor
                    : l.estadoMedidorServidor ?? l.estadoMedidor,
          ),
        );
      }

      developer.log(
        'Puntos cargados=${puntos.length}, '
        'conEstado=${puntos.where((p) => p.estadoMedidorClave != null).length}.',
        name: 'mapa.estados',
      );
      return puntos;
    } catch (_) {
      return [];
    }
  }

  static ({double lat, double lon}) centroDePoints(List<PuntoMapa> puntos) {
    final validos =
        puntos.where((p) => p.latitud != 0 && p.longitud != 0).toList();

    if (validos.isEmpty) return (lat: 2.3845, lon: -75.5429);

    final lat =
        validos.map((p) => p.latitud).reduce((a, b) => a + b) / validos.length;
    final lon =
        validos.map((p) => p.longitud).reduce((a, b) => a + b) / validos.length;
    return (lat: lat, lon: lon);
  }
}
