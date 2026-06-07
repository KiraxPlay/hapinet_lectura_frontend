// lib/components/mapa/filtros_mapa_sheet.dart
import 'package:flutter/material.dart';
import '../../models/estado_medidor.dart';

class FiltrosMapaSheet extends StatefulWidget {
  final bool mostrarSinLectura;
  final bool mostrarPendientes;
  final bool mostrarSincronizados;
  final Set<String> estadosMedidorActivos; // claves activas, vacío = todos
  final void Function({
    required bool sinLectura,
    required bool pendientes,
    required bool sincronizados,
    required Set<String> estadosMedidor,
  }) onCambio;

  const FiltrosMapaSheet({
    super.key,
    required this.mostrarSinLectura,
    required this.mostrarPendientes,
    required this.mostrarSincronizados,
    required this.estadosMedidorActivos,
    required this.onCambio,
  });

  @override
  State<FiltrosMapaSheet> createState() => _FiltrosMapaSheetState();
}

class _FiltrosMapaSheetState extends State<FiltrosMapaSheet> {
  late bool _sinLectura;
  late bool _pendientes;
  late bool _sincronizados;
  late Set<String> _estadosMedidor;

  @override
  void initState() {
    super.initState();
    _sinLectura = widget.mostrarSinLectura;
    _pendientes = widget.mostrarPendientes;
    _sincronizados = widget.mostrarSincronizados;
    _estadosMedidor = Set.from(widget.estadosMedidorActivos);
  }

  void _notificar() {
    widget.onCambio(
      sinLectura: _sinLectura,
      pendientes: _pendientes,
      sincronizados: _sincronizados,
      estadosMedidor: _estadosMedidor,
    );
  }

  void _toggleEstado(String clave) {
    setState(() {
      if (_estadosMedidor.contains(clave)) {
        _estadosMedidor.remove(clave);
      } else {
        _estadosMedidor.add(clave);
      }
    });
    _notificar();
  }

  void _limpiarEstados() {
    setState(() => _estadosMedidor.clear());
    _notificar();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Sección 1: Visibilidad general ──────────
          _seccion('Mostrar en el mapa'),
          _filtroSwitch(
            'Sin lectura (padrón pendiente)',
            Colors.grey,
            Icons.water_drop_outlined,
            _sinLectura,
            (v) {
              setState(() => _sinLectura = v);
              _notificar();
            },
          ),
          _filtroSwitch(
            'Lecturas pendientes de sync',
            Colors.orange,
            Icons.cloud_upload_outlined,
            _pendientes,
            (v) {
              setState(() => _pendientes = v);
              _notificar();
            },
          ),
          _filtroSwitch(
            'Lecturas sincronizadas',
            Colors.green,
            Icons.cloud_done_outlined,
            _sincronizados,
            (v) {
              setState(() => _sincronizados = v);
              _notificar();
            },
          ),

          const SizedBox(height: 20),

          // ── Sección 2: Filtro por estado del medidor ──
          Row(
            children: [
              _seccion('Filtrar por estado del medidor',
                  expandido: true),
              if (_estadosMedidor.isNotEmpty)
                TextButton(
                  onPressed: _limpiarEstados,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Ver todos',
                      style:
                          TextStyle(fontSize: 12, color: Colors.blue)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Toca un estado para mostrar solo esos medidores',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Chips de estado del medidor
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EstadoMedidor.values.map((estado) {
              final activo = _estadosMedidor.contains(estado.clave);
              return GestureDetector(
                onTap: () => _toggleEstado(estado.clave),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: activo
                        ? estado.colorBadge
                        : estado.colorBadge.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: activo
                          ? estado.colorBadge
                          : estado.colorBadge.withOpacity(0.35),
                      width: activo ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        estado.icono,
                        size: 14,
                        color: activo
                            ? Colors.white
                            : estado.colorBadge,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        estado.etiqueta,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: activo
                              ? Colors.white
                              : estado.colorBadge,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),

          // ── Leyenda de colores ───────────────────────
          _seccion('Referencia de colores'),
          const SizedBox(height: 8),
          ...EstadoMedidor.values.map((e) =>
              _leyenda(e.icono, e.colorMapa, e.etiqueta)),
          const SizedBox(height: 4),
          _leyenda(Icons.water_drop_outlined, Colors.grey,
              'Sin lectura aún'),
          _leyenda(Icons.water_drop, Colors.orange,
              'Lectura pendiente de sync'),
          _leyenda(Icons.water_drop, Colors.green,
              'Lectura sincronizada (sin estado)'),
        ],
      ),
    );
  }

  Widget _seccion(String titulo, {bool expandido = false}) {
    final text = Text(
      titulo,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
    return expandido ? Expanded(child: text) : text;
  }

  Widget _filtroSwitch(String label, Color color, IconData icono,
      bool valor, Function(bool) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Text(label, style: const TextStyle(fontSize: 13))),
          Switch(value: valor, onChanged: onChange, activeColor: color),
        ],
      ),
    );
  }

  Widget _leyenda(IconData icon, Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}