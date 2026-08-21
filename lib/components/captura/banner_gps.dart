// lib/components/captura/banner_gps.dart
import 'package:flutter/material.dart';
import '../../models/posicion_result.dart';

class BannerGps extends StatelessWidget {
  final PosicionResult? posicion;

  const BannerGps({super.key, required this.posicion});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            posicion != null ? Icons.gps_fixed : Icons.gps_not_fixed,
            color: posicion != null ? Colors.green : Colors.orange,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            posicion != null
                ? 'GPS: ${posicion!.descripcionPrecision}'
                : 'Obteniendo GPS...',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}