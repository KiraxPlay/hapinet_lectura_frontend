// lib/components/funciones/fila.dart
import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar una fila de label + valor en detalles.
/// Uso con valor texto:
///   Fila(label: 'Fecha', valor: '01/01/2025')
/// Uso con widget personalizado:
///   Fila(label: 'Lectura', child: TextField(...))
class Fila extends StatelessWidget {
  final String label;
  final String? valor;
  final Widget? child;

  const Fila(
    this.label, {
    super.key,
    this.valor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          child ?? Text(valor ?? '', style: const TextStyle(fontSize: 15)),
          const Divider(),
        ],
      ),
    );
  }
}