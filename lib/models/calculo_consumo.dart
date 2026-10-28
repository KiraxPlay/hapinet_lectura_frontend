import 'estado_medidor.dart';

/// Centraliza la lectura provisional y el consumo mostrado durante la captura.
///
/// [lecturaAnterior] es el último valor del medidor antes del período actual.
/// [consumoAnterior] es el consumo histórico del último período que se consulta
/// en el API y se conserva en SQLite para poder trabajar sin conexión.
class CalculoConsumo {
  // Estos estados no tienen una lectura confiable del medidor en el momento
  // de la visita, así que la lectura provisional se estima con el consumo pasado.
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
    // Sin consumo mantiene la lectura anterior; su consumo calculado será 0.
    if (estado == EstadoMedidor.sinConsumo) return lecturaAnterior;

    if (_estadosConConsumoAnterior.contains(estado)) {
      if (lecturaAnterior == null || consumoAnterior == null) return null;
      // Ejemplo para "Dañado": lecturaAnterior 1200 + consumoAnterior 18
      // produce lectura provisional 1218.
      return lecturaAnterior + consumoAnterior;
    }

    // Estados como "No se tomó lectura" representan una lectura igual a cero.
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
      // Si hay una lectura actual (real o provisional), el consumo es la
      // diferencia con la lectura anterior; si falta, se muestra el histórico.
      if (lecturaActual != null) return lecturaActual - lecturaAnterior;
      return consumoAnterior;
    }
    if (estado == EstadoMedidor.lecturaRealizada) {
      if (lecturaActual == null) return null;
      // Para una lectura normal se resta la lectura previa a la captura.
      return lecturaActual - lecturaAnterior;
    }
    return null;
  }
}
