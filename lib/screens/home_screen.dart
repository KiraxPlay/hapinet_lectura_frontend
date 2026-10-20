// lib/screens/home_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import 'historial_screen.dart';
import 'mapa_screen.dart';
import 'lecturas_dia_screen.dart';
import 'tutorial_screen.dart';
import 'descarga_mapa_screen.dart';
import '../services/api/api_service.dart';
import '../services/api/tarifas_service.dart';
import '../services/importar_abonados_service.dart';
import 'seleccionar_impresora_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppDatabase db;
  final Acueducto acueducto;
  final VoidCallback onCerrarSesion;

  const HomeScreen({
    super.key,
    required this.db,
    required this.acueducto,
    required this.onCerrarSesion,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;
  bool _sincronizando = false;
  int _pendientes = 0;
  StreamSubscription<int>? _pendientesSubscription;

  @override
  void initState() {
    super.initState();
    _pendientesSubscription = widget.db.watchCantidadPendientesSync().listen((
      cantidad,
    ) {
      if (mounted) setState(() => _pendientes = cantidad);
    });
  }

  @override
  void dispose() {
    _pendientesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _sincronizarPredios() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Actualizar predios/abonados'),
            content: const Text(
              'Se descargarán los predios/abonados pendientes del servidor. '
              'Las lecturas que ya fueron sincronizadas no se perderán.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Actualizar'),
              ),
            ],
          ),
    );

    if (confirmar != true) return;

    if (_sincronizando) return;
    setState(() => _sincronizando = true);

    try {
      final resultado = await ImportarAbonadosService(
        db: widget.db,
        acueducto: widget.acueducto,
      ).importar(forzar: true);

      if (resultado.total > 0) {
        // Solo cierra el período anterior después de descargar el nuevo.
        await widget.db.prepararNuevoPeriodo();
        await widget.db.borrarHistorialLecturasLibres();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado.total == 0
                ? resultado.error ?? 'El servidor no devolvió predios'
                : 'Período actualizado: ${resultado.total} predios cargados',
          
          ),

          backgroundColor: resultado.total == 0 ? Colors.orange : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo actualizar el período'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  Future<void> _sincronizar() async {
    if (_sincronizando) return;
    // Diálogo de confirmación
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            icon: const Icon(Icons.sync, color: Colors.blue, size: 36),
            title: const Text('¿Sincronizar lecturas?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Se enviarán $_pendientes lectura(s) al servidor.'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Una vez sincronizadas, las lecturas '
                          'no se podrán editar desde la app.',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                icon: const Icon(Icons.sync, size: 16),
                label: const Text('Confirmar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );

    if (confirmar != true) return;

    setState(() => _sincronizando = true);

    try {
      // Sincronizar tarifas y empresa en background
      TarifasService(acueducto: widget.acueducto).sincronizar();

      // Sincronizar lecturas pendientes
      await ApiService(widget.acueducto)
          .sincronizarLecturasPendientes(widget.db)
          .timeout(const Duration(seconds: 30));

      // Limpiar clave de importación para que el próximo arranque
      // reimporte solo los predios sin lectura en el período activo
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(
        'abonados_importados_${widget.acueducto.tipo.name}_v12',
      );

      final pendientesRestantes =
          await widget.db.watchCantidadPendientesSync().first;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              pendientesRestantes == 0
                  ? '✓ Todo sincronizado'
                  : '⚠ $pendientesRestantes lecturas pendientes',
            ),
            backgroundColor:
                pendientesRestantes == 0 ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al sincronizar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  static const _tabs = [
    (icon: Icons.assignment_outlined, label: 'Lecturas'),
    (icon: Icons.list_alt, label: 'Historial'),
    (icon: Icons.map_outlined, label: 'Mapa'),
    (icon: Icons.live_tv_outlined, label: 'Tutorial'),
  ];

  Future<void> _confirmarCerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: Text(
              '¿Salir de la cuenta ${widget.acueducto.nombre}?\n\n'
              'Las lecturas guardadas no se perderán.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );
    if (confirmar != true) return;

    // Llamar al API para invalidar el token
    try {
      await ApiService(
        widget.acueducto,
      ).logout().timeout(const Duration(seconds: 5));
    } catch (e) {
    }

    if (mounted) {
      widget.onCerrarSesion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar solo visible en la tab de Lecturas para mostrar
      // el nombre del acueducto y el botón de cerrar sesión
      appBar:
          _tabIndex == 0
              ? AppBar(
                title: Text(widget.acueducto.nombre),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.map_outlined),
                    tooltip: 'Recursos offline',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DescargaMapaScreen(),
                        ),
                      );
                    },
                  ),
                  // Botón sincronizar con badge de pendientes
                  Stack(
                    children: [
                      IconButton(
                        icon:
                            _sincronizando
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.sync),
                        onPressed: _sincronizando ? null : _sincronizar,
                        tooltip: 'Sincronizar lecturas',
                      ),
                      if (_pendientes > 0 && !_sincronizando)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$_pendientes',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Ajustes impresora',
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) =>
                        SeleccionarImpresoraScreen(acueducto: widget.acueducto))),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _confirmarCerrarSesion,
                    tooltip: 'Cerrar sesión',
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_for_offline_outlined),
                    tooltip: 'Actualizar predios',
                    onPressed: _sincronizarPredios,
                  ),
                ],
              )
              : null,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          LecturasDiaScreen(db: widget.db, acueducto: widget.acueducto),
          HistorialScreen(db: widget.db, acueducto: widget.acueducto),
          MapaScreen(db: widget.db, acueducto: widget.acueducto),
          TutorialScreen(acueducto: widget.acueducto),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items:
            _tabs
                .map(
                  (t) => BottomNavigationBarItem(
                    icon: Icon(t.icon),
                    label: t.label,
                  ),
                )
                .toList(),
      ),
    );
  }
}
