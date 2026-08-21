// lib/services/geolocalizacion_service.dart
import 'dart:async';
import 'package:drift/drift.dart' show Value;
import 'package:geolocator/geolocator.dart';
import '../data/database.dart';
import '../models/posicion_result.dart';

class GeolocalizacionService {
  final AppDatabase _db;

  GeolocalizacionService(this._db);

  // ─────────────────────────────────────────────
  // PERMISOS
  // ─────────────────────────────────────────────

  Future<bool> solicitarPermisos() async {
    final servicioHabilitado = await Geolocator.isLocationServiceEnabled();
    if (!servicioHabilitado) {
      throw const GeolocalizacionException(
        'El GPS del dispositivo está desactivado. Actívalo en Configuración > Ubicación.',
        tipo: TipoErrorGeo.gpsDesactivado,
      );
    }

    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw const GeolocalizacionException(
          'Permiso de ubicación denegado.',
          tipo: TipoErrorGeo.permisoDenegado,
        );
      }
    }

    if (permiso == LocationPermission.deniedForever) {
      throw const GeolocalizacionException(
        'Permiso de ubicación denegado permanentemente. Habilítalo en Configuración > Aplicaciones.',
        tipo: TipoErrorGeo.permisoDenegadoPermanente,
      );
    }

    return true;
  }

  // ─────────────────────────────────────────────
  // OBTENER POSICIÓN ACTUAL
  // ─────────────────────────────────────────────

  /// Posición exacta usando el chip GPS — funciona 100% offline
  Future<PosicionResult> obtenerPosicionActual() async {
    await solicitarPermisos();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      final resultado = _fromPosition(position);
      await _guardarEnBD(resultado);
      return resultado;
    } on TimeoutException {
      return await _obtenerPosicionReducida();
    }
  }

  Future<PosicionResult> _obtenerPosicionReducida() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium, // ← medium, no high
    ).timeout(const Duration(seconds: 30));

    final resultado = PosicionResult(
      latitud: position.latitude,
      longitud: position.longitude,
      altitud: position.altitude,
      precision: position.accuracy,
      velocidad: position.speed,
      timestamp: position.timestamp,
      esPrecisionReducida: true,
    );
    await _guardarEnBD(resultado);
    return resultado;
  }
  // ─────────────────────────────────────────────
  // ÚLTIMA POSICIÓN CONOCIDA (instantánea)
  // ─────────────────────────────────────────────

  Future<PosicionResult?> obtenerUltimaPosicion() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      return PosicionResult(
        latitud: position.latitude,
        longitud: position.longitude,
        altitud: position.altitude,
        precision: position.accuracy,
        velocidad: position.speed,
        timestamp: position.timestamp,
        esUltimaConocida: true,
      );
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // STREAM EN TIEMPO REAL
  // ─────────────────────────────────────────────

  Stream<PosicionResult> watchPosicion({int distanciaMinMetros = 5}) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanciaMinMetros,
      ),
    ).map((p) => _fromPosition(p));
  }

  // ─────────────────────────────────────────────
  // PERSISTENCIA LOCAL
  // ─────────────────────────────────────────────

  Future<void> _guardarEnBD(PosicionResult p, {String? lecturaId}) async {
    await _db.guardarPosicionGps(
      RegistrosGpsCompanion.insert(
        latitud: p.latitud,
        longitud: p.longitud,
        altitud: Value(p.altitud),
        precision: p.precision,
        velocidad: Value(p.velocidad),
        timestamp: p.timestamp ?? DateTime.now(),
        lecturaId: Value(lecturaId),
      ),
    );
  }

  Future<void> guardarPosicionParaLectura(
    PosicionResult posicion,
    String lecturaId,
  ) async {
    await _guardarEnBD(posicion, lecturaId: lecturaId);
  }

  Future<List<RegistrosGp>> obtenerHistorialGps({int limite = 50}) =>
      _db.obtenerUltimasPosiciones(limite);

  Future<void> limpiarHistorialAntiguo() => _db.limpiarGpsAntiguo(30);

  // ─────────────────────────────────────────────
  // UTILIDADES
  // ─────────────────────────────────────────────

  double calcularDistancia(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) => Geolocator.distanceBetween(lat1, lon1, lat2, lon2);

  String formatearCoordenadas(double lat, double lon) {
    final latStr =
        lat >= 0
            ? '${lat.toStringAsFixed(6)}° N'
            : '${lat.abs().toStringAsFixed(6)}° S';
    final lonStr =
        lon >= 0
            ? '${lon.toStringAsFixed(6)}° E'
            : '${lon.abs().toStringAsFixed(6)}° O';
    return '$latStr, $lonStr';
  }

  PosicionResult _fromPosition(Position p) => PosicionResult(
    latitud: p.latitude,
    longitud: p.longitude,
    altitud: p.altitude,
    precision: p.accuracy,
    velocidad: p.speed,
    timestamp: p.timestamp,
  );
}
