// lib/services/abonados_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/abonado.dart';

class AbonadosService {
  // Cache en memoria — solo se lee el JSON una vez por sesion
  static List<Abonado>? _cache;

  /// Limpia el cache — llamar antes de reimportar con JSON actualizado
  static void limpiarCache() => _cache = null;

  /// Carga todos los abonados de los 3 sectores desde el asset JSON
  /// El orden del JSON respeta la ruta del tecnico (igual que el xlsx)
  Future<List<Abonado>> cargarTodos() async {
    if (_cache != null) return _cache!;

    final jsonStr = await rootBundle.loadString('assets/abonados.json');
    final Map<String, dynamic> data = json.decode(jsonStr);

    final lista = <Abonado>[];
    // El orden de los sectores y abonados dentro de cada sector
    // viene del JSON que ya esta ordenado por ruta
    for (final sector in data.keys) {
      final abonados = data[sector] as List<dynamic>;
      for (final item in abonados) {
        lista.add(Abonado.fromJson(item as Map<String, dynamic>, sector));
      }
    }

    _cache = lista;
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
    return {
      'TENDIDO': todos.where((a) => a.sector == 'TENDIDO').length,
      'RECREO': todos.where((a) => a.sector == 'RECREO').length,
      'PUEBLO NUEVO': todos.where((a) => a.sector == 'PUEBLO NUEVO').length,
    };
  }
}