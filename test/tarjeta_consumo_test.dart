import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medidor_hapinet_app/components/captura/tarjeta_consumo.dart';

void main() {
  testWidgets('muestra los cuatro datos de consumo y lectura', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TarjetaConsumo(
            consumo: 25,
            consumoAnterior: 18,
            lecturaAnterior: 1200,
            tieneLecturaAnterior: true,
            estadoMedidorAnterior: 'danado',
          ),
        ),
      ),
    );

    expect(find.text('CONSUMO ACTUAL'), findsOneWidget);
    expect(find.text('25 m³'), findsOneWidget);
    expect(find.text('ESTADO ANTERIOR'), findsOneWidget);
    expect(find.text('Dañado'), findsOneWidget);
    expect(find.text('CONSUMO ANTERIOR'), findsOneWidget);
    expect(find.text('18 m³'), findsOneWidget);
    expect(find.text('LECTURA ANTERIOR'), findsOneWidget);
    expect(find.text('1200 m³'), findsOneWidget);
  });

  testWidgets('indica cuando la lectura anterior no está disponible', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TarjetaConsumo(
            consumo: null,
            consumoAnterior: null,
            lecturaAnterior: null,
            tieneLecturaAnterior: false,
            estadoMedidorAnterior: null,
          ),
        ),
      ),
    );

    expect(find.text('No disponible: falta lectura anterior'), findsOneWidget);
    expect(find.text('No disponible'), findsNWidgets(2));
  });
}
