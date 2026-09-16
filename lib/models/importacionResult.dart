class ImportacionResult {
  final int total;
  final int nuevos;
  final bool yaExistia;

  const ImportacionResult({
    required this.total,
    required this.nuevos,
    this.yaExistia = false,
  });
}