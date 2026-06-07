// lib/services/historial_service.dart
import '../data/database.dart';

class HistorialDia {
  final List<Lectura> tendido;
  final List<Lectura> recreo;
  final List<Lectura> puebloNuevo;

  const HistorialDia({
    required this.tendido,
    required this.recreo,
    required this.puebloNuevo,
  });

  int get total => tendido.length + recreo.length + puebloNuevo.length;
  int get sinLectura => todos.where((l) => l.lectura == 0).length;
  int get conNota =>
      todos.where((l) => l.notas != null && l.notas!.isNotEmpty).length;
  List<Lectura> get todos => [...tendido, ...recreo, ...puebloNuevo];

  /// Filtra una lista raw por sector y construye HistorialDia
  static HistorialDia desdeListaPlana(List<Lectura> lista) {
    return HistorialDia(
      tendido: lista.where((l) => l.sector == 'TENDIDO').toList(),
      recreo: lista.where((l) => l.sector == 'RECREO').toList(),
      puebloNuevo:
          lista.where((l) => l.sector == 'PUEBLO NUEVO').toList(),
    );
  }
}

class HistorialService {
  final AppDatabase _db;

  HistorialService(this._db);

  /// Stream reactivo — se actualiza automáticamente al tomar o eliminar lecturas
  Stream<HistorialDia> watchDia({DateTime? fecha}) {
    final dia = fecha ?? DateTime.now();
    return _db
        .watchLecturasRealesDia(dia)
        .map(HistorialDia.desdeListaPlana);
  }

  /// Future para uso puntual (exportar, etc.)
  Future<HistorialDia> cargarDia({DateTime? fecha}) async {
    final dia = fecha ?? DateTime.now();
    final lista = await _db.obtenerLecturasRealesDia(dia);
    return HistorialDia.desdeListaPlana(lista);
  }
}