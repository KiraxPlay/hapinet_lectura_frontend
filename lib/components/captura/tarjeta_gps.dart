// lib/components/captura/tarjeta_gps.dart
import 'package:flutter/material.dart';
import '../../models/posicion_result.dart';
import '../../services/geolocalizacion_service.dart';

class TarjetaGps extends StatelessWidget {
  final PosicionResult? posicion;
  final GeolocalizacionService geo;
  final VoidCallback? onReintentar;

  const TarjetaGps({
    super.key,
    required this.posicion,
    required this.geo,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: posicion != null
            ? Colors.white10
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: posicion == null
            ? Border.all(color: Colors.orange.withOpacity(0.4))
            : null,
      ),
      child: Row(
        children: [
          Icon(
            posicion != null ? Icons.location_on : Icons.location_off,
            color: posicion != null ? Colors.green : Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: posicion != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        geo.formatearCoordenadas(
                            posicion!.latitud, posicion!.longitud),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                      ),
                    ],
                  )
                : const Text(
                    'GPS no disponible — toca reintentar',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
          ),
          // Botón reintentar si no hay GPS
          if (posicion == null && onReintentar != null)
            TextButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh,
                  size: 14, color: Colors.orange),
              label: const Text('Reintentar',
                  style:
                      TextStyle(fontSize: 11, color: Colors.orange)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }
}