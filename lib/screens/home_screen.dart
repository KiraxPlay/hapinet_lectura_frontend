// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../data/database.dart';
import '../models/acueducto.dart';
import 'historial_screen.dart';
import 'mapa_screen.dart';
import 'lecturas_dia_screen.dart';
import 'tutorial_screen.dart';

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

  static const _tabs = [
    (icon: Icons.assignment_outlined, label: 'Lecturas'),
    (icon: Icons.list_alt, label: 'Historial'),
    (icon: Icons.map_outlined, label: 'Mapa'),
    (icon: Icons.live_tv_outlined, label: 'Tutorial'),
  ];

  Future<void> _confirmarCerrarSesion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
    if (confirmar == true) widget.onCerrarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar solo visible en la tab de Lecturas para mostrar
      // el nombre del acueducto y el botón de cerrar sesión
      appBar: _tabIndex == 0
          ? AppBar(
              title: Text(widget.acueducto.nombre),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _confirmarCerrarSesion,
                  tooltip: 'Cerrar sesión',
                ),
              ],
            )
          : null,
      body: IndexedStack(
        index: _tabIndex,
        children: [
          LecturasDiaScreen(
            db: widget.db,
            acueducto: widget.acueducto,
          ),
          HistorialScreen(db: widget.db, acueducto: widget.acueducto,),
          MapaScreen(
            db: widget.db,
            acueducto: widget.acueducto,
          ),
          const TutorialScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}