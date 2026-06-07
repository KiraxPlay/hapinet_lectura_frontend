// lib/components/captura/tarjeta_ocr.dart
import 'package:flutter/material.dart';
import '../../models/ocr_result.dart';

class TarjetaOcr extends StatelessWidget {
  final OcrResult? ocrResult;

  const TarjetaOcr({super.key, required this.ocrResult});

  @override
  Widget build(BuildContext context) {
    if (ocrResult == null) return const SizedBox.shrink();

    final color = ocrResult!.esExitoso
        ? (ocrResult!.requiereRevision ? Colors.orange : Colors.green)
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ocrResult!.esExitoso ? Icons.check_circle : Icons.warning,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'OCR Offline — Confianza: ${ocrResult!.descripcionConfianza}',
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
            ],
          ),
          if (ocrResult!.advertencia != null) ...[
            const SizedBox(height: 4),
            Text(ocrResult!.advertencia!,
                style: TextStyle(color: color, fontSize: 12)),
          ],
          if (!ocrResult!.esExitoso && ocrResult!.mensajeError != null) ...[
            const SizedBox(height: 4),
            Text(ocrResult!.mensajeError!,
                style:
                    const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            const Text(
              'Ingresa el número manualmente en el campo de abajo.',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}