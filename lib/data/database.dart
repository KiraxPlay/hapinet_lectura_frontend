// lib/data/database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

// ─────────────────────────────────────────────
// TABLA: Lecturas de medidores
// ─────────────────────────────────────────────
class Lecturas extends Table {
  TextColumn get id => text()();
  IntColumn get lectura => integer()();
  TextColumn get textoCrudo => text()();
  TextColumn get rutaFoto => text()();
  RealColumn get latitud => real()();
  RealColumn get longitud => real()();
  RealColumn get altitud => real().nullable()();
  RealColumn get precision => real().nullable()();
  TextColumn get direccionAproximada => text().nullable()();
  DateTimeColumn get fechaLectura => dateTime()();
  TextColumn get estadoSync =>
      text().withDefault(const Constant('pendiente'))();
  DateTimeColumn get fechaSync => dateTime().nullable()();
  IntColumn get intentosSync => integer().withDefault(const Constant(0))();
  TextColumn get codigoMedidor => text().nullable()();
  TextColumn get notas => text().nullable()();

  // Campos para abonados del padron
  TextColumn get nombreAbonado => text().nullable()();
  TextColumn get sector => text().nullable()();
  BoolColumn get esAbonado =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get tieneLecturaReal =>
      boolean().withDefault(const Constant(false))();

  // Lectura anterior
  IntColumn get lecturaAnterior => integer().nullable()();

  // Estado fisico del medidor
  // Valores: 'bueno', 'danado', 'empanado', 'con_fuga', 'sin_contador', 'acceso_denegado'
  TextColumn get estadoMedidor => text().nullable()();

  // Celular del abonado
  TextColumn get celular => text().nullable()();

  // Orden de ruta del tecnico — posicion en el JSON/xlsx
  // Permite mostrar la lista en el orden correcto de la ruta
  IntColumn get ordenRuta =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────
// TABLA: Historial de posiciones GPS
// ─────────────────────────────────────────────
class RegistrosGps extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitud => real()();
  RealColumn get longitud => real()();
  RealColumn get altitud => real().nullable()();
  RealColumn get precision => real()();
  RealColumn get velocidad => real().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get lecturaId => text().nullable()();
}

// ─────────────────────────────────────────────
// BASE DE DATOS
// ─────────────────────────────────────────────
@DriftDatabase(tables: [Lecturas, RegistrosGps])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => await m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(lecturas, lecturas.nombreAbonado);
            await m.addColumn(lecturas, lecturas.sector);
            await m.addColumn(lecturas, lecturas.esAbonado);
            await m.addColumn(lecturas, lecturas.tieneLecturaReal);
          }
          if (from < 3) {
            await m.addColumn(lecturas, lecturas.lecturaAnterior);
          }
          if (from < 4) {
            await m.addColumn(lecturas, lecturas.estadoMedidor);
          }
          if (from < 5) {
            await m.addColumn(lecturas, lecturas.celular);
          }
          if (from < 6) {
            await m.addColumn(lecturas, lecturas.ordenRuta);
          }
        },
      );

  // ── Lecturas ─────────────────────────────────

  Future<void> insertarLectura(LecturasCompanion lectura) =>
      into(lecturas).insert(lectura);

  Future<void> insertarAbonadoSiNoExiste(LecturasCompanion abonado) async {
    final existe = await (select(lecturas)
          ..where((l) => l.codigoMedidor.equals(
              abonado.codigoMedidor.value ?? '')))
        .getSingleOrNull();
    if (existe == null) {
      await into(lecturas).insert(abonado);
    }
  }

  Future<void> actualizarLecturaAbonado({
    required String codigoMedidor,
    required int nuevaLectura,
    required String rutaFoto,
    required double latitud,
    required double longitud,
    String? textoCrudo,
    String? notas,
    String? estadoMedidor,
  }) async {
    final registro = await (select(lecturas)
          ..where((l) => l.codigoMedidor.equals(codigoMedidor)))
        .getSingleOrNull();

    final anterior = registro?.lectura;

    await (update(lecturas)
          ..where((l) => l.codigoMedidor.equals(codigoMedidor)))
        .write(LecturasCompanion(
      lectura: Value(nuevaLectura),
      lecturaAnterior: Value(anterior),
      rutaFoto: Value(rutaFoto),
      latitud: Value(latitud),
      longitud: Value(longitud),
      textoCrudo: Value(textoCrudo ?? ''),
      notas: Value(notas),
      fechaLectura: Value(DateTime.now()),
      estadoSync: const Value('pendiente'),
      tieneLecturaReal: const Value(true),
      estadoMedidor: Value(estadoMedidor),
    ));
  }

  Future<void> eliminarLectura(String id) async {
    final registro =
        await (select(lecturas)..where((l) => l.id.equals(id)))
            .getSingleOrNull();

    if (registro == null) return;

    if (registro.esAbonado) {
      await (update(lecturas)..where((l) => l.id.equals(id))).write(
        LecturasCompanion(
          tieneLecturaReal: const Value(false),
          lectura: Value(registro.lecturaAnterior ?? 0),
          rutaFoto: const Value(''),
          textoCrudo: const Value(''),
          notas: const Value(null),
          estadoSync: const Value('pendiente'),
          fechaSync: const Value(null),
          intentosSync: const Value(0),
        ),
      );
    } else {
      await (delete(lecturas)..where((l) => l.id.equals(id))).go();
    }
  }

  // ── Queries ───────────────────────────────────

  Future<List<Lectura>> obtenerTodasLecturas() =>
      (select(lecturas)
            ..orderBy([(l) => OrderingTerm.desc(l.fechaLectura)]))
          .get();

  Future<List<Lectura>> obtenerPendientesLectura({String? sector}) async {
    final query = select(lecturas)
      ..where((l) => l.esAbonado.equals(true))
      ..where((l) => l.tieneLecturaReal.equals(false));
    if (sector != null) query.where((l) => l.sector.equals(sector));
    // Orden de ruta del tecnico (posicion en el JSON/xlsx)
    query.orderBy([(l) => OrderingTerm.asc(l.ordenRuta)]);
    return query.get();
  }

  Future<List<Lectura>> obtenerAbonados({String? sector}) async {
    final query = select(lecturas)
      ..where((l) => l.esAbonado.equals(true));
    if (sector != null) query.where((l) => l.sector.equals(sector));
    return query.get();
  }

  Future<List<Lectura>> obtenerLecturasRealesDia(DateTime dia) async {
    final inicio = DateTime(dia.year, dia.month, dia.day);
    final fin = inicio.add(const Duration(days: 1));
    return (select(lecturas)
          ..where((l) => l.tieneLecturaReal.equals(true))
          ..where((l) => l.fechaLectura.isBiggerOrEqualValue(inicio))
          ..where((l) => l.fechaLectura.isSmallerThanValue(fin))
          ..orderBy([(l) => OrderingTerm.asc(l.ordenRuta)]))
        .get();
  }

  Future<List<Lectura>> obtenerLecturasReales() =>
      (select(lecturas)
            ..where((l) => l.tieneLecturaReal.equals(true))
            ..orderBy([(l) => OrderingTerm.desc(l.fechaLectura)]))
          .get();

  Future<List<DateTime>> obtenerDiasConLecturas() async {
    final todas = await obtenerLecturasReales();
    final diasSet = <String>{};
    final dias = <DateTime>[];
    for (final l in todas) {
      final clave =
          '${l.fechaLectura.year}-${l.fechaLectura.month}-${l.fechaLectura.day}';
      if (diasSet.add(clave)) {
        dias.add(DateTime(
            l.fechaLectura.year, l.fechaLectura.month, l.fechaLectura.day));
      }
    }
    dias.sort((a, b) => b.compareTo(a));
    return dias;
  }

  Stream<List<DateTime>> watchDiasConLecturas() {
    return watchTodasLecturas().map((todas) {
      final diasSet = <String>{};
      final dias = <DateTime>[];
      for (final l in todas.where((l) => l.tieneLecturaReal)) {
        final clave =
            '${l.fechaLectura.year}-${l.fechaLectura.month}-${l.fechaLectura.day}';
        if (diasSet.add(clave)) {
          dias.add(DateTime(l.fechaLectura.year, l.fechaLectura.month,
              l.fechaLectura.day));
        }
      }
      dias.sort((a, b) => b.compareTo(a));
      return dias;
    });
  }

  Future<List<Lectura>> obtenerPendientesSync() =>
      (select(lecturas)
            ..where((l) => l.estadoSync.equals('pendiente'))
            ..where((l) => l.tieneLecturaReal.equals(true)))
          .get();

  // ── Streams reactivos ──────────────────────────

  Stream<List<Lectura>> watchTodasLecturas() =>
      (select(lecturas)
            ..orderBy([(l) => OrderingTerm.desc(l.fechaLectura)]))
          .watch();

  Stream<List<Lectura>> watchLecturasRealesDia(DateTime dia) {
    final inicio = DateTime(dia.year, dia.month, dia.day);
    final fin = inicio.add(const Duration(days: 1));
    return (select(lecturas)
          ..where((l) => l.tieneLecturaReal.equals(true))
          ..where((l) => l.fechaLectura.isBiggerOrEqualValue(inicio))
          ..where((l) => l.fechaLectura.isSmallerThanValue(fin))
          ..orderBy([(l) => OrderingTerm.asc(l.ordenRuta)]))
        .watch();
  }

  Stream<List<Lectura>> watchPendientesLectura({String? sector}) {
    final query = select(lecturas)
      ..where((l) => l.esAbonado.equals(true))
      ..where((l) => l.tieneLecturaReal.equals(false));
    if (sector != null) query.where((l) => l.sector.equals(sector));
    // Orden de ruta del tecnico
    query.orderBy([(l) => OrderingTerm.asc(l.ordenRuta)]);
    return query.watch();
  }

  // ── Sync ─────────────────────────────────────

  Future<void> actualizarEstadoSync(
      String id, String estado, DateTime? fechaSync) async {
    await (update(lecturas)..where((l) => l.id.equals(id))).write(
      LecturasCompanion(
        estadoSync: Value(estado),
        fechaSync: Value(fechaSync),
      ),
    );
  }

  Future<void> incrementarIntentosFallidos(String id) async {
    final lectura =
        await (select(lecturas)..where((l) => l.id.equals(id))).getSingle();
    await (update(lecturas)..where((l) => l.id.equals(id))).write(
      LecturasCompanion(
        intentosSync: Value(lectura.intentosSync + 1),
        estadoSync: const Value('error'),
      ),
    );
  }

  // ── GPS ──────────────────────────────────────

  Future<void> guardarPosicionGps(RegistrosGpsCompanion registro) =>
      into(registrosGps).insert(registro);

  Future<List<RegistrosGp>> obtenerUltimasPosiciones(int limite) =>
      (select(registrosGps)
            ..orderBy([(r) => OrderingTerm.desc(r.timestamp)])
            ..limit(limite))
          .get();

  Future<void> limpiarGpsAntiguo(int dias) async {
    final limite = DateTime.now().subtract(Duration(days: dias));
    await (delete(registrosGps)
          ..where((r) => r.timestamp.isSmallerThanValue(limite)))
        .go();
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'medidor_database');
}