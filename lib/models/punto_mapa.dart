// lib/models/punto_mapa.dart
import 'package:flutter/material.dart';
import 'estado_medidor.dart';

typedef EstadoServidorPredio = ({EstadoMedidor estado, int lecturaActual});

class PuntoMapa {
  final String codigo;
  final int? predioId;
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
    this.predioId,
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

  PuntoMapa copyWith({
    int? predioId,
    int? lecturaActual,
    DateTime? fechaLectura,
    String? estadoSync,
    bool? tieneLecturaReal,
    String? estadoMedidorClave,
  }) {
    return PuntoMapa(
      codigo: codigo,
      predioId: predioId ?? this.predioId,
      nombre: nombre,
      sector: sector,
      latitud: latitud,
      longitud: longitud,
      lecturaActual: lecturaActual ?? this.lecturaActual,
      fechaLectura: fechaLectura ?? this.fechaLectura,
      estadoSync: estadoSync ?? this.estadoSync,
      tieneLecturaReal: tieneLecturaReal ?? this.tieneLecturaReal,
      estadoMedidorClave: estadoMedidorClave ?? this.estadoMedidorClave,
    );
  }

  /// Color del marcador en el mapa según estado del medidor o sync
  Color get color {
    // Si tiene estado de medidor reportado → ese color tiene prioridad
    final estado = estadoMedidor;
    if (estado != null) return estado.colorMapa;

    // Sin lectura aún → gris
    if (!tieneLecturaReal) return Colors.grey.shade400;

    // Lectura tomada sin estado especial → verde/naranja según sync
    return switch (estadoSync) {
      'sincronizado' => Colors.green,
      _ => Colors.orange,
    };
  }

  static const coloresSector = {
    // ASOAGUAPO
    'TENDIDO': Color(0xFF1976D2), // Azul
    'RECREO': Color(0xFF388E3C), // Verde
    'PUEBLO NUEVO': Color(0xFF7B1FA2), // Morado
    // AGUAVIVA
    'La Palma': Color(0xFF00838F), // Cian oscuro
    'Cachaya': Color(0xFFE65100), // Naranja
    'Alto Corozal': Color(0xFF558B2F), // Verde oliva
    'Los Cafetos': Color(0xFF6A1B9A), // Violeta
    'La Floresta': Color(0xFFC62828), // Rojo
  };

  Color get colorSector => coloresSector[sector] ?? const Color(0xFF607D8B);
}
