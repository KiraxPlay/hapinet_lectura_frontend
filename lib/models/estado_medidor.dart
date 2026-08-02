// lib/models/estado_medidor.dart
import 'package:flutter/material.dart';

enum EstadoMedidor {
  danado,
  empanado,
  conFuga,
  sinContador,
  accesoDenegado;

  // Clave que se guarda en la BD
  String get clave => switch (this) {
        EstadoMedidor.danado => 'danado',
        EstadoMedidor.empanado => 'empanado',
        EstadoMedidor.conFuga => 'con_fuga',
        EstadoMedidor.sinContador => 'sin_contador',
        EstadoMedidor.accesoDenegado => 'acceso_denegado',
      };

  // Etiqueta visible para el técnico
  String get etiqueta => switch (this) {
        EstadoMedidor.danado => 'Dañado',
        EstadoMedidor.empanado => 'Empañado',
        EstadoMedidor.conFuga => 'Con fuga',
        EstadoMedidor.sinContador => 'Sin contador',
        EstadoMedidor.accesoDenegado => 'Acceso denegado',
      };

  // Ícono representativo
  IconData get icono => switch (this) {
        EstadoMedidor.danado => Icons.build_circle_outlined,
        EstadoMedidor.empanado => Icons.blur_on,
        EstadoMedidor.conFuga => Icons.water_damage_outlined,
        EstadoMedidor.sinContador => Icons.remove_circle_outline,
        EstadoMedidor.accesoDenegado => Icons.lock_outline,
      };

  // Color del marcador en el mapa
  Color get colorMapa => switch (this) {
        EstadoMedidor.danado => Colors.red,
        EstadoMedidor.empanado => const Color(0xFFFDD835),
        EstadoMedidor.conFuga => Colors.blue,
        EstadoMedidor.sinContador => Colors.orange,
        EstadoMedidor.accesoDenegado => const Color(0xFF424242),
      };

  // Color del badge en listas e historial
  Color get colorBadge => switch (this) {
        EstadoMedidor.danado => Colors.red,
        EstadoMedidor.empanado => const Color(0xFFF9A825),
        EstadoMedidor.conFuga => Colors.blue,
        EstadoMedidor.sinContador => Colors.orange,
        EstadoMedidor.accesoDenegado => Colors.grey.shade700,
      };

  // Si true → al seleccionar este estado la lectura se pone en 0
  bool get poneLecturaEnCero => switch (this) {
        EstadoMedidor.empanado => false,
        EstadoMedidor.danado => true,
        EstadoMedidor.conFuga => true,
        EstadoMedidor.sinContador => true,
        EstadoMedidor.accesoDenegado => true,
      };

  // Construir desde la clave guardada en BD
  static EstadoMedidor? desdeClave(String? clave) {
    if (clave == null) return null;
    try {
      return EstadoMedidor.values.firstWhere((e) => e.clave == clave);
    } catch (_) {
      return null;
    }
  }
}