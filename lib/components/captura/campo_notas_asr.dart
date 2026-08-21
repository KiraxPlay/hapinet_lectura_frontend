// lib/components/captura/campo_notas_asr.dart
// Campo de observaciones con botón de micrófono ASR integrado
import 'package:flutter/material.dart';

class CampoNotasAsr extends StatelessWidget {
  final TextEditingController controller;
  final bool esLecturaCero;
  final bool asrDisponible;
  final bool escuchando;
  final double nivelVolumen;
  final VoidCallback onToggleAsr;
  final VoidCallback onChanged;

  const CampoNotasAsr({
    super.key,
    required this.controller,
    required this.esLecturaCero,
    required this.asrDisponible,
    required this.escuchando,
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
            // Botón micrófono — solo si ASR está disponible
            suffixIcon: asrDisponible
                ? GestureDetector(
                    onTap: onToggleAsr,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: escuchando
                            ? Colors.red
                            : Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Transform.scale(
                        scale: escuchando
                            ? 1.0 + (nivelVolumen / 20)
                            : 1.0,
                        child: Icon(
                          escuchando ? Icons.mic : Icons.mic_none,
                          color: escuchando ? Colors.white : Colors.white54,
                          size: 18,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
        ),

        // Indicador de escucha activa
        if (escuchando) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 4),
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              const Text(
                'Escuchando... habla ahora',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontStyle: FontStyle.italic),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onToggleAsr,
                child: const Text(
                  'Detener',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// Barra de volumen animada — muestra el nivel del micrófono
class _BarraVolumen extends StatelessWidget {
  final double nivel; // 0.0 → 10.0
  final Color color;

  const _BarraVolumen({required this.nivel, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: (nivel / 10).clamp(0.0, 1.0),
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}