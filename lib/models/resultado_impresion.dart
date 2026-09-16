class ResultadoImpresion {
  final bool exitoso;
  final String? error;

  const ResultadoImpresion._({required this.exitoso, this.error});

  factory ResultadoImpresion.exito() =>
      const ResultadoImpresion._(exitoso: true);

  factory ResultadoImpresion.error(String msg) =>
      ResultadoImpresion._(exitoso: false, error: msg);
}
