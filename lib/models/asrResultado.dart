class AsrResultado {
  final String texto;
  final bool esFinal;
  final double nivelVolumen;

  const AsrResultado({
    required this.texto,
    required this.esFinal,
    this.nivelVolumen = 0.0,
  });
}