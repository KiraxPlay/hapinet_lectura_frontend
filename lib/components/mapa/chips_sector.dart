// lib/components/mapa/chips_sector.dart
import 'package:flutter/material.dart';
import '../../models/punto_mapa.dart';

class ChipsSector extends StatelessWidget {
  final String? sectorSeleccionado;
  final List<PuntoMapa> puntos;
  final void Function(String? sector) onSectorCambiado;

  static const _sectores = ['TENDIDO', 'RECREO', 'PUEBLO NUEVO'];

  const ChipsSector({
    super.key,
    required this.sectorSeleccionado,
    required this.puntos,
    required this.onSectorCambiado,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chip(null, 'Todos', Colors.blue),
            ..._sectores.map((sector) {
              final color =
                  PuntoMapa.coloresSector[sector] ?? Colors.grey;
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _chip(sector, sector[0], color),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _chip(String? sector, String label, Color color) {
    final seleccionado = sectorSeleccionado == sector;
    final total = sector == null
        ? puntos.length
        : puntos.where((p) => p.sector == sector).length;

    return GestureDetector(
      onTap: () => onSectorCambiado(sector),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: seleccionado ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? color : color.withOpacity(0.3),
            width: seleccionado ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: seleccionado ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: seleccionado
                    ? Colors.white.withOpacity(0.3)
                    : color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$total',
                style: TextStyle(
                  fontSize: 10,
                  color: seleccionado ? Colors.white : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}