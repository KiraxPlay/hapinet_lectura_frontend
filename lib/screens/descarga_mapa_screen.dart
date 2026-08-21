// lib/screens/descarga_mapa_screen.dart
import 'package:flutter/material.dart';
import '../services/tiles_service.dart';

class DescargaMapaScreen extends StatefulWidget {
  const DescargaMapaScreen({super.key});

  @override
  State<DescargaMapaScreen> createState() => _DescargaMapaScreenState();
}

class _DescargaMapaScreenState extends State<DescargaMapaScreen> {
  final _tilesService = TilesService();

  bool _descargando = false;
  bool _completado = false;
  double _progreso = 0.0;
  int _descargados = 0;
  int _total = 0;
  String? _error;

  static const _sectores = [
    _SectorInfo(
      nombre: 'Tendido',
      descripcion: 'Tendido — Gigante — Huila',
      icono: Icons.location_city,
      color: Color(0xFF1976D2),
    ),
    _SectorInfo(
      nombre: 'Recreo',
      descripcion: 'Recreo — Gigante — Huila',
      icono: Icons.park_outlined,
      color: Color(0xFF388E3C),
    ),
    _SectorInfo(
      nombre: 'Pueblo Nuevo',
      descripcion: 'Pueblo Nuevo — Gigante — Huila',
      icono: Icons.home_outlined,
      color: Color(0xFF7B1FA2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Descargar mapa offline'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Explicación ───────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.blue.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.blue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Descarga el mapa de Gigante, Huila para usarlo '
                      'sin internet. Incluye los 3 sectores de ASOAGUAPO. '
                      'Requiere conexión solo la primera vez (~${TilesService.contarTiles()} tiles).',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Sectores a descargar ──────────────────
            const Text(
              'Sectores incluidos',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._sectores.map((s) => _tarjetaSector(s)),

            const SizedBox(height: 28),

            // ── Progreso ─────────────────────────────
            if (_descargando || _completado || _error != null) ...[
              _buildProgreso(),
              const SizedBox(height: 24),
            ],

            // ── Botón ────────────────────────────────
            if (!_completado)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _descargando ? null : _iniciarDescarga,
                  icon: _descargando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white),
                        )
                      : const Icon(Icons.download),
                  label: Text(_descargando
                      ? 'Descargando...'
                      : 'Descargar mapa offline'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

            if (_completado) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green, size: 24),
                    SizedBox(width: 10),
                    Text(
                      '¡Mapa descargado! Funciona sin internet.',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _iniciarDescarga,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualizar mapa'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tarjetaSector(_SectorInfo sector) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: sector.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: sector.color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: sector.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(sector.icono,
                color: sector.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sector.nombre,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: sector.color,
                      fontSize: 14),
                ),
                Text(
                  sector.descripcion,
                  style: const TextStyle(
                      fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_outline,
              color: _completado ? Colors.green : Colors.grey.shade300,
              size: 20),
        ],
      ),
    );
  }

  Widget _buildProgreso() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                        color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _completado
                    ? '¡Completado!'
                    : 'Descargando tiles...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _completado
                      ? Colors.green
                      : Colors.blue,
                ),
              ),
              Text(
                '$_descargados / $_total',
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _total > 0 ? _progreso : null,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                  _completado ? Colors.green : Colors.blue),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _completado
                ? 'Todos los tiles de Gigante, Huila descargados'
                : 'Zoom 12–16 • Tendido, Recreo y Pueblo Nuevo',
            style: const TextStyle(
                fontSize: 11, color: Colors.grey),
          ),
        ],
      ],
    );
  }

  Future<void> _iniciarDescarga() async {
    setState(() {
      _descargando = true;
      _completado = false;
      _progreso = 0;
      _descargados = 0;
      _total = TilesService.contarTiles();
      _error = null;
    });

    try {
      await _tilesService.descargar(
        onProgreso: (progreso, descargados, total) {
          if (mounted) {
            setState(() {
              _progreso = progreso;
              _descargados = descargados;
              _total = total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _descargando = false;
          _completado = true;
          _progreso = 1.0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _descargando = false;
          _error =
              'Error durante la descarga: $e\nVerifica tu conexión a internet.';
        });
      }
    }
  }
}

class _SectorInfo {
  final String nombre;
  final String descripcion;
  final IconData icono;
  final Color color;

  const _SectorInfo({
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
  });
}