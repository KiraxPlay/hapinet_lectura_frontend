// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../data/database.dart';
import 'historial_screen.dart';
import 'mapa_screen.dart';
import 'lecturas_dia_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppDatabase db;
  const HomeScreen({super.key, required this.db});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  static const _tabs = [
    (icon: Icons.assignment_outlined, label: 'Lecturas'),
    (icon: Icons.list_alt,            label: 'Historial'),
    (icon: Icons.map_outlined,        label: 'Mapa'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          LecturasDiaScreen(db: widget.db),
          HistorialScreen(db: widget.db),
          MapaScreen(db: widget.db),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600),
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