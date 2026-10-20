import 'dart:convert';
import 'dart:developer' as developer;

class FacturaPendiente {
  final int? numero;
  final int total;
  final List<DetalleFacturaPendiente> detalles;

  const FacturaPendiente({
    required this.numero,
    required this.total,
    required this.detalles,
  });

  factory FacturaPendiente.fromJson(Map<String, dynamic> json) {
    final rawDetalles = json['detalles'];
    final detalles = <DetalleFacturaPendiente>[];
    if (rawDetalles is List) {
      for (final item in rawDetalles) {
        final map = _mapear(item);
        if (map != null) detalles.add(DetalleFacturaPendiente.fromJson(map));
      }
    }

    return FacturaPendiente(
      numero: _entero(json['factura_numero']),
      total: _entero(json['factura_total']) ?? 0,
      detalles: detalles,
    );
  }

  static List<FacturaPendiente> desdeDatosPredioJson(String? json) {
    if (json == null || json.isEmpty) return const [];

    dynamic decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException catch (error, stackTrace) {
      developer.log(
        'No se pudieron leer las facturas pendientes guardadas del predio.',
        name: 'FacturaPendiente',
        error: error,
        stackTrace: stackTrace,
      );
      return const [];
    }

    final predio = _mapear(decoded);
    final rawFacturas = predio?['facturasPendientes'];
    if (rawFacturas is! List) return const [];

    return [
      for (final item in rawFacturas)
        if (_mapear(item) case final factura?)
          FacturaPendiente.fromJson(factura),
    ];
  }
}

class DetalleFacturaPendiente {
  final String concepto;
  final String cantidad;
  final int valor;

  const DetalleFacturaPendiente({
    required this.concepto,
    required this.cantidad,
    required this.valor,
  });

  factory DetalleFacturaPendiente.fromJson(Map<String, dynamic> json) {
    final conceptoJson = _mapear(json['concepto']);
    return DetalleFacturaPendiente(
      concepto:
          conceptoJson?['concepto_descripcion']?.toString() ??
          'Concepto pendiente',
      cantidad: json['detalle_cantidad']?.toString() ?? '',
      valor: _entero(json['detalle_liquidacion']) ?? 0,
    );
  }
}

Map<String, dynamic>? _mapear(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

int? _entero(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
