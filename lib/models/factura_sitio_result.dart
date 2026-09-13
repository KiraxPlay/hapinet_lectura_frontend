// Resultado de la facturacion realizada en sitio.
class FacturaSitioResult {
  final bool exitoso;
  final String? error;
  final String? rutaPdf;
  final bool esOficial;
  final int? facturaNumero;
  final int total;
  final String? aviso;
  final int cargoBasico;
  final int valorConsumo;
  final int novedades;
  final int? consumoEstimado;
  final int? consumo;

  const FacturaSitioResult._({
    required this.exitoso,
    this.error,
    this.rutaPdf,
    this.esOficial = false,
    this.facturaNumero,
    this.total = 0,
    this.aviso,
    this.cargoBasico = 0,
    this.valorConsumo = 0,
    this.novedades = 0,
    this.consumoEstimado,
    this.consumo,
  });

  factory FacturaSitioResult.exito({
    required String rutaPdf,
    required bool esOficial,
    required int total,
    int? facturaNumero,
    String? aviso,
    int cargoBasico = 0,
    int valorConsumo = 0,
    int novedades = 0,
    int? consumoEstimado,
    int? consumo,
  }) => FacturaSitioResult._(
    exitoso: true,
    rutaPdf: rutaPdf,
    esOficial: esOficial,
    facturaNumero: facturaNumero,
    total: total,
    aviso: aviso,
    cargoBasico: cargoBasico,
    valorConsumo: valorConsumo,
    novedades: novedades,
    consumoEstimado: consumoEstimado,
    consumo: consumo,
  );

  factory FacturaSitioResult.error(String msg) =>
      FacturaSitioResult._(exitoso: false, error: msg);

  int get cargoBasicoMostrar => cargoBasico;
  int get valorConsumoMostrar => valorConsumo;
  int get novedadesMostrar => novedades;

  String get totalFormateado =>
      '\$${total.toString().replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]}.${m[2]}')}';
}
