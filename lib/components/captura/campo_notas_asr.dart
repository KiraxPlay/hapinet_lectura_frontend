// lib/components/captura/campo_notas_asr.dart
import 'package:flutter/material.dart';

class CampoNotasAsr extends StatelessWidget {
  final TextEditingController controller;
  final bool esLecturaCero;
  final bool asrDisponible;
  final bool escuchando;
  final bool transcribiendo;
  final double nivelVolumen;
  final VoidCallback onToggleAsr;
  final VoidCallback onChanged;

  const CampoNotasAsr({
    super.key,
    required this.controller,
    required this.esLecturaCero,
    required this.asrDisponible,
    required this.escuchando,
    required this.transcribiendo,
    required this.nivelVolumen,
    required this.onToggleAsr,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final borde = BorderSide(
      color: esLecturaCero
          ? Colors.orange.withOpacity(0.5)
          : Colors.white24,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: 2,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: esLecturaCero
                ? '⚠ Observación obligatoria: ¿por qué no se pudo leer?'
                : 'Notas del técnico (opcional)',
            hintStyle: TextStyle(
              color: esLecturaCero
                  ? Colors.orange.shade300
                  : Colors.white30,
              fontSize: 12,
            ),
            filled: true,
            fillColor: esLecturaCero
                ? Colors.orange.withOpacity(0.1)
                : Colors.white10,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: borde),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: borde),
            // Micrófono solo cuando no está grabando ni procesando
            suffixIcon: asrDisponible && !escuchando && !transcribiendo
                ? GestureDetector(
                    onTap: onToggleAsr,
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_none,
                          color: Colors.white54, size: 18),
                    ),
                  )
                : null,
          ),
        ),

        // ── Procesando — spinner pequeño ──
        if (transcribiendo) ...[
          const SizedBox(height: 6),
          const Row(children: [
            SizedBox(width: 4),
            SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.orange),
            ),
            SizedBox(width: 8),
            Text('Procesando lo que dijo...',
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontStyle: FontStyle.italic)),
          ]),
        ],

        // ── Grabando — botón GRANDE para personas mayores ──
        if (escuchando) ...[
          const SizedBox(height: 10),
          // Barra de volumen
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: (nivelVolumen / 10).clamp(0.0, 1.0),
                backgroundColor: Colors.red.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Botón DETENER grande y visible
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onToggleAsr,
              icon: const Icon(Icons.stop_circle, size: 24),
              label: const Text(
                'LISTO — Tocar aquí para terminar',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '🎤 Hable con calma. Toque el botón rojo cuando termine.',
            style: TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}