// lib/components/mapa/resumen_mapa_sheet.dart
import 'package:flutter/material.dart';
import '../../models/punto_mapa.dart';

class ResumenMapaSheet extends StatelessWidget {
  final List<PuntoMapa> puntos;
  final void Function(PuntoMapa) onTap;

  const ResumenMapaSheet({
    super.key,
    required this.puntos,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sinLectura = puntos.where((p) => !p.tieneLecturaReal).length;
    final conLectura = puntos.where((p) => p.tieneLecturaReal).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text('${puntos.length} medidores',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                Text('$sinLectura sin leer · $conLectura leídos',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Divider(),
          // Lista
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: puntos.length,
              itemBuilder: (_, i) {
                final p = puntos[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: p.color.withOpacity(0.15),
                    child: Icon(
                      p.tieneLecturaReal
                          ? Icons.water_drop
                          : Icons.water_drop_outlined,
                      size: 18,
                      color: p.color,
                    ),
                  ),
                  title: Text(
                    p.nombre,
                    style: const TextStyle(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${p.codigo} · ${p.sector}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: Text(
                    p.lecturaActual?.toString() ?? '—',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  onTap: () => onTap(p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}