import 'estado_medidor.dart';

class CalculoConsumo {
  static const _estadosConConsumoAnterior = {
    EstadoMedidor.danado,
    EstadoMedidor.noLegible,
    EstadoMedidor.reversa,
    EstadoMedidor.sinMedidor,
  };

  static int? lecturaParaEstado({
    required EstadoMedidor estado,
    required int? lecturaAnterior,
    required int? consumoAnterior,
  }) {
    if (estado == EstadoMedidor.sinConsumo) return lecturaAnterior;

    if (_estadosConConsumoAnterior.contains(estado)) {
      if (lecturaAnterior == null || consumoAnterior == null) return null;
      return lecturaAnterior + consumoAnterior;
    }

    if (estado.poneLecturaEnCero) return 0;
    return null;
  }

  static int? calcular({
    required EstadoMedidor estado,
    required int? lecturaAnterior,
    required int? lecturaActual,
    required int? consumoAnterior,
  }) {
    if (lecturaAnterior == null) return null;
    if (estado == EstadoMedidor.sinConsumo) return 0;
    if (_estadosConConsumoAnterior.contains(estado)) {
      if (lecturaActual != null) return lecturaActual - lecturaAnterior;
      return consumoAnterior;
    }
    if (estado == EstadoMedidor.lecturaRealizada) {
      if (lecturaActual == null) return null;
      return lecturaActual - lecturaAnterior;
    }
    return null;
  }
}
