// lib/models/estado_medidor.dart
import 'package:flutter/material.dart';

enum EstadoMedidor {
  lecturaRealizada,
  noSeTomoLectura,
  danado,
  noLegible,
  reversa,
  sinConsumo,
  sinMedidor,
  soloPunto,
  suspendido,
  predioInactivo;

  String get clave => switch (this) {
    EstadoMedidor.lecturaRealizada => 'lectura_realizada',
    EstadoMedidor.noSeTomoLectura => 'no_se_tomo_lectura',
    EstadoMedidor.danado => 'danado',
    EstadoMedidor.noLegible => 'no_legible',
    EstadoMedidor.reversa => 'reversa',
    EstadoMedidor.sinConsumo => 'sin_consumo',
    EstadoMedidor.sinMedidor => 'sin_medidor',
    EstadoMedidor.soloPunto => 'solo_punto',
    EstadoMedidor.suspendido => 'suspendido',
    EstadoMedidor.predioInactivo => 'predio_inactivo',
  };

  String get etiqueta => switch (this) {
    EstadoMedidor.lecturaRealizada => 'Lectura realizada',
    EstadoMedidor.noSeTomoLectura => 'No se tomó lectura',
    EstadoMedidor.danado => 'Dañado',
    EstadoMedidor.noLegible => 'No legible',
    EstadoMedidor.reversa => 'Reversa',
    EstadoMedidor.sinConsumo => 'Sin consumo',
    EstadoMedidor.sinMedidor => 'Sin medidor',
    EstadoMedidor.soloPunto => 'Solo punto',
    EstadoMedidor.suspendido => 'Suspendido',
    EstadoMedidor.predioInactivo => 'Predio inactivo',
  };

  String get nombreParametro => switch (this) {
    EstadoMedidor.lecturaRealizada => 'Lectura realizada',
    EstadoMedidor.noSeTomoLectura => 'No se tomó lectura',
    EstadoMedidor.danado => 'Dañado',
    EstadoMedidor.noLegible => 'No legible',
    EstadoMedidor.reversa => 'Reversa',
    EstadoMedidor.sinConsumo => 'Sin consumo',
    EstadoMedidor.sinMedidor => 'Sin medidor',
    EstadoMedidor.soloPunto => 'Solo punto',
    EstadoMedidor.suspendido => 'Suspendido',
    EstadoMedidor.predioInactivo => 'Predio Inactivo',
  };

  int? get parametroId => switch (this) {
    EstadoMedidor.lecturaRealizada => 21,
    EstadoMedidor.noSeTomoLectura => 22,
    EstadoMedidor.danado => 23,
    EstadoMedidor.noLegible => 24,
    EstadoMedidor.reversa => null,
    EstadoMedidor.sinConsumo => 58,
    EstadoMedidor.sinMedidor => 61,
    EstadoMedidor.soloPunto => 68,
    EstadoMedidor.suspendido => 69,
    EstadoMedidor.predioInactivo => 70,
  };

  IconData get icono => switch (this) {
    EstadoMedidor.lecturaRealizada => Icons.water_drop_outlined,
    EstadoMedidor.noSeTomoLectura => Icons.visibility_off_outlined,
    EstadoMedidor.danado => Icons.build_circle_outlined,
    EstadoMedidor.noLegible => Icons.blur_on,
    EstadoMedidor.reversa => Icons.swap_vert_circle_outlined,
    EstadoMedidor.sinConsumo => Icons.water_drop_outlined,
    EstadoMedidor.sinMedidor => Icons.remove_circle_outline,
    EstadoMedidor.soloPunto => Icons.location_on_outlined,
    EstadoMedidor.suspendido => Icons.pause_circle_outline,
    EstadoMedidor.predioInactivo => Icons.domain_disabled_outlined,
  };

  Color get colorMapa => switch (this) {
    EstadoMedidor.lecturaRealizada => Colors.green,
    EstadoMedidor.noSeTomoLectura => Colors.grey,
    EstadoMedidor.danado => Colors.red,
    EstadoMedidor.noLegible => Colors.amber.shade800,
    EstadoMedidor.reversa => Colors.deepPurple,
    EstadoMedidor.sinConsumo => Colors.blue,
    EstadoMedidor.sinMedidor => Colors.deepOrange,
    EstadoMedidor.soloPunto => Colors.purple,
    EstadoMedidor.suspendido => Colors.brown,
    EstadoMedidor.predioInactivo => Colors.blueGrey,
  };

  Color get colorBadge => switch (this) {
    EstadoMedidor.lecturaRealizada => Colors.green,
    EstadoMedidor.noSeTomoLectura => Colors.grey.shade700,
    EstadoMedidor.danado => Colors.red,
    EstadoMedidor.noLegible => Colors.amber.shade800,
    EstadoMedidor.reversa => Colors.deepPurple,
    EstadoMedidor.sinConsumo => Colors.blue,
    EstadoMedidor.sinMedidor => Colors.deepOrange,
    EstadoMedidor.soloPunto => Colors.purple,
    EstadoMedidor.suspendido => Colors.brown,
    EstadoMedidor.predioInactivo => Colors.blueGrey,
  };

  bool get poneLecturaEnCero => switch (this) {
    EstadoMedidor.lecturaRealizada => false,
    EstadoMedidor.sinConsumo => false,
    EstadoMedidor.noSeTomoLectura => true,
    EstadoMedidor.danado => false,
    EstadoMedidor.noLegible => false,
    EstadoMedidor.reversa => false,
    EstadoMedidor.sinMedidor => false,
    EstadoMedidor.soloPunto => true,
    EstadoMedidor.suspendido => true,
    EstadoMedidor.predioInactivo => true,
  };

  bool get requiereConfirmacionCambio => switch (this) {
    EstadoMedidor.danado ||
    EstadoMedidor.noLegible ||
    EstadoMedidor.reversa ||
    EstadoMedidor.predioInactivo => true,
    _ => false,
  };

  static EstadoMedidor? desdeClave(String? clave) {
    if (clave == null) return null;
    final claveActual = switch (clave) {
      'empanado' => 'no_legible',
      'con_fuga' || 'acceso_denegado' => 'no_se_tomo_lectura',
      'sin_contador' => 'sin_medidor',
      _ => clave,
    };
    for (final estado in EstadoMedidor.values) {
      if (estado.clave == claveActual) return estado;
    }
    return null;
  }

  static EstadoMedidor? desdeNombreParametro(String? nombre) {
    if (nombre == null) return null;
    final normalizado = switch (_normalizarParametro(nombre)) {
      'lecturareversa' => 'reversa',
      _ => _normalizarParametro(nombre),
    };

    for (final estado in EstadoMedidor.values) {
      final nombreNormalizado = _normalizarParametro(estado.nombreParametro);
      if (nombreNormalizado == normalizado) return estado;
    }
    return null;
  }

  static EstadoMedidor? desdeParametroId(int? parametroId) {
    if (parametroId == null) return null;
    for (final estado in EstadoMedidor.values) {
      if (estado.parametroId == parametroId) return estado;
    }
    return null;
  }

  static String _normalizarParametro(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');
}
