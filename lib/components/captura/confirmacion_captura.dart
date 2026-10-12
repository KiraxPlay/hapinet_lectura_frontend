// lib/components/captura/confirmacion_captura.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/foto_result.dart';
import '../../models/posicion_result.dart';
import '../../services/geolocalizacion_service.dart';
import '../captura/tarjeta_consumo.dart';
import '../captura/tarjeta_gps.dart';
import '../captura/selector_estado_medidor.dart';
import '../captura/campo_notas_asr.dart';
import '../captura/botones_confirmacion.dart';

class ConfirmacionCaptura extends StatelessWidget {
  final FotoResult? foto;
  final PosicionResult? posicion;
  final int? consumo;
  final bool tieneLecturaAnterior;
  final String? estadoMedidorAnterior;
  final GeolocalizacionService geo;
  final TextEditingController lecturaController;
  final TextEditingController notasController;
  final String? estadoMedidor;
  final bool esLecturaCero;
  final bool procesando;

  // ── ASR campos ──
  final bool asrDisponible;
  final String? campoTranscribiendo; // 'lectura' | 'notas' | null
  final double nivelVolumen;
  // Cuál campo está escuchando: 'lectura' | 'notas' | null
  final String? campoEscuchando;

  final void Function(String campo) onToggleAsr;
  final VoidCallback onLecturaChanged;
  final VoidCallback onReiniciar;
  final VoidCallback onGuardar;
  final VoidCallback onReintentar;
  final VoidCallback onChanged;
  final ValueChanged<String> onCambioEstado;

  const ConfirmacionCaptura({
    super.key,
    required this.foto,
    required this.posicion,
    required this.consumo,
    required this.tieneLecturaAnterior,
    required this.estadoMedidorAnterior,
    required this.geo,
    required this.lecturaController,
    required this.notasController,
    required this.estadoMedidor,
    required this.esLecturaCero,
    required this.procesando,
    required this.asrDisponible,
    required this.campoTranscribiendo,
    required this.nivelVolumen,
    required this.campoEscuchando,
    required this.onToggleAsr,
    required this.onLecturaChanged,
    required this.onReiniciar,
    required this.onGuardar,
    required this.onReintentar,
    required this.onChanged,
    required this.onCambioEstado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (foto != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(foto!.rutaLocal),
                        height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),

                const SizedBox(height: 16),
                TarjetaConsumo(
                  consumo: consumo,
                  tieneLecturaAnterior: tieneLecturaAnterior,
                  estadoMedidorAnterior: estadoMedidorAnterior,
                ),
                const SizedBox(height: 16),

                // ── Campo lectura con ASR ──
                const Text('Número del medidor',
                    style: TextStyle(color: Colors.white70, fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _CampoLecturaAsr(
                  controller: lecturaController,
                  asrDisponible: asrDisponible,
                  escuchando: campoEscuchando == 'lectura',
                  transcribiendo: campoTranscribiendo == 'lectura',
                  nivelVolumen: campoEscuchando == 'lectura' ? nivelVolumen : 0.0,
                  onToggleAsr: () => onToggleAsr('lectura'),
                  onChanged: onLecturaChanged,
                ),

                const SizedBox(height: 16),
                TarjetaGps(posicion: posicion, geo: geo,
                    onReintentar: posicion == null ? onReintentar : null),
                const SizedBox(height: 16),

                SelectorEstadoMedidor(
                  estadoSeleccionado: estadoMedidor,
                  onCambio: onCambioEstado,
                ),
                const SizedBox(height: 12),

                // ── Campo notas con ASR ──
                CampoNotasAsr(
                  controller: notasController,
                  esLecturaCero: esLecturaCero,
                  asrDisponible: asrDisponible,
                  escuchando: campoEscuchando == 'notas',
                  transcribiendo: campoTranscribiendo == 'notas',
                  nivelVolumen: campoEscuchando == 'notas' ? nivelVolumen : 0.0,
                  onToggleAsr: () => onToggleAsr('notas'),
                  onChanged: onChanged,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        BotonesConfirmacion(
          procesando: procesando,
          onReiniciar: onReiniciar,
          onGuardar: onGuardar,
        ),
      ],
    );
  }
}

// Campo numérico con botón ASR
// Cuando el técnico dicta números en palabras se convierten a dígitos
// Ej: "cero uno dos tres" → "0123"
class _CampoLecturaAsr extends StatelessWidget {
  final TextEditingController controller;
  final bool asrDisponible;
  final bool escuchando;
  final bool transcribiendo; // true solo para este campo
  final double nivelVolumen;
  final VoidCallback onToggleAsr;
  final VoidCallback onChanged;

  const _CampoLecturaAsr({
    required this.controller,
    required this.asrDisponible,
    required this.escuchando,
    required this.transcribiendo,
    required this.nivelVolumen,
    required this.onToggleAsr,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
          style: const TextStyle(
              color: Colors.white, fontSize: 28,
              fontWeight: FontWeight.bold, letterSpacing: 4),
          decoration: InputDecoration(
            hintText: 'Ej: 012345',
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24)),
            // Micrófono solo cuando no graba ni procesa
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

        // Procesando
        if (transcribiendo) ...[
          const SizedBox(height: 6),
          const Row(children: [
            SizedBox(width: 4),
            SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.blue),
            ),
            SizedBox(width: 8),
            Text('Procesando el número...',
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontStyle: FontStyle.italic)),
          ]),
        ],

        // Grabando — botón grande
        if (escuchando) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: (nivelVolumen / 10).clamp(0.0, 1.0),
                backgroundColor: Colors.blue.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '🎤 Diga el número del medidor con calma.',
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