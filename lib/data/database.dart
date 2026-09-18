import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Drift genera database.g.dart automáticamente con:
// dart run build_runner build --delete-conflicting-outputs
part 'database.g.dart';

// ─────────────────────────────────────────────
// TABLA: Lecturas de medidores
// Define las columnas de la tabla SQLite "lecturas"
// ─────────────────────────────────────────────
class Lecturas extends Table {
  // ID único de cada lectura (UUID o 'abonado_xxx')
  TextColumn get id => text()();

  // Valor numérico del medidor leído por el técnico
  // Para abonados sin lectura aún = valor del padrón (lectura_actual del JSON)
  IntColumn get lectura => integer()();

  // Texto crudo reconocido por el OCR (para debug)
  TextColumn get textoCrudo => text()();

  // Ruta local de la foto tomada al medidor
  // Vacío ('') si aún no se ha fotografiado
  TextColumn get rutaFoto => text()();

  // Coordenadas GPS donde se tomó la lectura
  // 0.0 si no se pudo obtener GPS
  RealColumn get latitud => real()();
  RealColumn get longitud => real()();

  // Altitud y precisión GPS opcionales
  RealColumn get altitud => real().nullable()();
  RealColumn get precision => real().nullable()();

  // Dirección aproximada obtenida por geocodificación inversa
  TextColumn get direccionAproximada => text().nullable()();

  // Fecha y hora exacta de la lectura
  DateTimeColumn get fechaLectura => dateTime()();

  // Estado de sincronización con el servidor
  // Valores: 'pendiente' | 'sincronizado' | 'error'
  TextColumn get estadoSync =>
      text().withDefault(const Constant('pendiente'))();

  // Fecha en que se sincronizó con el servidor (null = no sincronizado)
  DateTimeColumn get fechaSync => dateTime().nullable()();

  // Contador de intentos fallidos de sincronización
  IntColumn get intentosSync => integer().withDefault(const Constant(0))();

  // Código del medidor del abonado (ej: TEN-0001)
  // null para lecturas libres (sin abonado del padrón)
  TextColumn get codigoMedidor => text().nullable()();

  // Código del predio en el sistema (predio_codigo) ej: PUE-0150
  TextColumn get predioCodigo => text().nullable()();

  // Notas u observaciones del técnico
  // Obligatorio cuando lectura = 0
  TextColumn get notas => text().nullable()();

  // ── Campos exclusivos para abonados del padrón ──

  // Nombre completo del abonado (importado del JSON)
  TextColumn get nombreAbonado => text().nullable()();

  // Sector al que pertenece: 'TENDIDO' | 'RECREO' | 'PUEBLO NUEVO'
  TextColumn get sector => text().nullable()();

  // true = es un abonado del padrón importado del JSON
  // false = lectura libre tomada sin abonado registrado
  BoolColumn get esAbonado => boolean().withDefault(const Constant(false))();

  // true = el técnico ya tomó la lectura este período
  // false = aún pendiente de lectura
  BoolColumn get tieneLecturaReal =>
      boolean().withDefault(const Constant(false))();

  // true cuando el técnico ya imprimió el comprobante desde el visor PDF
  BoolColumn get impreso => boolean().withDefault(const Constant(false))();
  DateTimeColumn get fechaImpresion => dateTime().nullable()();

  // Tipo de facturación elegido por el técnico: 64=Consumo, 65=Promedio, 66=SoloBasico
  IntColumn get tipoFacturacion => integer().nullable()();

  // Lectura del período anterior — se preserva al tomar nueva lectura
  // Se usa para calcular el consumo (lectura - lecturaAnterior)
  IntColumn get lecturaAnterior => integer().nullable()();

  // Estado físico del medidor reportado por el técnico
  // Valores: 'bueno' | 'danado' | 'empanado' | 'con_fuga' |
  //          'sin_contador' | 'acceso_denegado' | null (no reportado)
  TextColumn get estadoMedidor => text().nullable()();

  // Número de celular del abonado (importado del JSON)
  TextColumn get celular => text().nullable()();

  // Posición del abonado en la ruta del técnico (orden del JSON/xlsx)
  // 1 = primero en la ruta, 2 = segundo, etc.
  // Se usa para ordenar la lista del día según la ruta real
  IntColumn get ordenRuta => integer().withDefault(const Constant(0))();

  // Clave primaria — cada lectura tiene un ID único
  @override
  Set<Column> get primaryKey => {id};
}

// ─────────────────────────────────────────────
// TABLA: Historial de posiciones GPS
// Guarda el rastro de posiciones del técnico en campo
// ─────────────────────────────────────────────
class RegistrosGps extends Table {
  // ID autoincremental — Drift lo maneja automáticamente
  IntColumn get id => integer().autoIncrement()();
  RealColumn get latitud => real()();
  RealColumn get longitud => real()();
  RealColumn get altitud => real().nullable()();
  RealColumn get precision => real()();
  // Velocidad del técnico en m/s (null si el GPS no la reporta)
  RealColumn get velocidad => real().nullable()();
  // Momento exacto en que se registró la posición
  DateTimeColumn get timestamp => dateTime()();
  // ID de la lectura asociada a esta posición (opcional)
  TextColumn get lecturaId => text().nullable()();
}

// ─────────────────────────────────────────────
// BASE DE DATOS — configuración principal
// ─────────────────────────────────────────────
class NovedadesLocales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get predioId => integer()();
  TextColumn get concepto => text()();
  IntColumn get valorCuota => integer()();
  IntColumn get cuotasPendientes => integer()();
  IntColumn get totalPendiente => integer()();
}

@DriftDatabase(tables: [Lecturas, RegistrosGps, NovedadesLocales])
class AppDatabase extends _$AppDatabase {
  // nombreBd permite tener una BD por acueducto
  AppDatabase({String nombreBd = 'medidor_database'})
    : super(_openConnection(nombreBd));

  // Versión del esquema — incrementar cada vez que se añaden columnas
  // Al subir la versión, Drift llama onUpgrade automáticamente
  @override
  int get schemaVersion => 10;

  // Estrategia de migración — se ejecuta al instalar o actualizar la app
  @override
  MigrationStrategy get migration => MigrationStrategy(
    // onCreate: se llama la primera vez que se instala la app
    // Crea todas las tablas desde cero
    onCreate: (m) async => await m.createAll(),

    // onUpgrade: se llama cuando schemaVersion sube
    // Agrega las columnas nuevas según la versión anterior (from)
    onUpgrade: (m, from, to) async {
      // v1 → v2: se añadieron campos de abonado del padrón
      if (from < 2) {
        await m.addColumn(lecturas, lecturas.nombreAbonado);
        await m.addColumn(lecturas, lecturas.sector);
        await m.addColumn(lecturas, lecturas.esAbonado);
        await m.addColumn(lecturas, lecturas.tieneLecturaReal);
      }
      // v2 → v3: se añadió lectura anterior para calcular consumo
      if (from < 3) {
        await m.addColumn(lecturas, lecturas.lecturaAnterior);
      }
      // v3 → v4: se añadió estado físico del medidor
      if (from < 4) {
        await m.addColumn(lecturas, lecturas.estadoMedidor);
      }
      // v4 → v5: se añadió celular del abonado
      if (from < 5) {
        await m.addColumn(lecturas, lecturas.celular);
      }
      // v5 → v6: se añadió orden de ruta del técnico
      if (from < 6) {
        await m.addColumn(lecturas, lecturas.ordenRuta);
      }
      // v6 → v7: campo impreso y fechaImpresion
      if (from < 7) {
        await m.addColumn(lecturas, lecturas.impreso);
        await m.addColumn(lecturas, lecturas.fechaImpresion);
      }
      // v7 → v8: tabla novedades locales
      if (from < 8) {
        await m.createTable(novedadesLocales);
      }
      // v8 → v9: tipo de facturación del técnico
      if (from < 9) {
        await m.addColumn(lecturas, lecturas.tipoFacturacion);
      }
      // v9 → v10: código del predio
      if (from < 10) {
        await m.addColumn(lecturas, lecturas.predioCodigo);
      }
      // v8 → v9: tipo de facturación
      if (from < 9) {
        await m.addColumn(lecturas, lecturas.tipoFacturacion);
      }
    },
  );

  // ─────────────────────────────────────────────
  // INSERTAR / ACTUALIZAR / ELIMINAR
  // ─────────────────────────────────────────────

  // Elimina todos los abonados del padrón que NO tienen lectura real
  // Se usa para limpiar duplicados al actualizar el JSON
  // Los abonados con lectura ya tomada se conservan intactos
  Future<void> eliminarAbonadosSinLectura() async {
    await (delete(lecturas)
          ..where((l) => l.esAbonado.equals(true))
          ..where((l) => l.tieneLecturaReal.equals(false)))
        .go();
  }

  // Inicia una nueva ronda sin borrar los datos del abonado.
  // La lectura anterior queda como referencia para calcular consumo.
  Future<void> prepararNuevoPeriodo() async {
    await (update(lecturas)
          ..where((l) => l.esAbonado.equals(true)))
        .write(
      const LecturasCompanion(
        lecturaAnterior: Value.absent(),
        rutaFoto: Value(''),
        textoCrudo: Value(''),
        fechaSync: Value(null),
        intentosSync: Value(0),
        estadoSync: Value('pendiente'),
        tieneLecturaReal: Value(false),
        estadoMedidor: Value(null),
        notas: Value(null),
        impreso: Value(false),
        fechaImpresion: Value(null),
      ),
    );
  }

  // Borra las lecturas libres del período anterior.
  // Las filas de abonados se conservan y se reinician con prepararNuevoPeriodo.
  Future<void> borrarHistorialLecturasLibres() async {
    await (delete(lecturas)..where((l) => l.esAbonado.equals(false))).go();
  }

  // Inserta una lectura libre (sin abonado del padrón)
  Future<void> insertarLectura(LecturasCompanion lectura) =>
      into(lecturas).insert(lectura);

  // Inserta un abonado del padrón SOLO si no existe ya en la BD
  // Evita duplicados al reimportar el JSON
  // La verificación es por codigoMedidor (ej: TEN-201-001)
  Future<void> insertarAbonadoSiNoExiste(LecturasCompanion abonado) async {
    final existe =
        await (select(lecturas)..where(
          (l) => l.codigoMedidor.equals(abonado.codigoMedidor.value ?? ''),
        )).getSingleOrNull();
    // Solo inserta si no encontró ningún registro con ese código
    if (existe == null) {
      await into(lecturas).insert(abonado);
    }
  }

  Future<void> actualizarSectorAbonado({
    required String codigoMedidor,
    required String sector,
  }) async {
    await (update(lecturas)
          ..where((l) => l.codigoMedidor.equals(codigoMedidor)))
        .write(LecturasCompanion(sector: Value(sector)));
  }

  // Actualiza la lectura de un abonado del padrón cuando el técnico
  // la toma con la cámara. Preserva la lectura anterior para calcular consumo
  Future<void> actualizarLecturaAbonado({
    required String codigoMedidor,
    required int nuevaLectura,
    required String rutaFoto,
    required double latitud,
    required double longitud,
    String? textoCrudo,
    String? notas,
    String? estadoMedidor,
    int? tipoFacturacion,
  }) async {
    // Busca el registro actual para guardar su lectura como "anterior"
    final registro =
        await (select(lecturas)..where(
          (l) => l.codigoMedidor.equals(codigoMedidor),
        )).getSingleOrNull();

    // La lectura actual pasa a ser la anterior (para calcular consumo)
    final anterior = registro?.lectura;

    // Actualiza todos los campos de la lectura
    await (update(lecturas)
      ..where((l) => l.codigoMedidor.equals(codigoMedidor))).write(
      LecturasCompanion(
        lectura: Value(nuevaLectura),
        lecturaAnterior: Value(anterior),
        rutaFoto: Value(rutaFoto),
        latitud: Value(latitud),
        longitud: Value(longitud),
        textoCrudo: Value(textoCrudo ?? ''),
        notas: Value(notas),
        fechaLectura: Value(DateTime.now()),
        // Vuelve a 'pendiente' para que se sincronice con el servidor
        estadoSync: const Value('pendiente'),
        tieneLecturaReal: const Value(true),
        estadoMedidor: Value(estadoMedidor),
        tipoFacturacion: Value(tipoFacturacion),
      ),
    );
  }

  // Elimina o resetea una lectura según si es abonado o lectura libre
  Future<void> eliminarLectura(String id) async {
    final registro =
        await (select(lecturas)
          ..where((l) => l.id.equals(id))).getSingleOrNull();

    if (registro == null) return;

    if (registro.esAbonado) {
      // Abonado del padrón → NO se borra, solo se resetea
      // El abonado queda como "pendiente" conservando nombre, código, etc.
      await (update(lecturas)..where((l) => l.id.equals(id))).write(
        LecturasCompanion(
          tieneLecturaReal: const Value(false),
          // Restaura la lectura al valor anterior (antes de este período)
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
      // Lectura libre → se borra completamente de la BD
      await (delete(lecturas)..where((l) => l.id.equals(id))).go();
    }
  }

  // ─────────────────────────────────────────────
  // QUERIES — consultas a la BD
  // ─────────────────────────────────────────────

  // Todas las lecturas ordenadas de más reciente a más antigua
  Future<List<Lectura>> obtenerTodasLecturas() =>
      (select(lecturas)
        ..orderBy([(l) => OrderingTerm.desc(l.fechaLectura)])).get();

  // Abonados del padrón que aún NO tienen lectura del período actual
  // Ordenados por posición en la ruta del técnico (ordenRuta)
  Future<List<Lectura>> obtenerPendientesLectura({String? sector}) async {
    final query =
        select(lecturas)
          ..where((l) => l.esAbonado.equals(true))
          ..where((l) => l.tieneLecturaReal.equals(false));
    // Filtrar por sector si se especifica (T, R o P)
    if (sector != null) query.where((l) => l.sector.equals(sector));
    query.orderBy([(l) => OrderingTerm.asc(l.ordenRuta)]);
    return query.get();
  }


  // Todos los abonados del padrón (con y sin lectura)
  Future<List<Lectura>> obtenerAbonados({String? sector}) async {
    final query = select(lecturas)..where((l) => l.esAbonado.equals(true));
    if (sector != null) query.where((l) => l.sector.equals(sector));
    return query.get();
  }

  // Lecturas tomadas en un día específico
  // Ordenadas por posición en la ruta del técnico
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

  // Todas las lecturas reales (con foto/OCR), las más recientes primero
  Future<List<Lectura>> obtenerLecturasReales() =>
      (select(lecturas)
            ..where((l) => l.tieneLecturaReal.equals(true))
            ..orderBy([(l) => OrderingTerm.desc(l.fechaLectura)]))
          .get();

  // Días que tienen al menos una lectura real
  // Retorna lista de fechas ordenada de más reciente a más antigua
  Future<List<DateTime>> obtenerDiasConLecturas() async {
    final todas = await obtenerLecturasReales();
    final diasSet = <String>{};
    final dias = <DateTime>[];
    for (final l in todas) {
      // Clave única por día (sin hora)
      final clave =
          '${l.fechaLectura.year}-${l.fechaLectura.month}-${l.fechaLectura.day}';
      if (diasSet.add(clave)) {
        dias.add(
          DateTime(
            l.fechaLectura.year,
            l.fechaLectura.month,
            l.fechaLectura.day,
          ),
        );
      }
    }
    dias.sort((a, b) => b.compareTo(a));
    return dias;
  }

  // Lecturas pendientes de sincronización con el servidor
  Future<List<Lectura>> obtenerPendientesSync() =>
      (select(lecturas)
            ..where((l) => l.estadoSync.equals('pendiente'))
            ..where((l) => l.tieneLecturaReal.equals(true)))
          .get();

  // ─────────────────────────────────────────────
  // STREAMS — se actualizan automáticamente al cambiar la BD
  // Úsalos en StreamBuilder para UI reactiva
  // ─────────────────────────────────────────────

  // Stream de todas las lecturas — para historial en tiempo real
  Stream<List<Lectura>> watchTodasLecturas() =>
      (select(lecturas)
        ..orderBy([(l) => OrderingTerm.desc(l.fechaLectura)])).watch();

  // Stream de días con lecturas — para la lista del historial
  // Se recalcula automáticamente al tomar o eliminar lecturas
  Stream<List<DateTime>> watchDiasConLecturas() {
    return watchTodasLecturas().map((todas) {
      final diasSet = <String>{};
      final dias = <DateTime>[];
      for (final l in todas.where((l) => l.tieneLecturaReal)) {
        final clave =
            '${l.fechaLectura.year}-${l.fechaLectura.month}-${l.fechaLectura.day}';
        if (diasSet.add(clave)) {
          dias.add(
            DateTime(
              l.fechaLectura.year,
              l.fechaLectura.month,
              l.fechaLectura.day,
            ),
          );
        }
      }
      dias.sort((a, b) => b.compareTo(a));
      return dias;
    });
  }

  // Stream de lecturas de un día — para historial reactivo del día
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

  // Stream de pendientes — para la lista del día reactiva
  // Se actualiza automáticamente al tomar una lectura
  Stream<List<Lectura>> watchPendientesLectura({String? sector}) {
    final query =
        select(lecturas)
          ..where((l) => l.esAbonado.equals(true))
          ..where((l) => l.tieneLecturaReal.equals(false));
    if (sector != null) query.where((l) => l.sector.equals(sector));
    query.orderBy([(l) => OrderingTerm.asc(l.ordenRuta)]);
    return query.watch();
  }

  // ─────────────────────────────────────────────
  // SINCRONIZACIÓN
  // ─────────────────────────────────────────────

  // Actualiza el estado de sync de una lectura
  // Se llama después de sincronizar con el servidor
  Future<void> actualizarEstadoSync(
    String id,
    String estado,
    DateTime? fechaSync,
  ) async {
    await (update(lecturas)..where((l) => l.id.equals(id))).write(
      LecturasCompanion(estadoSync: Value(estado), fechaSync: Value(fechaSync)),
    );
  }

  // Incrementa el contador de intentos fallidos y marca como 'error'
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

  // ─────────────────────────────────────────────
  // GPS
  // ─────────────────────────────────────────────

  // Guarda una posición GPS en el historial de recorrido
  Future<void> guardarPosicionGps(RegistrosGpsCompanion registro) =>
      into(registrosGps).insert(registro);

  // Últimas N posiciones GPS registradas
  Future<List<RegistrosGp>> obtenerUltimasPosiciones(int limite) =>
      (select(registrosGps)
            ..orderBy([(r) => OrderingTerm.desc(r.timestamp)])
            ..limit(limite))
          .get();

  // Elimina posiciones GPS más antiguas que N días
  // Para no acumular demasiado historial de GPS
  Future<void> limpiarGpsAntiguo(int dias) async {
    final limite = DateTime.now().subtract(Duration(days: dias));
    await (delete(registrosGps)
      ..where((r) => r.timestamp.isSmallerThanValue(limite))).go();
  }

  // ─────────────────────────────────────────────
  // NUEVOS MÉTODOS
  // ─────────────────────────────────────────────

  // Inserta abonados en batch
  Future<void> insertarAbonadosEnBatch(
      List<LecturasCompanion> companions) async {
    await transaction(() async {
      for (final abonado in companions) {
        final id = abonado.id.value;
        final existente = await (select(lecturas)
              ..where((l) => l.id.equals(id)))
            .getSingleOrNull();

        if (existente == null) {
          await into(lecturas).insert(abonado);
        } else {
          await (update(lecturas)..where((l) => l.id.equals(id))).write(
            LecturasCompanion(
              codigoMedidor: abonado.codigoMedidor,
              predioCodigo: abonado.predioCodigo,
              nombreAbonado: abonado.nombreAbonado,
              celular: abonado.celular,
              sector: abonado.sector,
              latitud: abonado.latitud,
              longitud: abonado.longitud,
              ordenRuta: abonado.ordenRuta,
            ),
          );
        }
      }
    });
  }

  // Obtiene lecturas pendientes de sincronización
  Future<List<Lectura>> obtenerLecturasPendientesSync() async {
    return (select(lecturas)
          ..where((l) => l.estadoSync.equals('pendiente'))
          ..where((l) => l.tieneLecturaReal.equals(true)))
        .get();
  }

  // Marca una lectura como sincronizada
  Future<void> marcarLecturaSincronizada({
    required String id,
    required DateTime fechaSync,
  }) async {
    await (update(lecturas)..where((l) => l.id.equals(id))).write(
      LecturasCompanion(
        estadoSync: const Value('sincronizado'),
        fechaSync: Value(fechaSync),
      ),
    );
  }

  // Alias de incrementarIntentosFallidos para compatibilidad
  Future<void> incrementarIntentoSync(String id) =>
      incrementarIntentosFallidos(id);

  // Verifica si existe un abonado con ese código
  Future<bool> existeAbonado(String codigo) async {
    final result = await (select(lecturas)
          ..where((l) => l.codigoMedidor.equals(codigo))
          ..where((l) => l.esAbonado.equals(true)))
        .getSingleOrNull();
    return result != null;
  }

  // Actualiza datos de un abonado desde el API
  Future<void> actualizarAbonado({
    required String codigo,
    required String nombre,
    required String sector,
    double? latitud,
    double? longitud,
  }) async {
    await (update(lecturas)
          ..where((l) => l.codigoMedidor.equals(codigo)))
        .write(LecturasCompanion(
      nombreAbonado: Value(nombre),
      sector: Value(sector),
      latitud: Value(latitud ?? 0.0),
      longitud: Value(longitud ?? 0.0),
    ));
  }

  // Obtiene la lectura más reciente por código de medidor
  Future<Lectura?> obtenerLecturaPorCodigo(String codigo) async {
    return (select(lecturas)
          ..where((l) => l.codigoMedidor.equals(codigo))
          ..orderBy([(l) => OrderingTerm.desc(l.fechaLectura)])
          ..limit(1))
        .getSingleOrNull();
  }

  // Marca una lectura como impresa desde el visor PDF
  Future<void> marcarImpreso(String id) async {
    await (update(lecturas)..where((l) => l.id.equals(id))).write(
      LecturasCompanion(
        impreso: const Value(true),
        fechaImpresion: Value(DateTime.now()),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // NOVEDADES LOCALES (offline)
  // ─────────────────────────────────────────────

  Future<void> guardarNovedadesPredio(
      int predioId, List<Map<String, dynamic>> novedades) async {
    await (delete(novedadesLocales)
          ..where((n) => n.predioId.equals(predioId)))
        .go();
    if (novedades.isEmpty) return;
    await batch((b) {
      b.insertAll(
        novedadesLocales,
        novedades.map((n) => NovedadesLocalesCompanion.insert(
              predioId: predioId,
              concepto: n['concepto'] as String,
              valorCuota: n['valor_cuota'] as int,
              cuotasPendientes: n['cuotas_pendientes'] as int,
              totalPendiente: n['total_pendiente'] as int,
            )),
      );
    });
  }

  Future<List<Map<String, dynamic>>> obtenerNovedadesPredio(
      int predioId) async {
    final rows = await (select(novedadesLocales)
          ..where((n) => n.predioId.equals(predioId)))
        .get();
    return rows.map((r) => {
      'concepto': r.concepto,
      'valor_cuota': r.valorCuota,
      'cuotas_pendientes': r.cuotasPendientes,
      'total_pendiente': r.totalPendiente,
    }).toList();
  }

// Abre la conexión a la BD SQLite con el nombre especificado
// Cada acueducto usa su propio archivo de BD
static QueryExecutor _openConnection(String nombreBd) {
  return driftDatabase(name: nombreBd);
}

}