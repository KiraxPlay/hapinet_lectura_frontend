import 'package:medidor_hapinet_app/services/exportar_pdf.dart';

import '../data/database.dart';
import '../models/acueducto.dart';
import 'api/api_service.dart';
import 'api/factura_api_service.dart';

class ComprobanteService {
  final FacturaApiService _facturaApi;

  ComprobanteService({FacturaApiService? facturaApi})
    : _facturaApi = facturaApi ?? FacturaApiService();

  Future<DeudaResult> cargarDeuda(int predioId) {
    return _facturaApi.deudaAbonado(predioId);
  }

  Future<List<Map<String, dynamic>>> cargarNovedades({
    required int predioId,
    required Acueducto acueducto,
    required AppDatabase db,
  }) async {
    try {
      final api = ApiService(acueducto);
      final lista = await api
          .novedadesPredio(predioId)
          .timeout(const Duration(seconds: 8));
      final novedades = lista.cast<Map<String, dynamic>>();
      await db.guardarNovedadesPredio(predioId, novedades);
      return novedades;
    } catch (_) {
      return db.obtenerNovedadesPredio(predioId);
    }
  }

  Future<String> generarPdf({
    required AppDatabase db,
    required Acueducto acueducto,
    required Lectura lectura,
    required FacturaSitioResult resultado,
    required List<Map<String, dynamic>> novedades,
  }) {
    final pdfService = ExportarPdfService(db, acueducto: acueducto);
    return pdfService.exportarFacturaAbonado(
      lectura,
      novedades: novedades,
      resultado: resultado,
    );
  }
}
