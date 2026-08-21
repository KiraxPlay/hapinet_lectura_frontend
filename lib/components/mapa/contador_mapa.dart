// lib/components/mapa/contador_mapa.dart
import 'package:flutter/material.dart';

class ContadorMapa extends StatelessWidget {
  final int total;
  final int sinLectura;
  final int conLectura;

  const ContadorMapa({
    super.key,
    required this.total,
    required this.sinLectura,
    required this.conLectura,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.water_drop, size: 14, color: Colors.blue),
              const SizedBox(width: 4),
              Text('$total medidores',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _pill('$sinLectura sin leer', Colors.grey),
              const SizedBox(width: 4),
              _pill('$conLectura leídos', Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(texto,
          style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}