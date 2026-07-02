// lib/services/historial_service.dart
import '../data/database.dart';
import '../models/punto_mapa.dart';

class HistorialDia {
  // Mapa dinámico sector → lecturas
  // Funciona con cualquier acueducto sin hardcodear sectores
  final Map<String, List<Lectura>> porSector;

  const HistorialDia({required this.porSector});

  int get total => porSector.values.fold(0, (s, l) => s + l.length);
  List<Lectura> get todos => porSector.values.expand((l) => l).toList();
  List<String> get sectores => porSector.keys.toList();

  static HistorialDia desdeListaPlana(List<Lectura> lista) {
    final mapa = <String, List<Lectura>>{};
    for (final l in lista) {
      final sector = l.sector ?? 'Sin sector';
      mapa.putIfAbsent(sector, () => []).add(l);
    }
    return HistorialDia(porSector: mapa);
  }

  // Compatibilidad con código anterior que usaba .tendido/.recreo/.puebloNuevo
  List<Lectura> get tendido => porSector['TENDIDO'] ?? [];
  List<Lectura> get recreo => porSector['RECREO'] ?? [];
  List<Lectura> get puebloNuevo => porSector['PUEBLO NUEVO'] ?? [];
}

class HistorialService {
  final AppDatabase _db;

  HistorialService(this._db);

  Stream<HistorialDia> watchDia({DateTime? fecha}) {
    final dia = fecha ?? DateTime.now();
    return _db
        .watchLecturasRealesDia(dia)
        .map(HistorialDia.desdeListaPlana);
  }

  Future<HistorialDia> cargarDia({DateTime? fecha}) async {
    final dia = fecha ?? DateTime.now();
    final lista = await _db.obtenerLecturasRealesDia(dia);
    return HistorialDia.desdeListaPlana(lista);
  }
}