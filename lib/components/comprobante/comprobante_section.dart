import 'package:flutter/material.dart';

class ComprobanteFila {
  final String label;
  final String valor;
  final bool negrita;
  final Color? color;

  const ComprobanteFila(
    this.label,
    this.valor, {
    this.negrita = false,
    this.color,
  });
}

class ComprobanteSection extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  final List<ComprobanteFila> filas;

  const ComprobanteSection({
    super.key,
    required this.titulo,
    required this.icono,
    required this.color,
    required this.filas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icono, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...filas.map(
              (fila) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fila.label,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fila.valor,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            fila.negrita ? FontWeight.bold : FontWeight.normal,
                        color: fila.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
