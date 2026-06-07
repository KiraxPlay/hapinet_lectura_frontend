// lib/components/funciones/color_sector.dart
import 'package:flutter/material.dart';

/// Retorna el color asociado al sector
Color colorDeSector(String? sector) {
  return switch (sector) {
    'TENDIDO' => const Color(0xFF1976D2),
    'RECREO' => const Color(0xFF388E3C),
    'PUEBLO NUEVO' => const Color(0xFF7B1FA2),
    _ => const Color(0xFF607D8B),
  };
}

/// Retorna la inicial del sector para avatares
String inicialDeSector(String? sector) => (sector ?? 'O')[0];

/// Retorna el nombre legible del sector
String nombreDeSector(String? sector) {
  return switch (sector) {
    'TENDIDO' => 'El Tendido',
    'RECREO' => 'El Recreo',
    'PUEBLO NUEVO' => 'Pueblo Nuevo',
    _ => 'Sin sector',
  };
}