// lib/components/mapa/tarjeta_punto_mapa.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/punto_mapa.dart';
import '../../models/estado_medidor.dart';

/// ─────────────────────────────────────────────
/// TARJETA DEL PUNTO SELECCIONADO EN EL MAPA
/// ─────────────────────────────────────────────
/// Aparece en la parte inferior cuando el técnico
/// toca un marcador en el mapa.
///
/// GUÍA DE ESTILOS:
///   - Redondeo de la tarjeta → [BorderRadius.circular(12)] línea ~30
///   - Elevación (sombra) → [elevation: 6] línea ~29
///   - Padding interno → [EdgeInsets.all(14)] línea ~32
///   - Color botón "Centrar" → OutlinedButton, usa color por defecto del tema
///   - Color botón "Leer" → [punto.colorSector] = color del sector (T/R/P)
///   - Tamaño fuente nombre → [fontSize: 13] línea ~50
///   - Tamaño fuente lectura → [fontSize: 22] línea ~90

class TarjetaPuntoMapa extends StatelessWidget {
  final PuntoMapa punto;
  final VoidCallback onCerrar;
  final VoidCallback onCentrar;

  /// Si es null → el medidor ya tiene lectura, no muestra botón "Leer"
  /// Si no es null → muestra botón "Leer" que abre la cámara
  final VoidCallback? onTomarLectura;

  const TarjetaPuntoMapa({
    super.key,
    required this.punto,
    required this.onCerrar,
    required this.onCentrar,
    this.onTomarLectura,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,         // ← sombra de la tarjeta
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)), // ← redondeo
      child: Padding(
        padding: const EdgeInsets.all(14), // ← padding interno
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── ENCABEZADO: ícono + nombre + botón cerrar ──
            Row(
              children: [
                Icon(Icons.water_drop,
                    color: punto.colorSector, // ← color del sector
                    size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    punto.nombre,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13), // ← tamaño nombre
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: onCerrar,
                  child: const Icon(Icons.close,
                      size: 18, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // ── CÓDIGO DEL MEDIDOR ──
            Text(punto.codigo,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey)),

            // ── BADGE ESTADO DEL MEDIDOR (si fue reportado) ──
            if (punto.estadoMedidor != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: punto.estadoMedidor!.colorBadge
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: punto.estadoMedidor!.colorBadge
                          .withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(punto.estadoMedidor!.icono,
                        size: 12,
                        color: punto.estadoMedidor!.colorBadge),
                    const SizedBox(width: 4),
                    Text(
                      punto.estadoMedidor!.etiqueta,
                      style: TextStyle(
                          fontSize: 11,
                          color: punto.estadoMedidor!.colorBadge,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 14),

            // ── DATOS: lectura + fecha + badge sync ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Lectura actual
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lectura',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey)),
                    Text(
                      punto.lecturaActual?.toString() ?? '—',
                      style: const TextStyle(
                          fontSize: 22, // ← tamaño número lectura
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Fecha de la lectura (solo si tiene)
                if (punto.fechaLectura != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fecha',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey)),
                      Text(
                        DateFormat('dd/MM/yyyy\nHH:mm')
                            .format(punto.fechaLectura!),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),

                const Spacer(),

                // Badge: Sin lectura / Pendiente / Sync
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: punto.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: punto.color.withOpacity(0.4)),
                  ),
                  child: Text(
                    punto.tieneLecturaReal
                        ? (punto.estadoSync == 'sincronizado'
                            ? 'Sync'
                            : 'Pendiente')
                        : 'Sin lectura',
                    style: TextStyle(
                        fontSize: 11,
                        color: punto.color,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── BOTONES ──────────────────────────────────
            // Siempre muestra "Centrar"
            // "Leer" solo aparece si onTomarLectura != null
            // (es decir, si el medidor NO tiene lectura aún)
            Row(
              children: [

                // Botón centrar en el mapa
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCentrar,
                    icon: const Icon(
                        Icons.center_focus_strong, size: 16),
                    label: const Text('Centrar'),
                    style: OutlinedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      // ← para cambiar color del botón centrar:
                      // foregroundColor: Colors.blue,
                      // side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),

                // Botón tomar lectura (solo pendientes)
                if (onTomarLectura != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onTomarLectura,
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: const Text('Leer'),
                      style: ElevatedButton.styleFrom(
                        // ← color del botón = color del sector del abonado
                        backgroundColor: punto.colorSector,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}