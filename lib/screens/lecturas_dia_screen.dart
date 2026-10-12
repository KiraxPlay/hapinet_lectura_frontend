// lib/screens/lecturas_dia_screen.dart
import 'package:flutter/material.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import '../models/punto_mapa.dart';
import '../components/fondo_gotas.dart';
import 'info_abonado_screen.dart';

class LecturasDiaScreen extends StatefulWidget {
  final AppDatabase db;
  final Acueducto acueducto;

  const LecturasDiaScreen({
    super.key,
    required this.db,
    required this.acueducto,
  });

  @override
  State<LecturasDiaScreen> createState() => _LecturasDiaScreenState();
}

class _LecturasDiaScreenState extends State<LecturasDiaScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  List<String> _sectores = [];

  String _busqueda = '';
  final _busquedaCtrl = TextEditingController();
  final _focusBusqueda = FocusNode();

  @override
  void dispose() {
    _tabController?.dispose();
    _busquedaCtrl.dispose();
    _focusBusqueda.dispose();
    super.dispose();
  }

  // Reconstruye el TabController cuando cambian los sectores
  void _actualizarTabs(List<String> nuevosSectores) {
    if (_sectores.length == nuevosSectores.length &&
        _sectores.every((s) => nuevosSectores.contains(s))) {
      return;
    }
    _tabController?.dispose();
    _sectores = nuevosSectores;
    _tabController = TabController(length: _sectores.length, vsync: this);
    setState(() {});
  }

  List<Lectura> _filtrar(List<Lectura> lista) {
    if (_busqueda.isEmpty) return lista;
    final q = _busqueda.toLowerCase();
    return lista
        .where((l) =>
            (l.nombreAbonado ?? '').toLowerCase().contains(q) ||
            (l.codigoMedidor ?? '').toLowerCase().contains(q))
        .toList();
  }

  Color _colorSector(String? sector) =>
      PuntoMapa.coloresSector[sector] ?? const Color(0xFF607D8B);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Lectura>>(
      stream: widget.db.watchPendientesLectura(),
      builder: (context, snapshot) {
        final todos = snapshot.data ?? [];

        // Extraer sectores únicos en el orden que aparecen
        final sectoresSet = <String>[];
        for (final l in todos) {
          if (l.sector != null && !sectoresSet.contains(l.sector)) {
            sectoresSet.add(l.sector!);
          }
        }
        // Si no hay pendientes, usar sectores del JSON previo
        final sectores =
            sectoresSet.isEmpty ? _sectores : sectoresSet;

        if (sectores.isNotEmpty) {
          _actualizarTabs(sectores);
        }

        // Si aún no hay tabs — puede ser BD vacía o cargando
        if (_tabController == null || _sectores.isEmpty) {
          // Si el stream ya respondió y no hay datos → BD vacía
          final bdVacia = snapshot.connectionState != ConnectionState.waiting
              && todos.isEmpty;

          return Scaffold(
            appBar: AppBar(
              title: Text('Lecturas del día — ${widget.acueducto.nombre}'),
            ),
            body: Center(
              child: bdVacia
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off,
                              size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'Sin datos disponibles',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No se pudieron cargar los abonados.\n'
                            'Verifica tu conexión y reinicia la app.'
                            'O puede que no haya periodo activo en estos momentos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Lecturas del día — ${widget.acueducto.nombre}'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                isScrollable: _sectores.length > 3,
                tabs: _sectores.map((sector) {
                  final count =
                      todos.where((l) => l.sector == sector).length;
                  return _buildTab(
                    sector.length > 8
                        ? sector.split(' ').map((w) => w[0]).join()
                        : sector,
                    count,
                  );
                }).toList(),
                labelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                indicatorColor: Colors.blue,
              ),
            ),
          ),
          body: FondoConGotas(
            child: Column(
              children: [
                _buildBusqueda(),
                Expanded(
                  child: Column(
                    children: [
                      _buildResumen(todos.length),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: _sectores.map((sector) {
                            final lista = todos
                                .where((l) => l.sector == sector)
                                .toList();
                            return _buildLista(_filtrar(lista), sector);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Tab _buildTab(String label, int pendientes) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          Text(
            '$pendientes pendientes',
            style: TextStyle(
              fontSize: 10,
              color: pendientes == 0 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusqueda() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: TextField(
        controller: _busquedaCtrl,
        focusNode: _focusBusqueda,
        onChanged: (v) => setState(() => _busqueda = v),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o código...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _busqueda.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _busquedaCtrl.clear();
                    setState(() => _busqueda = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildResumen(int pendientes) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.pending_actions, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              pendientes == 0
                  ? '¡Todas las lecturas del día completadas!'
                  : '$pendientes medidores pendientes de lectura',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: pendientes == 0 ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLista(List<Lectura> lista, String sector) {
    if (lista.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 56, color: Colors.green),
            const SizedBox(height: 12),
            const Text('¡Todo listo en este sector!',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('No hay medidores pendientes',
                style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: lista.length,
      itemBuilder: (_, i) => _TarjetaAbonado(
        lectura: lista[i],
        db: widget.db,
        colorSector: _colorSector(lista[i].sector),
        acueducto: widget.acueducto,
        onCapturar: () => _irACaptura(lista[i]),
      ),
    );
  }

  int? _extraerPredioId(String? id) {
    if (id == null) return null;
    final match = RegExp(r'predio_(\d+)').firstMatch(id);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  Future<void> _irACaptura(Lectura lectura) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InfoAbonadoScreen(
          db: widget.db,
          acueducto: widget.acueducto,
          codigoMedidor: lectura.codigoMedidor,
          predioCodigo: lectura.predioCodigo,
          nombreAbonado: lectura.nombreAbonado,
          celular: lectura.celular,
          lecturaAnterior: lectura.lecturaAnterior,
          latitud: lectura.latitud,
          longitud: lectura.longitud,
          sector: lectura.sector,
          estadoMedidorClave: lectura.estadoMedidor,
          predioId: _extraerPredioId(lectura.id),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TARJETA DE ABONADO PENDIENTE
// ─────────────────────────────────────────────

class _TarjetaAbonado extends StatelessWidget {
  final Lectura lectura;
  final VoidCallback onCapturar;
  final AppDatabase db;
  final Color colorSector;
  final Acueducto acueducto;

  const _TarjetaAbonado({
    required this.lectura,
    required this.onCapturar,
    required this.db,
    required this.colorSector,
    required this.acueducto,
  });

  @override
  Widget build(BuildContext context) {
    final inicial = (lectura.sector ?? 'O')[0].toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final match = RegExp(r'predio_(\d+)').firstMatch(lectura.id);
          final predioId = match != null ? int.tryParse(match.group(1)!) : null;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => InfoAbonadoScreen(
                db: db,
                acueducto: acueducto,
                codigoMedidor: lectura.codigoMedidor,
                predioCodigo: lectura.predioCodigo,
                nombreAbonado: lectura.nombreAbonado,
                celular: lectura.celular,
                lecturaAnterior: lectura.lecturaAnterior,
                latitud: lectura.latitud,
                longitud: lectura.longitud,
                sector: lectura.sector,
                estadoMedidorClave: lectura.estadoMedidor,
                predioId: predioId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar sector
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorSector.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: colorSector.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    inicial,
                    style: TextStyle(
                        color: colorSector,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info abonado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lectura.nombreAbonado ??
                          lectura.codigoMedidor ??
                          '—',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Medidor: ${lectura.codigoMedidor ?? 'Sin registrar'}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      'Predio: ${lectura.predioCodigo ?? 'Sin registrar'}',
                      style: const TextStyle(
                          fontSize: 11, color: Colors.grey),
                    ),
                    if (lectura.lectura > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Lectura anterior: ${lectura.lectura}',
                        style: TextStyle(
                            fontSize: 11,
                            color: colorSector,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
                Icon(Icons.chevron_right,
                  color: colorSector.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}