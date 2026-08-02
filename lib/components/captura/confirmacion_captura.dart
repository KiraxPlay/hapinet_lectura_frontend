// lib/components/captura/confirmacion_captura.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/foto_result.dart';
import '../../models/ocr_result.dart';
import '../../models/posicion_result.dart';
import '../../services/geolocalizacion_service.dart';
import '../captura/tarjeta_ocr.dart';
import '../captura/tarjeta_gps.dart';
import '../captura/selector_estado_medidor.dart';
import '../captura/campo_notas_asr.dart';
import '../captura/botones_confirmacion.dart';

class ConfirmacionCaptura extends StatelessWidget {
  final FotoResult? foto;
  final OcrResult? ocrResult;
  final PosicionResult? posicion;
  final GeolocalizacionService geo;
  final TextEditingController lecturaController;
  final TextEditingController notasController;
  final String? estadoMedidor;
  final bool esLecturaCero;
  final bool procesando;

  // ── ASR campos ──
  final bool asrDisponible;
  final double nivelVolumen;
  // Cuál campo está escuchando: 'lectura' | 'notas' | null
  final String? campoEscuchando;

  final void Function(String campo) onToggleAsr;
  final VoidCallback onReiniciar;
  final VoidCallback onGuardar;
  final VoidCallback onReintentar;
  final VoidCallback onChanged;
  final void Function(String? clave, bool poneLecturaEnCero) onCambioEstado;

  const ConfirmacionCaptura({
    super.key,
    required this.foto,
    required this.ocrResult,
    required this.posicion,
    required this.geo,
    required this.lecturaController,
    required this.notasController,
    required this.estadoMedidor,
    required this.esLecturaCero,
    required this.procesando,
    required this.asrDisponible,
    required this.nivelVolumen,
    required this.campoEscuchando,
    required this.onToggleAsr,
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
                TarjetaOcr(ocrResult: ocrResult),
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
                  nivelVolumen: campoEscuchando == 'lectura' ? nivelVolumen : 0.0,
                  onToggleAsr: () => onToggleAsr('lectura'),
                  onChanged: onChanged,
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
  final double nivelVolumen;
  final VoidCallback onToggleAsr;
  final VoidCallback onChanged;

  const _CampoLecturaAsr({
    required this.controller,
    required this.asrDisponible,
    required this.escuchando,
    required this.nivelVolumen,
    required this.onToggleAsr,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
          style: const TextStyle(color: Colors.white, fontSize: 28,
              fontWeight: FontWeight.bold, letterSpacing: 4),
          decoration: InputDecoration(
            hintText: 'Ej: 012345',
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: Colors.white10,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24)),
            suffixIcon: asrDisponible
                ? GestureDetector(
                    onTap: onToggleAsr,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: escuchando
                            ? Colors.blue
                            : Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Transform.scale(
                        scale: escuchando ? 1.0 + (nivelVolumen / 20) : 1.0,
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
        if (escuchando) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 4),
              Container(width: 8, height: 8,
                  decoration: const BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('Dicta el número del medidor',
                  style: TextStyle(color: Colors.blue, fontSize: 11,
                      fontStyle: FontStyle.italic)),
              const Spacer(),
              GestureDetector(
                onTap: onToggleAsr,
                child: const Text('Detener',
                    style: TextStyle(color: Colors.blue, fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}