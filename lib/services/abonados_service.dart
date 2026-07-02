// lib/services/abonados_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/abonado.dart';

class AbonadosService {
  // El asset a cargar depende del acueducto activo
  final String jsonAsset;

  AbonadosService({required this.jsonAsset});

  // Cache en memoria — solo se lee el JSON una vez por sesion
  static final Map<String, List<Abonado>> _cache = {};

  // Limpia el cache de un asset específico
  static void limpiarCache(String jsonAsset) => _cache.remove(jsonAsset);

  // Limpia todo el cache
  static void limpiarTodo() => _cache.clear();

  Future<List<Abonado>> cargarTodos() async {
    if (_cache.containsKey(jsonAsset)) return _cache[jsonAsset]!;

    final jsonStr = await rootBundle.loadString(jsonAsset);
    final Map<String, dynamic> data = json.decode(jsonStr);

    final lista = <Abonado>[];
    for (final sector in data.keys) {
      final abonados = data[sector] as List<dynamic>;
      for (final item in abonados) {
        lista.add(Abonado.fromJson(item as Map<String, dynamic>, sector));
      }
    }

    _cache[jsonAsset] = lista;
    return lista;
  }

  Future<List<Abonado>> porSector(String sector) async {
    final todos = await cargarTodos();
    return todos.where((a) => a.sector == sector).toList();
  }

  Future<List<Abonado>> buscar(String query) async {
    final todos = await cargarTodos();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return todos;
    return todos
        .where((a) =>
            a.nombre.toLowerCase().contains(q) ||
            a.codigo.toLowerCase().contains(q))
        .toList();
  }

  Future<Map<String, int>> totalesPorSector() async {
    final todos = await cargarTodos();
    final mapa = <String, int>{};
    for (final a in todos) {
      mapa[a.sector] = (mapa[a.sector] ?? 0) + 1;
    }
    return mapa;
  }
}