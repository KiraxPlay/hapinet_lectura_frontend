// lib/components/captura/selector_estado_medidor.dart
import 'package:flutter/material.dart';
import '../../models/estado_medidor.dart';

class SelectorEstadoMedidor extends StatelessWidget {
  final String? estadoSeleccionado;

  // Retorna clave del estado Y si debe poner lectura en 0
  final void Function(String? clave, bool poneLecturaEnCero) onCambio;

  const SelectorEstadoMedidor({
    super.key,
    required this.estadoSeleccionado,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Problema con el medidor (opcional)',
          style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Si hay algún problema selecciónalo — la lectura se pondrá en 0',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EstadoMedidor.values.map((estado) {
            final seleccionado = estadoSeleccionado == estado.clave;
            return GestureDetector(
              onTap: () {
                if (seleccionado) {
                  onCambio(null, false);
                } else {
                  onCambio(estado.clave, estado.poneLecturaEnCero);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: seleccionado
                      ? estado.colorBadge
                      : estado.colorBadge.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: seleccionado
                        ? estado.colorBadge
                        : estado.colorBadge.withOpacity(0.35),
                    width: seleccionado ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      estado.icono,
                      size: 14,
                      color: seleccionado ? Colors.white : estado.colorBadge,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      estado.etiqueta,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: seleccionado ? Colors.white : estado.colorBadge,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}