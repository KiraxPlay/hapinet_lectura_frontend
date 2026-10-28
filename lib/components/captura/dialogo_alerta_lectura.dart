// lib/components/captura/dialogo_alerta_lectura.dart
import 'package:flutter/material.dart';
import '../../models/alerta_lectura.dart';

/// Confirma una lectura menor que la anterior.
/// Retorna true para usar la fórmula de medidor dañado, false para corregir.
Future<bool?> confirmarLecturaInferior({
  required BuildContext context,
  required int lecturaActual,
  required int lecturaAnterior,
}) {
  final consumo = lecturaActual - lecturaAnterior;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (ctx) => AlertDialog(
          title: const Text('¿Esta lectura está correcta?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'La lectura es menor que la anterior. Verifica el número '
                'ingresado antes de continuar.',
              ),
              const SizedBox(height: 12),
              _fila('Lectura anterior', '$lecturaAnterior'),
              _fila('Lectura ingresada', '$lecturaActual'),
              _fila('Diferencia', '$consumo m³'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Corregir lectura'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Usar fórmula de medidor dañado'),
            ),
          ],
        ),
  );
}

/// Muestra el diálogo de alerta y retorna la opción elegida por el técnico
/// Retorna null si el técnico cancela
Future<OpcionFacturacion?> mostrarDialogoAlerta({
  required BuildContext context,
  required AlertaLectura alerta,
  required int lecturaActual,
  required int? lecturaAnterior,
}) {
  final consumo =
      lecturaAnterior != null ? lecturaActual - lecturaAnterior : lecturaActual;

  return showDialog<OpcionFacturacion>(
    context: context,
    barrierDismissible: false,
    builder:
        (ctx) => AlertDialog(
          title: Row(
            children: [
              Text(alerta.icono, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alerta.titulo,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Valores detectados
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _fila('Lectura anterior', '${lecturaAnterior ?? '-'}'),
                    _fila('Lectura actual', '$lecturaActual'),
                    _fila('Consumo', '$consumo m³'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Descripción
              Text(
                alerta.descripcion,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 14),
              const Text(
                '¿Cómo desea facturar?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              // Opciones de facturación
              ...alerta.opciones.map(
                (op) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.pop(ctx, op),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                        color: Colors.blue.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            op.etiqueta,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            op.descripcion,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Corregir lectura'),
            ),
          ],
        ),
  );
}

Widget _fila(String label, String valor) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 2),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      Text(
        valor,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ],
  ),
);
