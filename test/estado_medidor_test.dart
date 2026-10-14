import 'package:flutter_test/flutter_test.dart';
import 'package:medidor_hapinet_app/models/estado_medidor.dart';
import 'package:medidor_hapinet_app/models/punto_mapa.dart';

void main() {
  group('EstadoMedidor', () {
    test('resuelve estados por los IDs de parametro del servidor', () {
      final estadosPorId = {
        21: EstadoMedidor.lecturaRealizada,
        22: EstadoMedidor.noSeTomoLectura,
        23: EstadoMedidor.danado,
        24: EstadoMedidor.noLegible,
        58: EstadoMedidor.sinConsumo,
        61: EstadoMedidor.sinMedidor,
        68: EstadoMedidor.soloPunto,
        69: EstadoMedidor.suspendido,
        70: EstadoMedidor.predioInactivo,
      };

      for (final entry in estadosPorId.entries) {
        expect(EstadoMedidor.desdeParametroId(entry.key), entry.value);
      }
      expect(EstadoMedidor.desdeParametroId(999), isNull);
    });

    test('acepta nombres con mayusculas y separadores distintos', () {
      expect(
        EstadoMedidor.desdeNombreParametro('LECTURA_REALIZADA'),
        EstadoMedidor.lecturaRealizada,
      );
      expect(
        EstadoMedidor.desdeNombreParametro('DAÑADO'),
        EstadoMedidor.danado,
      );
      expect(
        EstadoMedidor.desdeNombreParametro('Predio-Inactivo'),
        EstadoMedidor.predioInactivo,
      );
      expect(
        EstadoMedidor.desdeNombreParametro('LECTURA REVERSA'),
        EstadoMedidor.reversa,
      );
    });

    test('pinta estado aunque el punto aun no tenga lectura local', () {
      const punto = PuntoMapa(
        codigo: 'MED-001',
        nombre: 'Abonado',
        sector: 'TENDIDO',
        latitud: 2.3,
        longitud: -75.5,
        tieneLecturaReal: false,
        estadoMedidorClave: 'danado',
      );

      expect(punto.color, EstadoMedidor.danado.colorMapa);
    });

    test('solicita confirmacion solo para estados adversos', () {
      expect(EstadoMedidor.danado.requiereConfirmacionCambio, isTrue);
      expect(EstadoMedidor.noLegible.requiereConfirmacionCambio, isTrue);
      expect(EstadoMedidor.reversa.requiereConfirmacionCambio, isTrue);
      expect(EstadoMedidor.predioInactivo.requiereConfirmacionCambio, isTrue);
      expect(EstadoMedidor.noSeTomoLectura.requiereConfirmacionCambio, isFalse);
      expect(
        EstadoMedidor.lecturaRealizada.requiereConfirmacionCambio,
        isFalse,
      );
    });
  });
}
