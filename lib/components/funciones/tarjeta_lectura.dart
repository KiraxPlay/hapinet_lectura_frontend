// lib/components/funciones/tarjeta_lectura.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';
import 'color_sector.dart';
import 'detalle_lectura_sheet.dart';

class TarjetaLectura extends StatelessWidget {
  final Lectura lectura;
  final AppDatabase db;
  final VoidCallback onActualizado;

  const TarjetaLectura({
    super.key,
    required this.lectura,
    required this.db,
    required this.onActualizado,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorDeSector(lectura.sector);
    final sinLectura = lectura.lectura == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _verDetalle(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildMiniatura(color, sinLectura),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    Text(
                      lectura.nombreAbonado ?? lectura.codigoMedidor ?? '—',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lectura.codigoMedidor ?? '',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),

                    // Lectura anterior → actual + consumo
                    Row(
                      children: [
                        if (lectura.lecturaAnterior != null) ...[
                          Text(
                            '${lectura.lecturaAnterior}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.arrow_forward,
                                size: 12, color: Colors.grey),
                          ),
                        ],
                        Text(
                          sinLectura
                              ? 'Sin lectura'
                              : lectura.lectura.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: sinLectura ? Colors.orange : color,
                            letterSpacing: 1,
                          ),
                        ),
                        if (!sinLectura && lectura.lecturaAnterior != null) ...[
                          const SizedBox(width: 8),
                          _badgeConsumo(lectura.lectura -
                              lectura.lecturaAnterior!),
                        ],
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Hora + alerta sin lectura
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 3),
                        Text(
                          DateFormat('HH:mm').format(lectura.fechaLectura),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500),
                        ),
                        if (sinLectura) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.warning,
                              size: 11, color: Colors.orange),
                          const SizedBox(width: 2),
                          const Text('Sin lectura',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.orange)),
                        ],
                      ],
                    ),

                    // Observación si existe
                    if (lectura.notas != null && lectura.notas!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        lectura.notas!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets internos ──────────────────────────

  Widget _buildMiniatura(Color color, bool sinLectura) {
    if (lectura.rutaFoto.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(lectura.rutaFoto),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _avatarSector(color, sinLectura),
        ),
      );
    }
    return _avatarSector(color, sinLectura);
  }

  Widget _avatarSector(Color color, bool sinLectura) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: sinLectura
            ? Colors.orange.withOpacity(0.1)
            : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: sinLectura
              ? Colors.orange.withOpacity(0.3)
              : color.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: sinLectura
            ? const Icon(Icons.not_interested, color: Colors.orange, size: 26)
            : Text(
                inicialDeSector(lectura.sector),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
      ),
    );
  }

  Widget _badgeConsumo(int consumo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '+$consumo m³',
        style: const TextStyle(
            fontSize: 10, color: Colors.blue, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _verDetalle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DetalleLecturaSheet(
        lectura: lectura,
        db: db,
        onActualizado: onActualizado,
      ),
    );
  }
}