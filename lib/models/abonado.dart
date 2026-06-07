// lib/models/abonado.dart

class Abonado {
  final String codigo;
  final String nombre;
  final String sector; // TENDIDO, RECREO, PUEBLO NUEVO
  final String? celular;
  final int? lecturaActual;
  final double? latitud;
  final double? longitud;

  const Abonado({
    required this.codigo,
    required this.nombre,
    required this.sector,
    this.celular,
    this.lecturaActual,
    this.latitud,
    this.longitud,
  });

  factory Abonado.fromJson(Map<String, dynamic> json, String sector) {
    return Abonado(
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      sector: sector,
      celular: json['celular'] as String?,
      lecturaActual: json['lectura_actual'] as int?,
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
    );
  }

  bool get tieneCoordenadas => latitud != null && longitud != null;

  static const coloresSector = {
    'TENDIDO': 0xFF1976D2,
    'RECREO': 0xFF388E3C,
    'PUEBLO NUEVO': 0xFF7B1FA2,
  };

  int get colorSector => coloresSector[sector] ?? 0xFF607D8B;
  String get inicialSector => sector[0];
}