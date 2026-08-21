// lib/models/posicion_result.dart

class PosicionResult {
  final double latitud;
  final double longitud;
  final double? altitud;
  final double precision;
  final double? velocidad;
  final DateTime? timestamp;
  final bool esUltimaConocida;
  final bool esPrecisionReducida;

  const PosicionResult({
    required this.latitud,
    required this.longitud,
    this.altitud, // Altitud puede ser null si el dispositivo no la proporciona
    required this.precision,
    this.velocidad,
    this.timestamp,
    this.esUltimaConocida = false,
    this.esPrecisionReducida = false,
  });

  /// Precisión aceptable = menos de 20 metros
  bool get esPrecisionAceptable => precision <= 20.0;

  String get descripcionPrecision {
    if (precision <= 5) return 'Excelente (${precision.toStringAsFixed(1)} m)';
    if (precision <= 10) return 'Buena (${precision.toStringAsFixed(1)} m)';
    if (precision <= 20) return 'Aceptable (${precision.toStringAsFixed(1)} m)';
    return 'Baja (${precision.toStringAsFixed(1)} m)';
  }

  @override
  String toString() =>
      'PosicionResult(lat: $latitud, lon: $longitud, precisión: ${precision}m)';
}

// ── Errores de geolocalización ──────────────────

enum TipoErrorGeo {
  gpsDesactivado,
  permisoDenegado,
  permisoDenegadoPermanente,
  timeout,
  desconocido,
}

class GeolocalizacionException implements Exception {
  final String mensaje;
  final TipoErrorGeo tipo;

  const GeolocalizacionException(this.mensaje, {required this.tipo});

  @override
  String toString() => mensaje;
}