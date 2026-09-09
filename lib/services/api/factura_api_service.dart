// lib/services/api/factura_api_service.dart
// Genera facturas en sitio después de sincronizar la lectura
// POST /api/generarFactura
// GET  /api/detalleFactura/{factura_id}
// GET  /api/deudaAbonado/{predio_id}
import 'api_client.dart';

class FacturaApiService {
  final _client = ApiClient.instancia;

  // ─────────────────────────────────────────────
  // GENERAR FACTURA
  // Requiere que la lectura ya esté sincronizada
  // POST /api/generarFactura
  // Body: { predio_id }
  // Response: { consumo, detalle: { cargo_basico, valor_consumo,
  //             novedades, total }, factura }
  // ─────────────────────────────────────────────

  Future<FacturaResult> generarFactura({required int predioId}) async {
    final response = await _client.post(
      '/generarFactura',
      body: {'predio_id': predioId},
    );

    if (response.sinConexion) {
      return FacturaResult.error(
          'Sin conexión — necesitas internet para generar la factura');
    }

    // 409 — ya tiene factura este período o no hay período activo
    if (response.statusCode == 409) {
      final msg = response.data?['message'] ?? 'Conflicto con la factura';
      return FacturaResult.error(msg);
    }

    // 422 — no hay lectura registrada en el servidor
    if (response.statusCode == 422) {
      return FacturaResult.error(
          'El predio no tiene lectura registrada en el servidor.\n'
          'Sincroniza primero la lectura.');
    }

    if (!response.exitoso) {
      return FacturaResult.error(
          'Error del servidor (${response.statusCode})');
    }

    final data = response.data as Map<String, dynamic>;
    final detalle = data['detalle'] as Map<String, dynamic>;
    final factura = data['factura'] as Map<String, dynamic>;

    return FacturaResult.exito(
      facturaId: factura['factura_id'] as int,
      facturaNumero: factura['factura_numero'] as int,
      consumo: data['consumo'] as int,
      cargoBasico: detalle['cargo_basico'] as int,
      valorConsumo: detalle['valor_consumo'] as int,
      novedades: detalle['novedades'] as int,
      total: detalle['total'] as int,
    );
  }

  // ─────────────────────────────────────────────
  // DETALLE DE FACTURA
  // GET /api/detalleFactura/{factura_id}
  // ─────────────────────────────────────────────

  Future<DetalleFacturaResult> detalleFactura(int facturaId) async {
    final response = await _client.get('/detalleFactura/$facturaId');

    if (!response.exitoso) {
      return DetalleFacturaResult.error('No se pudo obtener el detalle');
    }

    return DetalleFacturaResult.exito(
        data: response.data as Map<String, dynamic>);
  }

  // ─────────────────────────────────────────────
  // DEUDA DEL ABONADO
  // GET /api/deudaAbonado/{predio_id}
  // ─────────────────────────────────────────────

  Future<DeudaResult> deudaAbonado(int predioId) async {
    final response = await _client.get('/deudaAbonado/$predioId');

    if (!response.exitoso) {
      return DeudaResult.error('No se pudo obtener la deuda');
    }

    final data = response.data as Map<String, dynamic>;
    return DeudaResult.exito(
      totalDeuda: (data['total_deuda'] as num).toInt(),
      cantidadFacturas: data['cantidad_facturas'] as int,
    );
  }
}

// ─────────────────────────────────────────────
// MODELOS DE RESULTADO
// ─────────────────────────────────────────────

class FacturaResult {
  final bool exitoso;
  final String? error;
  final int? facturaId;
  final int? facturaNumero;
  final int? consumo;
  final int? cargoBasico;
  final int? valorConsumo;
  final int? novedades;
  final int? total;

  const FacturaResult._({
    required this.exitoso,
    this.error,
    this.facturaId,
    this.facturaNumero,
    this.consumo,
    this.cargoBasico,
    this.valorConsumo,
    this.novedades,
    this.total,
  });

  factory FacturaResult.exito({
    required int facturaId,
    required int facturaNumero,
    required int consumo,
    required int cargoBasico,
    required int valorConsumo,
    required int novedades,
    required int total,
  }) =>
      FacturaResult._(
        exitoso: true,
        facturaId: facturaId,
        facturaNumero: facturaNumero,
        consumo: consumo,
        cargoBasico: cargoBasico,
        valorConsumo: valorConsumo,
        novedades: novedades,
        total: total,
      );

  factory FacturaResult.error(String msg) =>
      FacturaResult._(exitoso: false, error: msg);

  // Formatea el total en pesos colombianos
  String get totalFormateado {
    if (total == null) return '\$0';
    return '\$${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}

class DetalleFacturaResult {
  final bool exitoso;
  final String? error;
  final Map<String, dynamic>? data;

  const DetalleFacturaResult._({required this.exitoso, this.error, this.data});

  factory DetalleFacturaResult.exito({required Map<String, dynamic> data}) =>
      DetalleFacturaResult._(exitoso: true, data: data);

  factory DetalleFacturaResult.error(String msg) =>
      DetalleFacturaResult._(exitoso: false, error: msg);
}

class DeudaResult {
  final bool exitoso;
  final String? error;
  final int? totalDeuda;
  final int? cantidadFacturas;

  const DeudaResult._({
    required this.exitoso,
    this.error,
    this.totalDeuda,
    this.cantidadFacturas,
  });

  factory DeudaResult.exito(
          {required int totalDeuda, required int cantidadFacturas}) =>
      DeudaResult._(
          exitoso: true,
          totalDeuda: totalDeuda,
          cantidadFacturas: cantidadFacturas);

  factory DeudaResult.error(String msg) =>
      DeudaResult._(exitoso: false, error: msg);
}