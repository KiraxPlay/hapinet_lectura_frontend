// lib/models/ocr_result.dart

enum EstadoOcr { exitoso, sinTexto, sinNumeros, conAdvertencia, error }

class OcrResult {
  final EstadoOcr estado;
  final int? lectura;
  final String textoCrudo;
  final double confianza;
  final String? advertencia;
  final String? mensajeError;
  final List<CandidatoNumerico> candidatos;

  const OcrResult._({
    required this.estado,
    this.lectura,
    this.textoCrudo = '',
    this.confianza = 0.0,
    this.advertencia,
    this.mensajeError,
    this.candidatos = const [],
  });

  factory OcrResult.exitoso({
    required int lectura,
    required String textoCrudo,
    required double confianza,
    List<CandidatoNumerico> todosCandidatos = const [],
  }) =>
      OcrResult._(
        estado: EstadoOcr.exitoso,
        lectura: lectura,
        textoCrudo: textoCrudo,
        confianza: confianza,
        candidatos: todosCandidatos,
      );

  factory OcrResult.conAdvertencia({
    required int lectura,
    required String textoCrudo,
    required String advertencia,
  }) =>
      OcrResult._(
        estado: EstadoOcr.conAdvertencia,
        lectura: lectura,
        textoCrudo: textoCrudo,
        confianza: 0.4,
        advertencia: advertencia,
      );

  factory OcrResult.sinTexto() => const OcrResult._(
        estado: EstadoOcr.sinTexto,
        mensajeError: 'No se detectó texto en la imagen.',
      );

  factory OcrResult.sinNumeros(String textoCrudo) => OcrResult._(
        estado: EstadoOcr.sinNumeros,
        textoCrudo: textoCrudo,
        mensajeError: 'Se detectó texto pero no números de medidor válidos.',
      );

  factory OcrResult.error(String mensaje) => OcrResult._(
        estado: EstadoOcr.error,
        mensajeError: mensaje,
      );

  bool get esExitoso =>
      estado == EstadoOcr.exitoso || estado == EstadoOcr.conAdvertencia;

  bool get requiereRevision =>
      estado == EstadoOcr.conAdvertencia || confianza < 0.7;

  String get descripcionConfianza {
    if (confianza >= 0.9) return 'Alta';
    if (confianza >= 0.7) return 'Media';
    return 'Baja — verifica manualmente';
  }
}

class CandidatoNumerico {
  final int valor;
  final String texto;
  final int longitudDigitos;
  final double confianza;

  const CandidatoNumerico({
    required this.valor,
    required this.texto,
    required this.longitudDigitos,
    required this.confianza,
  });
}
