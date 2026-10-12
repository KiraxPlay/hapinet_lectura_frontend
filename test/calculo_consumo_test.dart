import 'package:flutter_test/flutter_test.dart';
import 'package:medidor_hapinet_app/models/calculo_consumo.dart';
import 'package:medidor_hapinet_app/models/estado_medidor.dart';

void main() {
  group('CalculoConsumo', () {
    test('calcula lectura provisional y consumo para un medidor dañado', () {
      const lecturaAnterior = 1200;
      const consumoAnterior = 18;

      final lecturaProvisional = CalculoConsumo.lecturaParaEstado(
        estado: EstadoMedidor.danado,
        lecturaAnterior: lecturaAnterior,
        consumoAnterior: consumoAnterior,
      );
      final consumo = CalculoConsumo.calcular(
        estado: EstadoMedidor.danado,
        lecturaAnterior: lecturaAnterior,
        lecturaActual: lecturaProvisional,
        consumoAnterior: consumoAnterior,
      );

      expect(lecturaProvisional, 1218);
      expect(consumo, lecturaProvisional! - lecturaAnterior);
    });

    test('aplica la misma fórmula provisional al estado reversa', () {
      expect(
        CalculoConsumo.lecturaParaEstado(
          estado: EstadoMedidor.reversa,
          lecturaAnterior: 1200,
          consumoAnterior: 18,
        ),
        1218,
      );
    });

    test('sin consumo conserva la lectura anterior y calcula cero', () {
      expect(
        CalculoConsumo.lecturaParaEstado(
          estado: EstadoMedidor.sinConsumo,
          lecturaAnterior: 1200,
          consumoAnterior: 18,
        ),
        1200,
      );
      expect(
        CalculoConsumo.calcular(
          estado: EstadoMedidor.sinConsumo,
          lecturaAnterior: 1200,
          lecturaActual: 1200,
          consumoAnterior: 18,
        ),
        0,
      );
    });

    test('lectura realizada calcula lectura actual menos anterior', () {
      expect(
        CalculoConsumo.calcular(
          estado: EstadoMedidor.lecturaRealizada,
          lecturaAnterior: 1200,
          lecturaActual: 1225,
          consumoAnterior: 18,
        ),
        25,
      );
    });
  });
}
