import 'package:flutter/material.dart';
import '../../models/estado_medidor.dart';

class TarjetaConsumo extends StatelessWidget {
  final int? consumo;
  final int? consumoAnterior;
  final int? lecturaAnterior;
  final bool tieneLecturaAnterior;
  final String? estadoMedidorAnterior;

  const TarjetaConsumo({
    super.key,
    required this.consumo,
    required this.consumoAnterior,
    required this.lecturaAnterior,
    required this.tieneLecturaAnterior,
    required this.estadoMedidorAnterior,
  });

  @override
  Widget build(BuildContext context) {
    final detalleConsumo = switch (consumo) {
      final valor? => '$valor m³',
      _ when !tieneLecturaAnterior => 'No disponible: falta lectura anterior',
      _ => '0 m³',
    };
    final estado = EstadoMedidor.desdeClave(estadoMedidorAnterior);
    final colorEstado = estado?.colorBadge ?? Colors.grey;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _PanelDato(
                titulo: 'CONSUMO ACTUAL',
                valor: detalleConsumo,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PanelDato(
                titulo: 'ESTADO ANTERIOR',
                valor: estado?.etiqueta ?? 'No reportado',
                color: colorEstado,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PanelDato(
                titulo: 'CONSUMO ANTERIOR',
                valor:
                    consumoAnterior == null
                        ? 'No disponible'
                        : '$consumoAnterior m³',
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PanelDato(
                titulo: 'LECTURA ANTERIOR',
                valor:
                    lecturaAnterior == null
                        ? 'No disponible'
                        : '$lecturaAnterior m³',
                color: Colors.tealAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PanelDato extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;

  const _PanelDato({
    required this.titulo,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titulo,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            valor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
