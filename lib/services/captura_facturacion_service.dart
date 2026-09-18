import 'package:http/http.dart' as http;
import '../data/database.dart';
import '../models/acueducto.dart';
import '../models/factura_sitio_result.dart';
import 'api/api_service.dart';
import 'api/factura_api_service.dart';
import 'api/tarifas_service.dart';

class ResultadoFacturacionCaptura {
  final Lectura lectura;
  final FacturaSitioResult resultado;

  const ResultadoFacturacionCaptura({
    required this.lectura,
    required this.resultado,
  });
}

class CapturaFacturacionService {
  final FacturaApiService _facturaApi;

  CapturaFacturacionService({FacturaApiService? facturaApi})
    : _facturaApi = facturaApi ?? FacturaApiService();

  Future<ResultadoFacturacionCaptura?> facturar({
    required AppDatabase db,
    required Acueducto acueducto,
    required String codigoMedidor,
    required int predioId,
  }) async {
    final lectura = await db.obtenerLecturaPorCodigo(codigoMedidor);
    if (lectura == null) return null;

    if (await _tieneInternet(acueducto.apiUrl)) {
      try {
        await ApiService(acueducto).sincronizarLecturasPendientes(db);
        final factura = await _facturaApi.generarFactura(predioId: predioId);
        if (factura.exitoso) {
          return ResultadoFacturacionCaptura(
            lectura: lectura,
            resultado: FacturaSitioResult.exito(
              rutaPdf: '',
              esOficial: true,
              facturaNumero: factura.facturaNumero,
              total: factura.total ?? 0,
              cargoBasico: factura.cargoBasico ?? 0,
              valorConsumo: factura.valorConsumo ?? 0,
              novedades: factura.novedades ?? 0,
              consumo: factura.consumo,
            ),
          );
        }
      } catch (_) {
        // Si el servidor falla, continuar con el cálculo local.
      }
    }

    return ResultadoFacturacionCaptura(
      lectura: lectura,
      resultado: await _calcularOffline(lectura, acueducto),
    );
  }

  Future<FacturaSitioResult> _calcularOffline(
    Lectura lectura,
    Acueducto acueducto,
  ) async {
    final tarifas = TarifasService(acueducto: acueducto);
    final calculo = await tarifas.calcularOffline(
      lecturaActual: lectura.lectura,
      lecturaAnterior: lectura.lecturaAnterior ?? 0,
    );
    return FacturaSitioResult.exito(
      rutaPdf: '',
      esOficial: false,
      total: calculo.total,
      cargoBasico: calculo.cargoBasico,
      valorConsumo: calculo.valorConsumo,
      consumoEstimado: calculo.consumo,
      aviso: 'Comprobante estimado — sin novedades.',
    );
  }

  Future<bool> _tieneInternet(String apiUrl) async {
    try {
      final respuesta = await http
          .head(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 4));
      return respuesta.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}