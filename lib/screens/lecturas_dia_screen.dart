import 'package:flutter/material.dart';
import '../data/database.dart';
import '../components/fondo_gotas.dart';
import 'info_abonado_screen.dart';

class LecturasDiaScreen extends StatefulWidget {
  final AppDatabase db;
  const LecturasDiaScreen({super.key, required this.db});

  @override
  State<LecturasDiaScreen> createState() => _LecturasDiaScreenState();
}

class _LecturasDiaScreenState extends State<LecturasDiaScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String _busqueda = '';
  final _busquedaCtrl = TextEditingController();
  final _focusBusqueda = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturas del día'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: StreamBuilder<List<Lectura>>(
            stream: widget.db.watchPendientesLectura(),
            builder: (context, snapshot) {
              final todos = snapshot.data ?? [];
              final tendido =
                  todos.where((l) => l.sector == 'TENDIDO').length;
              final recreo =
                  todos.where((l) => l.sector == 'RECREO').length;
              final puebloNuevo =
                  todos.where((l) => l.sector == 'PUEBLO NUEVO').length;
              return TabBar(
                controller: _tabController,
                tabs: [
                  _buildTab('Tendido', tendido),
                  _buildTab('Recreo', recreo),
                  _buildTab('Pueblo N.', puebloNuevo),
                ],
                labelStyle: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                indicatorColor: Colors.blue,
              );
            },
          ),
        ),
      ),
      body: FondoConGotas(
        child: Column(
          children: [
            // ── Búsqueda — fuera del StreamBuilder para no perder foco ──
            _buildBusqueda(),

            // ── Contenido reactivo ──
            Expanded(
              child: StreamBuilder<List<Lectura>>(
                stream: widget.db.watchPendientesLectura(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final todos = snapshot.data ?? [];
                  final tendido =
                      todos.where((l) => l.sector == 'TENDIDO').toList();
                  final recreo =
                      todos.where((l) => l.sector == 'RECREO').toList();
                  final puebloNuevo =
                      todos.where((l) => l.sector == 'PUEBLO NUEVO').toList();

                  return Column(
                    children: [
                      _buildResumen(todos.length),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLista(_filtrar(tendido)),
                            _buildLista(_filtrar(recreo)),
                            _buildLista(_filtrar(puebloNuevo)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildLista(List<Lectura> lista) {
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
        onCapturar: () => _irACaptura(lista[i]),
      ),
    );
  }

  Future<void> _irACaptura(Lectura lectura) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InfoAbonadoScreen(
          db: widget.db,
          codigoMedidor: lectura.codigoMedidor,
          nombreAbonado: lectura.nombreAbonado,
          celular: lectura.celular,
          lecturaAnterior: lectura.lectura,
          latitud: lectura.latitud,
          longitud: lectura.longitud,
          sector: lectura.sector,
          estadoMedidorClave: lectura.estadoMedidor,
        ),
      ),
    );
    // No necesita recargar — el Stream se actualiza solo
  }

  @override
  void dispose() {
    _tabController.dispose();
    _busquedaCtrl.dispose();
    _focusBusqueda.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────
// TARJETA DE ABONADO PENDIENTE
// ─────────────────────────────────────────────

class _TarjetaAbonado extends StatelessWidget {
  final Lectura lectura;
  final VoidCallback onCapturar;
  final AppDatabase db;

  const _TarjetaAbonado({
    required this.lectura,
    required this.onCapturar,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    final colorSector = switch (lectura.sector) {
      'TENDIDO' => const Color(0xFF1976D2),
      'RECREO' => const Color(0xFF388E3C),
      'PUEBLO NUEVO' => const Color(0xFF7B1FA2),
      _ => const Color(0xFF607D8B),
    };
    final inicial = (lectura.sector ?? 'O')[0];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => InfoAbonadoScreen(
              db: db,
              codigoMedidor: lectura.codigoMedidor,
              nombreAbonado: lectura.nombreAbonado,
              celular: lectura.celular,
              lecturaAnterior: lectura.lectura,
              latitud: lectura.latitud,
              longitud: lectura.longitud,
              sector: lectura.sector,
              estadoMedidorClave: lectura.estadoMedidor,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar sector
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorSector.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorSector.withOpacity(0.3)),
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
                      lectura.nombreAbonado ?? lectura.codigoMedidor ?? '—',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lectura.codigoMedidor ?? '',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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
              Icon(Icons.chevron_right, color: colorSector.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}