// lib/models/foto_result.dart

import 'dart:io';

class FotoResult {
  final String rutaLocal;
  final int tamanoBytes;
  final DateTime timestamp;

  const FotoResult({
    required this.rutaLocal,
    required this.tamanoBytes,
    required this.timestamp,
  });

  double get tamanoMB => tamanoBytes / (1024 * 1024);
  File get archivo => File(rutaLocal);
}

// ── Errores de cámara ───────────────────────────

enum TipoErrorCamara {
  permisoDenegado,
  sinCamara,
  errorInicializacion,
  noInicializada,
  errorCaptura,
}

class CamaraException implements Exception {
  final String mensaje;
  final TipoErrorCamara tipo;

  const CamaraException(this.mensaje, {required this.tipo});

  @override
  String toString() => mensaje;
}
