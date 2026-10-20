import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:medidor_hapinet_app/models/factura_pendiente.dart';

void main() {
  test(
    'lee facturas pendientes y sus conceptos desde los datos del predio',
    () {
      final facturas = FacturaPendiente.desdeDatosPredioJson(
        jsonEncode({
          'facturasPendientes': [
            {
              'factura_numero': 23,
              'factura_total': 12500,
              'detalles': [
                {
                  'detalle_cantidad': '2 cuotas',
                  'detalle_liquidacion': 12500,
                  'concepto': {'concepto_descripcion': 'Mantenimiento'},
                },
              ],
            },
          ],
        }),
      );

      expect(facturas, hasLength(1));
      expect(facturas.single.numero, 23);
      expect(facturas.single.total, 12500);
      expect(facturas.single.detalles.single.concepto, 'Mantenimiento');
      expect(facturas.single.detalles.single.cantidad, '2 cuotas');
      expect(facturas.single.detalles.single.valor, 12500);
    },
  );
}
