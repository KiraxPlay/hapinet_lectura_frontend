import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import '../data/database.dart';
import '../models/punto_mapa.dart';
import '../models/posicion_result.dart';
import '../services/geolocalizacion_service.dart';
import '../services/mapa_service.dart';
import '../components/fondo_gotas.dart';
import '../components/mapa/chips_sector.dart';
import '../components/mapa/contador_mapa.dart';
import '../components/mapa/tarjeta_punto_mapa.dart';
import '../components/mapa/marcadores_mapa.dart';
import '../components/mapa/filtros_mapa_sheet.dart';
import '../components/mapa/resumen_mapa_sheet.dart';
import 'descarga_mapa_screen.dart';
import 'captura_screen.dart';
import 'info_abonado_screen.dart';

class MapaScreen extends StatefulWidget {
  final AppDatabase db;
  const MapaScreen({super.key, required this.db});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  late final GeolocalizacionService _geo;
  late final MapaService _mapaService;
  late final MapController _mapController;

  List<PuntoMapa> _puntos = [];
  PosicionResult? _posicionActual;
  StreamSubscription? _geoSub;
  StreamSubscription? _bdSub;
  CacheStore? _cacheStore;

  bool _cargando = true;
  PuntoMapa? _puntoSeleccionado;
  String? _sectorSeleccionado;

  bool _mostrarSinLectura = true;
  bool _mostrarPendientes = true;
  bool _mostrarSincronizados = true;
  Set<String> _estadosMedidorActivos = {};

  static const _posInicial = LatLng(2.3845, -75.5429);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _geo = GeolocalizacionService(widget.db);
    _mapaService = MapaService(widget.db);
    _inicializarCache();
    _cargarDatos();
  }

  Future<void> _inicializarCache() async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/map_tiles_cache');
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);
    setState(() => _cacheStore = FileCacheStore(cacheDir.path));
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final puntos = await _mapaService.cargarPuntos();

    PosicionResult? posicion;
    try {
      posicion = await _geo.obtenerUltimaPosicion();
      posicion ??= await _geo.obtenerPosicionActual();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _puntos = puntos;
        _posicionActual = posicion;
        _cargando = false;
      });

      if (posicion != null) {
        _mapController.move(
            LatLng(posicion.latitud, posicion.longitud), 14.0);
      } else if (puntos.isNotEmpty) {
        final centro = MapaService.centroDePoints(puntos);
        _mapController.move(LatLng(centro.lat, centro.lon), 14.0);
      }
    }

    _geoSub = _geo.watchPosicion().listen((pos) {
      if (mounted) setState(() => _posicionActual = pos);
    });

    // Cada vez que cambia cualquier lectura en la BD → recargar puntos
    _bdSub = widget.db.watchTodasLecturas().listen((_) async {
      final puntos = await _mapaService.cargarPuntos();
      if (mounted) setState(() => _puntos = puntos);
    });
  }

  // Ya no necesitamos _recargarPuntos separado — la lógica está en _bdSub

  // ─────────────────────────────────────────────
  // FILTRADO
  // ─────────────────────────────────────────────

  List<PuntoMapa> get _puntosFiltrados {
    return _puntos.where((p) {
      if (_sectorSeleccionado != null && p.sector != _sectorSeleccionado)
        return false;

      if (_estadosMedidorActivos.isNotEmpty) {
        final clave = p.estadoMedidorClave;
        if (clave == null) return false;
        if (!_estadosMedidorActivos.contains(clave)) return false;
        return true;
      }

      if (!p.tieneLecturaReal && !_mostrarSinLectura) return false;
      if (p.tieneLecturaReal &&
          p.estadoSync == 'pendiente' &&
          !_mostrarPendientes) return false;
      if (p.tieneLecturaReal &&
          p.estadoSync == 'sincronizado' &&
          !_mostrarSincronizados) return false;
      return true;
    }).toList();
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de medidores'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _estadosMedidorActivos.isNotEmpty ||
                  !_mostrarSinLectura ||
                  !_mostrarPendientes ||
                  !_mostrarSincronizados,
              label: Text(
                '${_estadosMedidorActivos.length + (!_mostrarSinLectura ? 1 : 0) + (!_mostrarPendientes ? 1 : 0) + (!_mostrarSincronizados ? 1 : 0)}',
              ),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _abrirFiltros,
            tooltip: 'Filtrar',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DescargaMapaScreen()),
            ),
            tooltip: 'Descargar mapa offline',
          ),
        ],
      ),
      body: _cargando
          ? FondoConGotas(
              child: const Center(child: CircularProgressIndicator()))
          : _buildMapa(),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'lista',
            onPressed: _abrirResumen,
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue,
            child: const Icon(Icons.list),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'miPosicion',
            onPressed: _centrarEnMiPosicion,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildMapa() {
    final filtrados = _puntosFiltrados;
    final sinLectura = filtrados.where((p) => !p.tieneLecturaReal).length;
    final conLectura = filtrados.where((p) => p.tieneLecturaReal).length;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _posicionActual != null
                ? LatLng(_posicionActual!.latitud, _posicionActual!.longitud)
                : _posInicial,
            initialZoom: 13.0,
            minZoom: 5.0,
            maxZoom: 18.0,
            onTap: (_, __) => setState(() => _puntoSeleccionado = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.hapinet.medidor_app',
              tileProvider: _cacheStore != null
                  ? CachedTileProvider(
                      store: _cacheStore!,
                      maxStale: const Duration(days: 30),
                    )
                  : NetworkTileProvider(),
              errorTileCallback: (tile, error, stackTrace) {},
              errorImage: const AssetImage('assets/images/tile_offline.png'),
            ),
            if (_posicionActual != null)
              CircleLayer(circles: [buildCirculoPrecision(_posicionActual!)]),
            MarkerLayer(
              markers: buildMarcadoresMedidores(
                puntos: filtrados,
                puntoSeleccionado: _puntoSeleccionado,
                onTap: (p) => setState(() => _puntoSeleccionado = p),
              ),
            ),
            if (_posicionActual != null)
              MarkerLayer(markers: [buildMarcadorPosicion(_posicionActual!)]),
          ],
        ),

        // Chips de sector
        Positioned(
          top: 12,
          left: 0,
          right: 0,
          child: ChipsSector(
            sectorSeleccionado: _sectorSeleccionado,
            puntos: _puntos,
            onSectorCambiado: (sector) {
              setState(() {
                _sectorSeleccionado = sector;
                _puntoSeleccionado = null;
              });
              if (sector != null) _centrarEnSector(sector);
            },
          ),
        ),

        // Contador
        Positioned(
          top: 60,
          left: 12,
          child: ContadorMapa(
            total: filtrados.length,
            sinLectura: sinLectura,
            conLectura: conLectura,
          ),
        ),

        // Tarjeta punto seleccionado
        if (_puntoSeleccionado != null)
          Positioned(
            bottom: 90,
            left: 16,
            right: 72,
            child: TarjetaPuntoMapa(
              punto: _puntoSeleccionado!,
              onCerrar: () => setState(() => _puntoSeleccionado = null),
              onCentrar: () => _mapController.move(
                LatLng(_puntoSeleccionado!.latitud,
                    _puntoSeleccionado!.longitud),
                17.0,
              ),
              // Botón "Leer" solo si NO tiene lectura real aún
              onTomarLectura: !_puntoSeleccionado!.tieneLecturaReal
                  ? () => _irACaptura(_puntoSeleccionado!)
                  : null,
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // ACCIONES
  // ─────────────────────────────────────────────

  void _centrarEnMiPosicion() {
    if (_posicionActual != null) {
      _mapController.move(
          LatLng(_posicionActual!.latitud, _posicionActual!.longitud), 15.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GPS no disponible aún')));
    }
  }

  void _centrarEnSector(String sector) {
    const centros = {
      'TENDIDO': LatLng(2.388617768340964, -75.52680856025003),
      'RECREO': LatLng(2.408369890088791, -75.52671515510596),
      'PUEBLO NUEVO': LatLng(2.397169384059909, -75.53760326671711),
    };
    final centro = centros[sector];
    if (centro == null) return;
    _mapController.move(centro, 15.0);
  }

  Future<void> _irACaptura(PuntoMapa punto) async {
    setState(() => _puntoSeleccionado = null);
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => InfoAbonadoScreen(
          db: widget.db,
          codigoMedidor: punto.codigo,
          nombreAbonado: punto.nombre,
          celular: null, // PuntoMapa no tiene celular — se ve en la BD
          lecturaAnterior: punto.lecturaActual,
          latitud: punto.latitud,
          longitud: punto.longitud,
          sector: punto.sector,
          estadoMedidorClave: punto.estadoMedidorClave,
        ),
      ),
    );
  }

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => FiltrosMapaSheet(
        mostrarSinLectura: _mostrarSinLectura,
        mostrarPendientes: _mostrarPendientes,
        mostrarSincronizados: _mostrarSincronizados,
        estadosMedidorActivos: _estadosMedidorActivos,
        onCambio: ({
          required sinLectura,
          required pendientes,
          required sincronizados,
          required estadosMedidor,
        }) {
          setState(() {
            _mostrarSinLectura = sinLectura;
            _mostrarPendientes = pendientes;
            _mostrarSincronizados = sincronizados;
            _estadosMedidorActivos = estadosMedidor;
          });
        },
      ),
    );
  }

  void _abrirResumen() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => ResumenMapaSheet(
        puntos: _puntosFiltrados,
        onTap: (p) {
          Navigator.pop(context);
          setState(() => _puntoSeleccionado = p);
          _mapController.move(LatLng(p.latitud, p.longitud), 17.0);
        },
      ),
    );
  }

  @override
  void dispose() {
    _geoSub?.cancel();
    _bdSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }
}