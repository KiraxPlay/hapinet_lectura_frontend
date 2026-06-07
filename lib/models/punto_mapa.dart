// lib/models/punto_mapa.dart
import 'package:flutter/material.dart';
import 'estado_medidor.dart';

class PuntoMapa {
  final String codigo;
  final String nombre;
  final String sector;
  final double latitud;
  final double longitud;
  final int? lecturaActual;
  final DateTime? fechaLectura;
  final String? estadoSync;
  final bool tieneLecturaReal;
  final String? estadoMedidorClave; // clave guardada en BD

  const PuntoMapa({
    required this.codigo,
    required this.nombre,
    required this.sector,
    required this.latitud,
    required this.longitud,
    this.lecturaActual,
    this.fechaLectura,
    this.estadoSync,
    required this.tieneLecturaReal,
    this.estadoMedidorClave,
  });

  /// Estado del medidor parseado
  EstadoMedidor? get estadoMedidor =>
      EstadoMedidor.desdeClave(estadoMedidorClave);

  /// Color del marcador en el mapa según estado del medidor o sync
  Color get color {
    // Si tiene estado de medidor reportado → ese color tiene prioridad
    final estado = estadoMedidor;
    if (estado != null && tieneLecturaReal) return estado.colorMapa;

    // Sin lectura aún → gris
    if (!tieneLecturaReal) return Colors.grey.shade400;

    // Lectura tomada sin estado especial → verde/naranja según sync
    return switch (estadoSync) {
      'sincronizado' => Colors.green,
      _ => Colors.orange,
    };
  }

  static const coloresSector = {
    'TENDIDO': Color(0xFF1976D2),
    'RECREO': Color(0xFF388E3C),
    'PUEBLO NUEVO': Color(0xFF7B1FA2),
  };

  Color get colorSector =>
      coloresSector[sector] ?? const Color(0xFF607D8B);
}