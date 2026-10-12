// lib/components/captura/selector_estado_medidor.dart
import 'package:flutter/material.dart';
import '../../models/estado_medidor.dart';

class SelectorEstadoMedidor extends StatelessWidget {
  final String? estadoSeleccionado;

  final ValueChanged<String> onCambio;

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
          'Estado de la lectura (obligatorio)',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          estadoSeleccionado == EstadoMedidor.lecturaRealizada.clave
              ? 'Se asigna “Lectura realizada” automáticamente.'
              : 'Selecciona el estado correspondiente al medidor.',
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              EstadoMedidor.values
                  .where((estado) => estado != EstadoMedidor.lecturaRealizada)
                  .map((estado) {
                    final seleccionado = estadoSeleccionado == estado.clave;
                    return GestureDetector(
                      onTap: () {
                        if (!seleccionado) onCambio(estado.clave);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              seleccionado
                                  ? estado.colorBadge
                                  : estado.colorBadge.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                seleccionado
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
                              color:
                                  seleccionado
                                      ? Colors.white
                                      : estado.colorBadge,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              estado.etiqueta,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    seleccionado
                                        ? Colors.white
                                        : estado.colorBadge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                  .toList(),
        ),
        if (estadoSeleccionado != EstadoMedidor.lecturaRealizada.clave)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => onCambio(EstadoMedidor.lecturaRealizada.clave),
              child: const Text('Restablecer a Lectura realizada'),
            ),
          ),
      ],
    );
  }
}
