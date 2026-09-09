// lib/models/alerta_lectura.dart
// Tipos de alertas que se detectan al confirmar una lectura

enum TipoAlerta {
  lecturaInferior,      // 🔴 Lectura < anterior
  consumoExcesivo,      // 🔴 Consumo > 1.5× promedio histórico
  consumoBajo,          // 🟠 Consumo < 0.3× promedio histórico
  lecturaRepetida,      // 🟡 Igual a la anterior
  lecturaCero,          // 🟡 Lectura = 0 con consumo normal
}

class AlertaLectura {
  final TipoAlerta tipo;
  final String titulo;
  final String descripcion;
  final String icono;
  // Opciones de facturación sugeridas
  final List<OpcionFacturacion> opciones;

  const AlertaLectura({
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.opciones,
  });
}

class OpcionFacturacion {
  final String etiqueta;
  final String descripcion;
  final int errorId;        // error_id que se envía a Laravel
  final bool usaPromedio;   // si true → calcular promedio histórico

  const OpcionFacturacion({
    required this.etiqueta,
    required this.descripcion,
    required this.errorId,
    this.usaPromedio = false,
  });
}

// Opciones estándar reutilizables
const _opcionConsumoReal = OpcionFacturacion(
  etiqueta: 'Usar lectura real',
  descripcion: 'Facturar con el consumo registrado',
  errorId: 64, // Consumo
);

const _opcionPromedio = OpcionFacturacion(
  etiqueta: 'Usar promedio histórico',
  descripcion: 'Facturar con el promedio de períodos anteriores',
  errorId: 65, // Promedio
  usaPromedio: true,
);

const _opcionSoloBasico = OpcionFacturacion(
  etiqueta: 'Solo cargo básico',
  descripcion: 'Facturar únicamente el cargo básico sin consumo',
  errorId: 66, // Solo básico
);

// ─────────────────────────────────────────────
// DETECTOR DE ALERTAS
// ─────────────────────────────────────────────

class DetectorAlertas {
  /// Detecta alertas dado:
  /// - [lecturaActual] lectura que el técnico ingresó
  /// - [lecturaAnterior] última lectura registrada
  /// - [promedioHistorico] promedio de m³ de períodos anteriores (puede ser null)
  static AlertaLectura? detectar({
    required int lecturaActual,
    required int? lecturaAnterior,
    double? promedioHistorico,
  }) {
    if (lecturaAnterior == null) return null;

    final consumo = lecturaActual - lecturaAnterior;

    // 🔴 Lectura menor a la anterior
    if (consumo < 0) {
      return const AlertaLectura(
        tipo: TipoAlerta.lecturaInferior,
        titulo: 'Lectura menor a la anterior',
        descripcion: 'La lectura ingresada es inferior a la última registrada. '
            'Esto puede indicar un error de digitación o un medidor nuevo.',
        icono: '🔴',
        opciones: [
          _opcionPromedio,
          _opcionSoloBasico,
        ],
      );
    }

    // 🟡 Lectura = 0
    if (lecturaActual == 0) {
      return const AlertaLectura(
        tipo: TipoAlerta.lecturaCero,
        titulo: 'Lectura en cero',
        descripcion: 'Se registró 0. Puede ser casa cerrada, '
            'medidor detenido o error de lectura.',
        icono: '🟡',
        opciones: [
          _opcionPromedio,
          _opcionSoloBasico,
          _opcionConsumoReal,
        ],
      );
    }

    // 🟡 Lectura repetida
    if (consumo == 0) {
      return const AlertaLectura(
        tipo: TipoAlerta.lecturaRepetida,
        titulo: 'Lectura igual a la anterior',
        descripcion: 'El medidor no registró consumo. '
            'Posible medidor detenido o sin uso.',
        icono: '🟡',
        opciones: [
          _opcionPromedio,
          _opcionSoloBasico,
          _opcionConsumoReal,
        ],
      );
    }

    // Alertas basadas en promedio histórico
    if (promedioHistorico != null && promedioHistorico > 0) {
      // 🔴 Consumo excesivo
      if (consumo > promedioHistorico * 1.5) {
        return AlertaLectura(
          tipo: TipoAlerta.consumoExcesivo,
          titulo: 'Consumo excesivamente alto',
          descripcion: 'El consumo de $consumo m³ supera considerablemente '
              'el promedio histórico de ${promedioHistorico.toStringAsFixed(0)} m³. '
              'Verifique la lectura.',
          icono: '🔴',
          opciones: const [
            _opcionConsumoReal,
            _opcionPromedio,
          ],
        );
      }

      // 🟠 Consumo inusualmente bajo
      if (consumo < promedioHistorico * 0.3) {
        return AlertaLectura(
          tipo: TipoAlerta.consumoBajo,
          titulo: 'Consumo inusualmente bajo',
          descripcion: 'El consumo de $consumo m³ es muy inferior '
              'al promedio histórico de ${promedioHistorico.toStringAsFixed(0)} m³.',
          icono: '🟠',
          opciones: const [
            _opcionConsumoReal,
            _opcionPromedio,
          ],
        );
      }
    }

    return null; // Sin alerta
  }
}