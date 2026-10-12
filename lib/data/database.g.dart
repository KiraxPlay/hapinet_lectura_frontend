// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LecturasTable extends Lecturas with TableInfo<$LecturasTable, Lectura> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LecturasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lecturaMeta = const VerificationMeta(
    'lectura',
  );
  @override
  late final GeneratedColumn<int> lectura = GeneratedColumn<int>(
    'lectura',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textoCrudoMeta = const VerificationMeta(
    'textoCrudo',
  );
  @override
  late final GeneratedColumn<String> textoCrudo = GeneratedColumn<String>(
    'texto_crudo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rutaFotoMeta = const VerificationMeta(
    'rutaFoto',
  );
  @override
  late final GeneratedColumn<String> rutaFoto = GeneratedColumn<String>(
    'ruta_foto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudMeta = const VerificationMeta(
    'latitud',
  );
  @override
  late final GeneratedColumn<double> latitud = GeneratedColumn<double>(
    'latitud',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudMeta = const VerificationMeta(
    'longitud',
  );
  @override
  late final GeneratedColumn<double> longitud = GeneratedColumn<double>(
    'longitud',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudMeta = const VerificationMeta(
    'altitud',
  );
  @override
  late final GeneratedColumn<double> altitud = GeneratedColumn<double>(
    'altitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _precisionMeta = const VerificationMeta(
    'precision',
  );
  @override
  late final GeneratedColumn<double> precision = GeneratedColumn<double>(
    'precision',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _direccionAproximadaMeta =
      const VerificationMeta('direccionAproximada');
  @override
  late final GeneratedColumn<String> direccionAproximada =
      GeneratedColumn<String>(
        'direccion_aproximada',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fechaLecturaMeta = const VerificationMeta(
    'fechaLectura',
  );
  @override
  late final GeneratedColumn<DateTime> fechaLectura = GeneratedColumn<DateTime>(
    'fecha_lectura',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pendiente'),
  );
  static const VerificationMeta _fechaSyncMeta = const VerificationMeta(
    'fechaSync',
  );
  @override
  late final GeneratedColumn<DateTime> fechaSync = GeneratedColumn<DateTime>(
    'fecha_sync',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intentosSyncMeta = const VerificationMeta(
    'intentosSync',
  );
  @override
  late final GeneratedColumn<int> intentosSync = GeneratedColumn<int>(
    'intentos_sync',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _codigoMedidorMeta = const VerificationMeta(
    'codigoMedidor',
  );
  @override
  late final GeneratedColumn<String> codigoMedidor = GeneratedColumn<String>(
    'codigo_medidor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _predioCodigoMeta = const VerificationMeta(
    'predioCodigo',
  );
  @override
  late final GeneratedColumn<String> predioCodigo = GeneratedColumn<String>(
    'predio_codigo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notasMeta = const VerificationMeta('notas');
  @override
  late final GeneratedColumn<String> notas = GeneratedColumn<String>(
    'notas',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreAbonadoMeta = const VerificationMeta(
    'nombreAbonado',
  );
  @override
  late final GeneratedColumn<String> nombreAbonado = GeneratedColumn<String>(
    'nombre_abonado',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
    'sector',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _esAbonadoMeta = const VerificationMeta(
    'esAbonado',
  );
  @override
  late final GeneratedColumn<bool> esAbonado = GeneratedColumn<bool>(
    'es_abonado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_abonado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tieneLecturaRealMeta = const VerificationMeta(
    'tieneLecturaReal',
  );
  @override
  late final GeneratedColumn<bool> tieneLecturaReal = GeneratedColumn<bool>(
    'tiene_lectura_real',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("tiene_lectura_real" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _impresoMeta = const VerificationMeta(
    'impreso',
  );
  @override
  late final GeneratedColumn<bool> impreso = GeneratedColumn<bool>(
    'impreso',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("impreso" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fechaImpresionMeta = const VerificationMeta(
    'fechaImpresion',
  );
  @override
  late final GeneratedColumn<DateTime> fechaImpresion =
      GeneratedColumn<DateTime>(
        'fecha_impresion',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tipoFacturacionMeta = const VerificationMeta(
    'tipoFacturacion',
  );
  @override
  late final GeneratedColumn<int> tipoFacturacion = GeneratedColumn<int>(
    'tipo_facturacion',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lecturaAnteriorMeta = const VerificationMeta(
    'lecturaAnterior',
  );
  @override
  late final GeneratedColumn<int> lecturaAnterior = GeneratedColumn<int>(
    'lectura_anterior',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consumoAnteriorServidorMeta =
      const VerificationMeta('consumoAnteriorServidor');
  @override
  late final GeneratedColumn<int> consumoAnteriorServidor =
      GeneratedColumn<int>(
        'consumo_anterior_servidor',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lecturaActualServidorMeta =
      const VerificationMeta('lecturaActualServidor');
  @override
  late final GeneratedColumn<int> lecturaActualServidor = GeneratedColumn<int>(
    'lectura_actual_servidor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoMedidorServidorMeta =
      const VerificationMeta('estadoMedidorServidor');
  @override
  late final GeneratedColumn<String> estadoMedidorServidor =
      GeneratedColumn<String>(
        'estado_medidor_servidor',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _estadoMedidorMeta = const VerificationMeta(
    'estadoMedidor',
  );
  @override
  late final GeneratedColumn<String> estadoMedidor = GeneratedColumn<String>(
    'estado_medidor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _celularMeta = const VerificationMeta(
    'celular',
  );
  @override
  late final GeneratedColumn<String> celular = GeneratedColumn<String>(
    'celular',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordenRutaMeta = const VerificationMeta(
    'ordenRuta',
  );
  @override
  late final GeneratedColumn<int> ordenRuta = GeneratedColumn<int>(
    'orden_ruta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lectura,
    textoCrudo,
    rutaFoto,
    latitud,
    longitud,
    altitud,
    precision,
    direccionAproximada,
    fechaLectura,
    estadoSync,
    fechaSync,
    intentosSync,
    codigoMedidor,
    predioCodigo,
    notas,
    nombreAbonado,
    sector,
    esAbonado,
    tieneLecturaReal,
    impreso,
    fechaImpresion,
    tipoFacturacion,
    lecturaAnterior,
    consumoAnteriorServidor,
    lecturaActualServidor,
    estadoMedidorServidor,
    estadoMedidor,
    celular,
    ordenRuta,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lecturas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lectura> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lectura')) {
      context.handle(
        _lecturaMeta,
        lectura.isAcceptableOrUnknown(data['lectura']!, _lecturaMeta),
      );
    } else if (isInserting) {
      context.missing(_lecturaMeta);
    }
    if (data.containsKey('texto_crudo')) {
      context.handle(
        _textoCrudoMeta,
        textoCrudo.isAcceptableOrUnknown(data['texto_crudo']!, _textoCrudoMeta),
      );
    } else if (isInserting) {
      context.missing(_textoCrudoMeta);
    }
    if (data.containsKey('ruta_foto')) {
      context.handle(
        _rutaFotoMeta,
        rutaFoto.isAcceptableOrUnknown(data['ruta_foto']!, _rutaFotoMeta),
      );
    } else if (isInserting) {
      context.missing(_rutaFotoMeta);
    }
    if (data.containsKey('latitud')) {
      context.handle(
        _latitudMeta,
        latitud.isAcceptableOrUnknown(data['latitud']!, _latitudMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudMeta);
    }
    if (data.containsKey('longitud')) {
      context.handle(
        _longitudMeta,
        longitud.isAcceptableOrUnknown(data['longitud']!, _longitudMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudMeta);
    }
    if (data.containsKey('altitud')) {
      context.handle(
        _altitudMeta,
        altitud.isAcceptableOrUnknown(data['altitud']!, _altitudMeta),
      );
    }
    if (data.containsKey('precision')) {
      context.handle(
        _precisionMeta,
        precision.isAcceptableOrUnknown(data['precision']!, _precisionMeta),
      );
    }
    if (data.containsKey('direccion_aproximada')) {
      context.handle(
        _direccionAproximadaMeta,
        direccionAproximada.isAcceptableOrUnknown(
          data['direccion_aproximada']!,
          _direccionAproximadaMeta,
        ),
      );
    }
    if (data.containsKey('fecha_lectura')) {
      context.handle(
        _fechaLecturaMeta,
        fechaLectura.isAcceptableOrUnknown(
          data['fecha_lectura']!,
          _fechaLecturaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fechaLecturaMeta);
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('fecha_sync')) {
      context.handle(
        _fechaSyncMeta,
        fechaSync.isAcceptableOrUnknown(data['fecha_sync']!, _fechaSyncMeta),
      );
    }
    if (data.containsKey('intentos_sync')) {
      context.handle(
        _intentosSyncMeta,
        intentosSync.isAcceptableOrUnknown(
          data['intentos_sync']!,
          _intentosSyncMeta,
        ),
      );
    }
    if (data.containsKey('codigo_medidor')) {
      context.handle(
        _codigoMedidorMeta,
        codigoMedidor.isAcceptableOrUnknown(
          data['codigo_medidor']!,
          _codigoMedidorMeta,
        ),
      );
    }
    if (data.containsKey('predio_codigo')) {
      context.handle(
        _predioCodigoMeta,
        predioCodigo.isAcceptableOrUnknown(
          data['predio_codigo']!,
          _predioCodigoMeta,
        ),
      );
    }
    if (data.containsKey('notas')) {
      context.handle(
        _notasMeta,
        notas.isAcceptableOrUnknown(data['notas']!, _notasMeta),
      );
    }
    if (data.containsKey('nombre_abonado')) {
      context.handle(
        _nombreAbonadoMeta,
        nombreAbonado.isAcceptableOrUnknown(
          data['nombre_abonado']!,
          _nombreAbonadoMeta,
        ),
      );
    }
    if (data.containsKey('sector')) {
      context.handle(
        _sectorMeta,
        sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta),
      );
    }
    if (data.containsKey('es_abonado')) {
      context.handle(
        _esAbonadoMeta,
        esAbonado.isAcceptableOrUnknown(data['es_abonado']!, _esAbonadoMeta),
      );
    }
    if (data.containsKey('tiene_lectura_real')) {
      context.handle(
        _tieneLecturaRealMeta,
        tieneLecturaReal.isAcceptableOrUnknown(
          data['tiene_lectura_real']!,
          _tieneLecturaRealMeta,
        ),
      );
    }
    if (data.containsKey('impreso')) {
      context.handle(
        _impresoMeta,
        impreso.isAcceptableOrUnknown(data['impreso']!, _impresoMeta),
      );
    }
    if (data.containsKey('fecha_impresion')) {
      context.handle(
        _fechaImpresionMeta,
        fechaImpresion.isAcceptableOrUnknown(
          data['fecha_impresion']!,
          _fechaImpresionMeta,
        ),
      );
    }
    if (data.containsKey('tipo_facturacion')) {
      context.handle(
        _tipoFacturacionMeta,
        tipoFacturacion.isAcceptableOrUnknown(
          data['tipo_facturacion']!,
          _tipoFacturacionMeta,
        ),
      );
    }
    if (data.containsKey('lectura_anterior')) {
      context.handle(
        _lecturaAnteriorMeta,
        lecturaAnterior.isAcceptableOrUnknown(
          data['lectura_anterior']!,
          _lecturaAnteriorMeta,
        ),
      );
    }
    if (data.containsKey('consumo_anterior_servidor')) {
      context.handle(
        _consumoAnteriorServidorMeta,
        consumoAnteriorServidor.isAcceptableOrUnknown(
          data['consumo_anterior_servidor']!,
          _consumoAnteriorServidorMeta,
        ),
      );
    }
    if (data.containsKey('lectura_actual_servidor')) {
      context.handle(
        _lecturaActualServidorMeta,
        lecturaActualServidor.isAcceptableOrUnknown(
          data['lectura_actual_servidor']!,
          _lecturaActualServidorMeta,
        ),
      );
    }
    if (data.containsKey('estado_medidor_servidor')) {
      context.handle(
        _estadoMedidorServidorMeta,
        estadoMedidorServidor.isAcceptableOrUnknown(
          data['estado_medidor_servidor']!,
          _estadoMedidorServidorMeta,
        ),
      );
    }
    if (data.containsKey('estado_medidor')) {
      context.handle(
        _estadoMedidorMeta,
        estadoMedidor.isAcceptableOrUnknown(
          data['estado_medidor']!,
          _estadoMedidorMeta,
        ),
      );
    }
    if (data.containsKey('celular')) {
      context.handle(
        _celularMeta,
        celular.isAcceptableOrUnknown(data['celular']!, _celularMeta),
      );
    }
    if (data.containsKey('orden_ruta')) {
      context.handle(
        _ordenRutaMeta,
        ordenRuta.isAcceptableOrUnknown(data['orden_ruta']!, _ordenRutaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lectura map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lectura(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      lectura:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}lectura'],
          )!,
      textoCrudo:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}texto_crudo'],
          )!,
      rutaFoto:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}ruta_foto'],
          )!,
      latitud:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}latitud'],
          )!,
      longitud:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}longitud'],
          )!,
      altitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitud'],
      ),
      precision: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precision'],
      ),
      direccionAproximada: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direccion_aproximada'],
      ),
      fechaLectura:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}fecha_lectura'],
          )!,
      estadoSync:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}estado_sync'],
          )!,
      fechaSync: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_sync'],
      ),
      intentosSync:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}intentos_sync'],
          )!,
      codigoMedidor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_medidor'],
      ),
      predioCodigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}predio_codigo'],
      ),
      notas: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notas'],
      ),
      nombreAbonado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_abonado'],
      ),
      sector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector'],
      ),
      esAbonado:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}es_abonado'],
          )!,
      tieneLecturaReal:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}tiene_lectura_real'],
          )!,
      impreso:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}impreso'],
          )!,
      fechaImpresion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_impresion'],
      ),
      tipoFacturacion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tipo_facturacion'],
      ),
      lecturaAnterior: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lectura_anterior'],
      ),
      consumoAnteriorServidor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}consumo_anterior_servidor'],
      ),
      lecturaActualServidor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lectura_actual_servidor'],
      ),
      estadoMedidorServidor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_medidor_servidor'],
      ),
      estadoMedidor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_medidor'],
      ),
      celular: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}celular'],
      ),
      ordenRuta:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}orden_ruta'],
          )!,
    );
  }

  @override
  $LecturasTable createAlias(String alias) {
    return $LecturasTable(attachedDatabase, alias);
  }
}

class Lectura extends DataClass implements Insertable<Lectura> {
  final String id;
  final int lectura;
  final String textoCrudo;
  final String rutaFoto;
  final double latitud;
  final double longitud;
  final double? altitud;
  final double? precision;
  final String? direccionAproximada;
  final DateTime fechaLectura;
  final String estadoSync;
  final DateTime? fechaSync;
  final int intentosSync;
  final String? codigoMedidor;
  final String? predioCodigo;
  final String? notas;
  final String? nombreAbonado;
  final String? sector;
  final bool esAbonado;
  final bool tieneLecturaReal;
  final bool impreso;
  final DateTime? fechaImpresion;
  final int? tipoFacturacion;
  final int? lecturaAnterior;
  final int? consumoAnteriorServidor;
  final int? lecturaActualServidor;
  final String? estadoMedidorServidor;
  final String? estadoMedidor;
  final String? celular;
  final int ordenRuta;
  const Lectura({
    required this.id,
    required this.lectura,
    required this.textoCrudo,
    required this.rutaFoto,
    required this.latitud,
    required this.longitud,
    this.altitud,
    this.precision,
    this.direccionAproximada,
    required this.fechaLectura,
    required this.estadoSync,
    this.fechaSync,
    required this.intentosSync,
    this.codigoMedidor,
    this.predioCodigo,
    this.notas,
    this.nombreAbonado,
    this.sector,
    required this.esAbonado,
    required this.tieneLecturaReal,
    required this.impreso,
    this.fechaImpresion,
    this.tipoFacturacion,
    this.lecturaAnterior,
    this.consumoAnteriorServidor,
    this.lecturaActualServidor,
    this.estadoMedidorServidor,
    this.estadoMedidor,
    this.celular,
    required this.ordenRuta,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lectura'] = Variable<int>(lectura);
    map['texto_crudo'] = Variable<String>(textoCrudo);
    map['ruta_foto'] = Variable<String>(rutaFoto);
    map['latitud'] = Variable<double>(latitud);
    map['longitud'] = Variable<double>(longitud);
    if (!nullToAbsent || altitud != null) {
      map['altitud'] = Variable<double>(altitud);
    }
    if (!nullToAbsent || precision != null) {
      map['precision'] = Variable<double>(precision);
    }
    if (!nullToAbsent || direccionAproximada != null) {
      map['direccion_aproximada'] = Variable<String>(direccionAproximada);
    }
    map['fecha_lectura'] = Variable<DateTime>(fechaLectura);
    map['estado_sync'] = Variable<String>(estadoSync);
    if (!nullToAbsent || fechaSync != null) {
      map['fecha_sync'] = Variable<DateTime>(fechaSync);
    }
    map['intentos_sync'] = Variable<int>(intentosSync);
    if (!nullToAbsent || codigoMedidor != null) {
      map['codigo_medidor'] = Variable<String>(codigoMedidor);
    }
    if (!nullToAbsent || predioCodigo != null) {
      map['predio_codigo'] = Variable<String>(predioCodigo);
    }
    if (!nullToAbsent || notas != null) {
      map['notas'] = Variable<String>(notas);
    }
    if (!nullToAbsent || nombreAbonado != null) {
      map['nombre_abonado'] = Variable<String>(nombreAbonado);
    }
    if (!nullToAbsent || sector != null) {
      map['sector'] = Variable<String>(sector);
    }
    map['es_abonado'] = Variable<bool>(esAbonado);
    map['tiene_lectura_real'] = Variable<bool>(tieneLecturaReal);
    map['impreso'] = Variable<bool>(impreso);
    if (!nullToAbsent || fechaImpresion != null) {
      map['fecha_impresion'] = Variable<DateTime>(fechaImpresion);
    }
    if (!nullToAbsent || tipoFacturacion != null) {
      map['tipo_facturacion'] = Variable<int>(tipoFacturacion);
    }
    if (!nullToAbsent || lecturaAnterior != null) {
      map['lectura_anterior'] = Variable<int>(lecturaAnterior);
    }
    if (!nullToAbsent || consumoAnteriorServidor != null) {
      map['consumo_anterior_servidor'] = Variable<int>(consumoAnteriorServidor);
    }
    if (!nullToAbsent || lecturaActualServidor != null) {
      map['lectura_actual_servidor'] = Variable<int>(lecturaActualServidor);
    }
    if (!nullToAbsent || estadoMedidorServidor != null) {
      map['estado_medidor_servidor'] = Variable<String>(estadoMedidorServidor);
    }
    if (!nullToAbsent || estadoMedidor != null) {
      map['estado_medidor'] = Variable<String>(estadoMedidor);
    }
    if (!nullToAbsent || celular != null) {
      map['celular'] = Variable<String>(celular);
    }
    map['orden_ruta'] = Variable<int>(ordenRuta);
    return map;
  }

  LecturasCompanion toCompanion(bool nullToAbsent) {
    return LecturasCompanion(
      id: Value(id),
      lectura: Value(lectura),
      textoCrudo: Value(textoCrudo),
      rutaFoto: Value(rutaFoto),
      latitud: Value(latitud),
      longitud: Value(longitud),
      altitud:
          altitud == null && nullToAbsent
              ? const Value.absent()
              : Value(altitud),
      precision:
          precision == null && nullToAbsent
              ? const Value.absent()
              : Value(precision),
      direccionAproximada:
          direccionAproximada == null && nullToAbsent
              ? const Value.absent()
              : Value(direccionAproximada),
      fechaLectura: Value(fechaLectura),
      estadoSync: Value(estadoSync),
      fechaSync:
          fechaSync == null && nullToAbsent
              ? const Value.absent()
              : Value(fechaSync),
      intentosSync: Value(intentosSync),
      codigoMedidor:
          codigoMedidor == null && nullToAbsent
              ? const Value.absent()
              : Value(codigoMedidor),
      predioCodigo:
          predioCodigo == null && nullToAbsent
              ? const Value.absent()
              : Value(predioCodigo),
      notas:
          notas == null && nullToAbsent ? const Value.absent() : Value(notas),
      nombreAbonado:
          nombreAbonado == null && nullToAbsent
              ? const Value.absent()
              : Value(nombreAbonado),
      sector:
          sector == null && nullToAbsent ? const Value.absent() : Value(sector),
      esAbonado: Value(esAbonado),
      tieneLecturaReal: Value(tieneLecturaReal),
      impreso: Value(impreso),
      fechaImpresion:
          fechaImpresion == null && nullToAbsent
              ? const Value.absent()
              : Value(fechaImpresion),
      tipoFacturacion:
          tipoFacturacion == null && nullToAbsent
              ? const Value.absent()
              : Value(tipoFacturacion),
      lecturaAnterior:
          lecturaAnterior == null && nullToAbsent
              ? const Value.absent()
              : Value(lecturaAnterior),
      consumoAnteriorServidor:
          consumoAnteriorServidor == null && nullToAbsent
              ? const Value.absent()
              : Value(consumoAnteriorServidor),
      lecturaActualServidor:
          lecturaActualServidor == null && nullToAbsent
              ? const Value.absent()
              : Value(lecturaActualServidor),
      estadoMedidorServidor:
          estadoMedidorServidor == null && nullToAbsent
              ? const Value.absent()
              : Value(estadoMedidorServidor),
      estadoMedidor:
          estadoMedidor == null && nullToAbsent
              ? const Value.absent()
              : Value(estadoMedidor),
      celular:
          celular == null && nullToAbsent
              ? const Value.absent()
              : Value(celular),
      ordenRuta: Value(ordenRuta),
    );
  }

  factory Lectura.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lectura(
      id: serializer.fromJson<String>(json['id']),
      lectura: serializer.fromJson<int>(json['lectura']),
      textoCrudo: serializer.fromJson<String>(json['textoCrudo']),
      rutaFoto: serializer.fromJson<String>(json['rutaFoto']),
      latitud: serializer.fromJson<double>(json['latitud']),
      longitud: serializer.fromJson<double>(json['longitud']),
      altitud: serializer.fromJson<double?>(json['altitud']),
      precision: serializer.fromJson<double?>(json['precision']),
      direccionAproximada: serializer.fromJson<String?>(
        json['direccionAproximada'],
      ),
      fechaLectura: serializer.fromJson<DateTime>(json['fechaLectura']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      fechaSync: serializer.fromJson<DateTime?>(json['fechaSync']),
      intentosSync: serializer.fromJson<int>(json['intentosSync']),
      codigoMedidor: serializer.fromJson<String?>(json['codigoMedidor']),
      predioCodigo: serializer.fromJson<String?>(json['predioCodigo']),
      notas: serializer.fromJson<String?>(json['notas']),
      nombreAbonado: serializer.fromJson<String?>(json['nombreAbonado']),
      sector: serializer.fromJson<String?>(json['sector']),
      esAbonado: serializer.fromJson<bool>(json['esAbonado']),
      tieneLecturaReal: serializer.fromJson<bool>(json['tieneLecturaReal']),
      impreso: serializer.fromJson<bool>(json['impreso']),
      fechaImpresion: serializer.fromJson<DateTime?>(json['fechaImpresion']),
      tipoFacturacion: serializer.fromJson<int?>(json['tipoFacturacion']),
      lecturaAnterior: serializer.fromJson<int?>(json['lecturaAnterior']),
      consumoAnteriorServidor: serializer.fromJson<int?>(
        json['consumoAnteriorServidor'],
      ),
      lecturaActualServidor: serializer.fromJson<int?>(
        json['lecturaActualServidor'],
      ),
      estadoMedidorServidor: serializer.fromJson<String?>(
        json['estadoMedidorServidor'],
      ),
      estadoMedidor: serializer.fromJson<String?>(json['estadoMedidor']),
      celular: serializer.fromJson<String?>(json['celular']),
      ordenRuta: serializer.fromJson<int>(json['ordenRuta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lectura': serializer.toJson<int>(lectura),
      'textoCrudo': serializer.toJson<String>(textoCrudo),
      'rutaFoto': serializer.toJson<String>(rutaFoto),
      'latitud': serializer.toJson<double>(latitud),
      'longitud': serializer.toJson<double>(longitud),
      'altitud': serializer.toJson<double?>(altitud),
      'precision': serializer.toJson<double?>(precision),
      'direccionAproximada': serializer.toJson<String?>(direccionAproximada),
      'fechaLectura': serializer.toJson<DateTime>(fechaLectura),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'fechaSync': serializer.toJson<DateTime?>(fechaSync),
      'intentosSync': serializer.toJson<int>(intentosSync),
      'codigoMedidor': serializer.toJson<String?>(codigoMedidor),
      'predioCodigo': serializer.toJson<String?>(predioCodigo),
      'notas': serializer.toJson<String?>(notas),
      'nombreAbonado': serializer.toJson<String?>(nombreAbonado),
      'sector': serializer.toJson<String?>(sector),
      'esAbonado': serializer.toJson<bool>(esAbonado),
      'tieneLecturaReal': serializer.toJson<bool>(tieneLecturaReal),
      'impreso': serializer.toJson<bool>(impreso),
      'fechaImpresion': serializer.toJson<DateTime?>(fechaImpresion),
      'tipoFacturacion': serializer.toJson<int?>(tipoFacturacion),
      'lecturaAnterior': serializer.toJson<int?>(lecturaAnterior),
      'consumoAnteriorServidor': serializer.toJson<int?>(
        consumoAnteriorServidor,
      ),
      'lecturaActualServidor': serializer.toJson<int?>(lecturaActualServidor),
      'estadoMedidorServidor': serializer.toJson<String?>(
        estadoMedidorServidor,
      ),
      'estadoMedidor': serializer.toJson<String?>(estadoMedidor),
      'celular': serializer.toJson<String?>(celular),
      'ordenRuta': serializer.toJson<int>(ordenRuta),
    };
  }

  Lectura copyWith({
    String? id,
    int? lectura,
    String? textoCrudo,
    String? rutaFoto,
    double? latitud,
    double? longitud,
    Value<double?> altitud = const Value.absent(),
    Value<double?> precision = const Value.absent(),
    Value<String?> direccionAproximada = const Value.absent(),
    DateTime? fechaLectura,
    String? estadoSync,
    Value<DateTime?> fechaSync = const Value.absent(),
    int? intentosSync,
    Value<String?> codigoMedidor = const Value.absent(),
    Value<String?> predioCodigo = const Value.absent(),
    Value<String?> notas = const Value.absent(),
    Value<String?> nombreAbonado = const Value.absent(),
    Value<String?> sector = const Value.absent(),
    bool? esAbonado,
    bool? tieneLecturaReal,
    bool? impreso,
    Value<DateTime?> fechaImpresion = const Value.absent(),
    Value<int?> tipoFacturacion = const Value.absent(),
    Value<int?> lecturaAnterior = const Value.absent(),
    Value<int?> consumoAnteriorServidor = const Value.absent(),
    Value<int?> lecturaActualServidor = const Value.absent(),
    Value<String?> estadoMedidorServidor = const Value.absent(),
    Value<String?> estadoMedidor = const Value.absent(),
    Value<String?> celular = const Value.absent(),
    int? ordenRuta,
  }) => Lectura(
    id: id ?? this.id,
    lectura: lectura ?? this.lectura,
    textoCrudo: textoCrudo ?? this.textoCrudo,
    rutaFoto: rutaFoto ?? this.rutaFoto,
    latitud: latitud ?? this.latitud,
    longitud: longitud ?? this.longitud,
    altitud: altitud.present ? altitud.value : this.altitud,
    precision: precision.present ? precision.value : this.precision,
    direccionAproximada:
        direccionAproximada.present
            ? direccionAproximada.value
            : this.direccionAproximada,
    fechaLectura: fechaLectura ?? this.fechaLectura,
    estadoSync: estadoSync ?? this.estadoSync,
    fechaSync: fechaSync.present ? fechaSync.value : this.fechaSync,
    intentosSync: intentosSync ?? this.intentosSync,
    codigoMedidor:
        codigoMedidor.present ? codigoMedidor.value : this.codigoMedidor,
    predioCodigo: predioCodigo.present ? predioCodigo.value : this.predioCodigo,
    notas: notas.present ? notas.value : this.notas,
    nombreAbonado:
        nombreAbonado.present ? nombreAbonado.value : this.nombreAbonado,
    sector: sector.present ? sector.value : this.sector,
    esAbonado: esAbonado ?? this.esAbonado,
    tieneLecturaReal: tieneLecturaReal ?? this.tieneLecturaReal,
    impreso: impreso ?? this.impreso,
    fechaImpresion:
        fechaImpresion.present ? fechaImpresion.value : this.fechaImpresion,
    tipoFacturacion:
        tipoFacturacion.present ? tipoFacturacion.value : this.tipoFacturacion,
    lecturaAnterior:
        lecturaAnterior.present ? lecturaAnterior.value : this.lecturaAnterior,
    consumoAnteriorServidor:
        consumoAnteriorServidor.present
            ? consumoAnteriorServidor.value
            : this.consumoAnteriorServidor,
    lecturaActualServidor:
        lecturaActualServidor.present
            ? lecturaActualServidor.value
            : this.lecturaActualServidor,
    estadoMedidorServidor:
        estadoMedidorServidor.present
            ? estadoMedidorServidor.value
            : this.estadoMedidorServidor,
    estadoMedidor:
        estadoMedidor.present ? estadoMedidor.value : this.estadoMedidor,
    celular: celular.present ? celular.value : this.celular,
    ordenRuta: ordenRuta ?? this.ordenRuta,
  );
  Lectura copyWithCompanion(LecturasCompanion data) {
    return Lectura(
      id: data.id.present ? data.id.value : this.id,
      lectura: data.lectura.present ? data.lectura.value : this.lectura,
      textoCrudo:
          data.textoCrudo.present ? data.textoCrudo.value : this.textoCrudo,
      rutaFoto: data.rutaFoto.present ? data.rutaFoto.value : this.rutaFoto,
      latitud: data.latitud.present ? data.latitud.value : this.latitud,
      longitud: data.longitud.present ? data.longitud.value : this.longitud,
      altitud: data.altitud.present ? data.altitud.value : this.altitud,
      precision: data.precision.present ? data.precision.value : this.precision,
      direccionAproximada:
          data.direccionAproximada.present
              ? data.direccionAproximada.value
              : this.direccionAproximada,
      fechaLectura:
          data.fechaLectura.present
              ? data.fechaLectura.value
              : this.fechaLectura,
      estadoSync:
          data.estadoSync.present ? data.estadoSync.value : this.estadoSync,
      fechaSync: data.fechaSync.present ? data.fechaSync.value : this.fechaSync,
      intentosSync:
          data.intentosSync.present
              ? data.intentosSync.value
              : this.intentosSync,
      codigoMedidor:
          data.codigoMedidor.present
              ? data.codigoMedidor.value
              : this.codigoMedidor,
      predioCodigo:
          data.predioCodigo.present
              ? data.predioCodigo.value
              : this.predioCodigo,
      notas: data.notas.present ? data.notas.value : this.notas,
      nombreAbonado:
          data.nombreAbonado.present
              ? data.nombreAbonado.value
              : this.nombreAbonado,
      sector: data.sector.present ? data.sector.value : this.sector,
      esAbonado: data.esAbonado.present ? data.esAbonado.value : this.esAbonado,
      tieneLecturaReal:
          data.tieneLecturaReal.present
              ? data.tieneLecturaReal.value
              : this.tieneLecturaReal,
      impreso: data.impreso.present ? data.impreso.value : this.impreso,
      fechaImpresion:
          data.fechaImpresion.present
              ? data.fechaImpresion.value
              : this.fechaImpresion,
      tipoFacturacion:
          data.tipoFacturacion.present
              ? data.tipoFacturacion.value
              : this.tipoFacturacion,
      lecturaAnterior:
          data.lecturaAnterior.present
              ? data.lecturaAnterior.value
              : this.lecturaAnterior,
      consumoAnteriorServidor:
          data.consumoAnteriorServidor.present
              ? data.consumoAnteriorServidor.value
              : this.consumoAnteriorServidor,
      lecturaActualServidor:
          data.lecturaActualServidor.present
              ? data.lecturaActualServidor.value
              : this.lecturaActualServidor,
      estadoMedidorServidor:
          data.estadoMedidorServidor.present
              ? data.estadoMedidorServidor.value
              : this.estadoMedidorServidor,
      estadoMedidor:
          data.estadoMedidor.present
              ? data.estadoMedidor.value
              : this.estadoMedidor,
      celular: data.celular.present ? data.celular.value : this.celular,
      ordenRuta: data.ordenRuta.present ? data.ordenRuta.value : this.ordenRuta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lectura(')
          ..write('id: $id, ')
          ..write('lectura: $lectura, ')
          ..write('textoCrudo: $textoCrudo, ')
          ..write('rutaFoto: $rutaFoto, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('altitud: $altitud, ')
          ..write('precision: $precision, ')
          ..write('direccionAproximada: $direccionAproximada, ')
          ..write('fechaLectura: $fechaLectura, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('fechaSync: $fechaSync, ')
          ..write('intentosSync: $intentosSync, ')
          ..write('codigoMedidor: $codigoMedidor, ')
          ..write('predioCodigo: $predioCodigo, ')
          ..write('notas: $notas, ')
          ..write('nombreAbonado: $nombreAbonado, ')
          ..write('sector: $sector, ')
          ..write('esAbonado: $esAbonado, ')
          ..write('tieneLecturaReal: $tieneLecturaReal, ')
          ..write('impreso: $impreso, ')
          ..write('fechaImpresion: $fechaImpresion, ')
          ..write('tipoFacturacion: $tipoFacturacion, ')
          ..write('lecturaAnterior: $lecturaAnterior, ')
          ..write('consumoAnteriorServidor: $consumoAnteriorServidor, ')
          ..write('lecturaActualServidor: $lecturaActualServidor, ')
          ..write('estadoMedidorServidor: $estadoMedidorServidor, ')
          ..write('estadoMedidor: $estadoMedidor, ')
          ..write('celular: $celular, ')
          ..write('ordenRuta: $ordenRuta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    lectura,
    textoCrudo,
    rutaFoto,
    latitud,
    longitud,
    altitud,
    precision,
    direccionAproximada,
    fechaLectura,
    estadoSync,
    fechaSync,
    intentosSync,
    codigoMedidor,
    predioCodigo,
    notas,
    nombreAbonado,
    sector,
    esAbonado,
    tieneLecturaReal,
    impreso,
    fechaImpresion,
    tipoFacturacion,
    lecturaAnterior,
    consumoAnteriorServidor,
    lecturaActualServidor,
    estadoMedidorServidor,
    estadoMedidor,
    celular,
    ordenRuta,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lectura &&
          other.id == this.id &&
          other.lectura == this.lectura &&
          other.textoCrudo == this.textoCrudo &&
          other.rutaFoto == this.rutaFoto &&
          other.latitud == this.latitud &&
          other.longitud == this.longitud &&
          other.altitud == this.altitud &&
          other.precision == this.precision &&
          other.direccionAproximada == this.direccionAproximada &&
          other.fechaLectura == this.fechaLectura &&
          other.estadoSync == this.estadoSync &&
          other.fechaSync == this.fechaSync &&
          other.intentosSync == this.intentosSync &&
          other.codigoMedidor == this.codigoMedidor &&
          other.predioCodigo == this.predioCodigo &&
          other.notas == this.notas &&
          other.nombreAbonado == this.nombreAbonado &&
          other.sector == this.sector &&
          other.esAbonado == this.esAbonado &&
          other.tieneLecturaReal == this.tieneLecturaReal &&
          other.impreso == this.impreso &&
          other.fechaImpresion == this.fechaImpresion &&
          other.tipoFacturacion == this.tipoFacturacion &&
          other.lecturaAnterior == this.lecturaAnterior &&
          other.consumoAnteriorServidor == this.consumoAnteriorServidor &&
          other.lecturaActualServidor == this.lecturaActualServidor &&
          other.estadoMedidorServidor == this.estadoMedidorServidor &&
          other.estadoMedidor == this.estadoMedidor &&
          other.celular == this.celular &&
          other.ordenRuta == this.ordenRuta);
}

class LecturasCompanion extends UpdateCompanion<Lectura> {
  final Value<String> id;
  final Value<int> lectura;
  final Value<String> textoCrudo;
  final Value<String> rutaFoto;
  final Value<double> latitud;
  final Value<double> longitud;
  final Value<double?> altitud;
  final Value<double?> precision;
  final Value<String?> direccionAproximada;
  final Value<DateTime> fechaLectura;
  final Value<String> estadoSync;
  final Value<DateTime?> fechaSync;
  final Value<int> intentosSync;
  final Value<String?> codigoMedidor;
  final Value<String?> predioCodigo;
  final Value<String?> notas;
  final Value<String?> nombreAbonado;
  final Value<String?> sector;
  final Value<bool> esAbonado;
  final Value<bool> tieneLecturaReal;
  final Value<bool> impreso;
  final Value<DateTime?> fechaImpresion;
  final Value<int?> tipoFacturacion;
  final Value<int?> lecturaAnterior;
  final Value<int?> consumoAnteriorServidor;
  final Value<int?> lecturaActualServidor;
  final Value<String?> estadoMedidorServidor;
  final Value<String?> estadoMedidor;
  final Value<String?> celular;
  final Value<int> ordenRuta;
  final Value<int> rowid;
  const LecturasCompanion({
    this.id = const Value.absent(),
    this.lectura = const Value.absent(),
    this.textoCrudo = const Value.absent(),
    this.rutaFoto = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.altitud = const Value.absent(),
    this.precision = const Value.absent(),
    this.direccionAproximada = const Value.absent(),
    this.fechaLectura = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.fechaSync = const Value.absent(),
    this.intentosSync = const Value.absent(),
    this.codigoMedidor = const Value.absent(),
    this.predioCodigo = const Value.absent(),
    this.notas = const Value.absent(),
    this.nombreAbonado = const Value.absent(),
    this.sector = const Value.absent(),
    this.esAbonado = const Value.absent(),
    this.tieneLecturaReal = const Value.absent(),
    this.impreso = const Value.absent(),
    this.fechaImpresion = const Value.absent(),
    this.tipoFacturacion = const Value.absent(),
    this.lecturaAnterior = const Value.absent(),
    this.consumoAnteriorServidor = const Value.absent(),
    this.lecturaActualServidor = const Value.absent(),
    this.estadoMedidorServidor = const Value.absent(),
    this.estadoMedidor = const Value.absent(),
    this.celular = const Value.absent(),
    this.ordenRuta = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LecturasCompanion.insert({
    required String id,
    required int lectura,
    required String textoCrudo,
    required String rutaFoto,
    required double latitud,
    required double longitud,
    this.altitud = const Value.absent(),
    this.precision = const Value.absent(),
    this.direccionAproximada = const Value.absent(),
    required DateTime fechaLectura,
    this.estadoSync = const Value.absent(),
    this.fechaSync = const Value.absent(),
    this.intentosSync = const Value.absent(),
    this.codigoMedidor = const Value.absent(),
    this.predioCodigo = const Value.absent(),
    this.notas = const Value.absent(),
    this.nombreAbonado = const Value.absent(),
    this.sector = const Value.absent(),
    this.esAbonado = const Value.absent(),
    this.tieneLecturaReal = const Value.absent(),
    this.impreso = const Value.absent(),
    this.fechaImpresion = const Value.absent(),
    this.tipoFacturacion = const Value.absent(),
    this.lecturaAnterior = const Value.absent(),
    this.consumoAnteriorServidor = const Value.absent(),
    this.lecturaActualServidor = const Value.absent(),
    this.estadoMedidorServidor = const Value.absent(),
    this.estadoMedidor = const Value.absent(),
    this.celular = const Value.absent(),
    this.ordenRuta = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lectura = Value(lectura),
       textoCrudo = Value(textoCrudo),
       rutaFoto = Value(rutaFoto),
       latitud = Value(latitud),
       longitud = Value(longitud),
       fechaLectura = Value(fechaLectura);
  static Insertable<Lectura> custom({
    Expression<String>? id,
    Expression<int>? lectura,
    Expression<String>? textoCrudo,
    Expression<String>? rutaFoto,
    Expression<double>? latitud,
    Expression<double>? longitud,
    Expression<double>? altitud,
    Expression<double>? precision,
    Expression<String>? direccionAproximada,
    Expression<DateTime>? fechaLectura,
    Expression<String>? estadoSync,
    Expression<DateTime>? fechaSync,
    Expression<int>? intentosSync,
    Expression<String>? codigoMedidor,
    Expression<String>? predioCodigo,
    Expression<String>? notas,
    Expression<String>? nombreAbonado,
    Expression<String>? sector,
    Expression<bool>? esAbonado,
    Expression<bool>? tieneLecturaReal,
    Expression<bool>? impreso,
    Expression<DateTime>? fechaImpresion,
    Expression<int>? tipoFacturacion,
    Expression<int>? lecturaAnterior,
    Expression<int>? consumoAnteriorServidor,
    Expression<int>? lecturaActualServidor,
    Expression<String>? estadoMedidorServidor,
    Expression<String>? estadoMedidor,
    Expression<String>? celular,
    Expression<int>? ordenRuta,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lectura != null) 'lectura': lectura,
      if (textoCrudo != null) 'texto_crudo': textoCrudo,
      if (rutaFoto != null) 'ruta_foto': rutaFoto,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (altitud != null) 'altitud': altitud,
      if (precision != null) 'precision': precision,
      if (direccionAproximada != null)
        'direccion_aproximada': direccionAproximada,
      if (fechaLectura != null) 'fecha_lectura': fechaLectura,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (fechaSync != null) 'fecha_sync': fechaSync,
      if (intentosSync != null) 'intentos_sync': intentosSync,
      if (codigoMedidor != null) 'codigo_medidor': codigoMedidor,
      if (predioCodigo != null) 'predio_codigo': predioCodigo,
      if (notas != null) 'notas': notas,
      if (nombreAbonado != null) 'nombre_abonado': nombreAbonado,
      if (sector != null) 'sector': sector,
      if (esAbonado != null) 'es_abonado': esAbonado,
      if (tieneLecturaReal != null) 'tiene_lectura_real': tieneLecturaReal,
      if (impreso != null) 'impreso': impreso,
      if (fechaImpresion != null) 'fecha_impresion': fechaImpresion,
      if (tipoFacturacion != null) 'tipo_facturacion': tipoFacturacion,
      if (lecturaAnterior != null) 'lectura_anterior': lecturaAnterior,
      if (consumoAnteriorServidor != null)
        'consumo_anterior_servidor': consumoAnteriorServidor,
      if (lecturaActualServidor != null)
        'lectura_actual_servidor': lecturaActualServidor,
      if (estadoMedidorServidor != null)
        'estado_medidor_servidor': estadoMedidorServidor,
      if (estadoMedidor != null) 'estado_medidor': estadoMedidor,
      if (celular != null) 'celular': celular,
      if (ordenRuta != null) 'orden_ruta': ordenRuta,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LecturasCompanion copyWith({
    Value<String>? id,
    Value<int>? lectura,
    Value<String>? textoCrudo,
    Value<String>? rutaFoto,
    Value<double>? latitud,
    Value<double>? longitud,
    Value<double?>? altitud,
    Value<double?>? precision,
    Value<String?>? direccionAproximada,
    Value<DateTime>? fechaLectura,
    Value<String>? estadoSync,
    Value<DateTime?>? fechaSync,
    Value<int>? intentosSync,
    Value<String?>? codigoMedidor,
    Value<String?>? predioCodigo,
    Value<String?>? notas,
    Value<String?>? nombreAbonado,
    Value<String?>? sector,
    Value<bool>? esAbonado,
    Value<bool>? tieneLecturaReal,
    Value<bool>? impreso,
    Value<DateTime?>? fechaImpresion,
    Value<int?>? tipoFacturacion,
    Value<int?>? lecturaAnterior,
    Value<int?>? consumoAnteriorServidor,
    Value<int?>? lecturaActualServidor,
    Value<String?>? estadoMedidorServidor,
    Value<String?>? estadoMedidor,
    Value<String?>? celular,
    Value<int>? ordenRuta,
    Value<int>? rowid,
  }) {
    return LecturasCompanion(
      id: id ?? this.id,
      lectura: lectura ?? this.lectura,
      textoCrudo: textoCrudo ?? this.textoCrudo,
      rutaFoto: rutaFoto ?? this.rutaFoto,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      altitud: altitud ?? this.altitud,
      precision: precision ?? this.precision,
      direccionAproximada: direccionAproximada ?? this.direccionAproximada,
      fechaLectura: fechaLectura ?? this.fechaLectura,
      estadoSync: estadoSync ?? this.estadoSync,
      fechaSync: fechaSync ?? this.fechaSync,
      intentosSync: intentosSync ?? this.intentosSync,
      codigoMedidor: codigoMedidor ?? this.codigoMedidor,
      predioCodigo: predioCodigo ?? this.predioCodigo,
      notas: notas ?? this.notas,
      nombreAbonado: nombreAbonado ?? this.nombreAbonado,
      sector: sector ?? this.sector,
      esAbonado: esAbonado ?? this.esAbonado,
      tieneLecturaReal: tieneLecturaReal ?? this.tieneLecturaReal,
      impreso: impreso ?? this.impreso,
      fechaImpresion: fechaImpresion ?? this.fechaImpresion,
      tipoFacturacion: tipoFacturacion ?? this.tipoFacturacion,
      lecturaAnterior: lecturaAnterior ?? this.lecturaAnterior,
      consumoAnteriorServidor:
          consumoAnteriorServidor ?? this.consumoAnteriorServidor,
      lecturaActualServidor:
          lecturaActualServidor ?? this.lecturaActualServidor,
      estadoMedidorServidor:
          estadoMedidorServidor ?? this.estadoMedidorServidor,
      estadoMedidor: estadoMedidor ?? this.estadoMedidor,
      celular: celular ?? this.celular,
      ordenRuta: ordenRuta ?? this.ordenRuta,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lectura.present) {
      map['lectura'] = Variable<int>(lectura.value);
    }
    if (textoCrudo.present) {
      map['texto_crudo'] = Variable<String>(textoCrudo.value);
    }
    if (rutaFoto.present) {
      map['ruta_foto'] = Variable<String>(rutaFoto.value);
    }
    if (latitud.present) {
      map['latitud'] = Variable<double>(latitud.value);
    }
    if (longitud.present) {
      map['longitud'] = Variable<double>(longitud.value);
    }
    if (altitud.present) {
      map['altitud'] = Variable<double>(altitud.value);
    }
    if (precision.present) {
      map['precision'] = Variable<double>(precision.value);
    }
    if (direccionAproximada.present) {
      map['direccion_aproximada'] = Variable<String>(direccionAproximada.value);
    }
    if (fechaLectura.present) {
      map['fecha_lectura'] = Variable<DateTime>(fechaLectura.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (fechaSync.present) {
      map['fecha_sync'] = Variable<DateTime>(fechaSync.value);
    }
    if (intentosSync.present) {
      map['intentos_sync'] = Variable<int>(intentosSync.value);
    }
    if (codigoMedidor.present) {
      map['codigo_medidor'] = Variable<String>(codigoMedidor.value);
    }
    if (predioCodigo.present) {
      map['predio_codigo'] = Variable<String>(predioCodigo.value);
    }
    if (notas.present) {
      map['notas'] = Variable<String>(notas.value);
    }
    if (nombreAbonado.present) {
      map['nombre_abonado'] = Variable<String>(nombreAbonado.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
    }
    if (esAbonado.present) {
      map['es_abonado'] = Variable<bool>(esAbonado.value);
    }
    if (tieneLecturaReal.present) {
      map['tiene_lectura_real'] = Variable<bool>(tieneLecturaReal.value);
    }
    if (impreso.present) {
      map['impreso'] = Variable<bool>(impreso.value);
    }
    if (fechaImpresion.present) {
      map['fecha_impresion'] = Variable<DateTime>(fechaImpresion.value);
    }
    if (tipoFacturacion.present) {
      map['tipo_facturacion'] = Variable<int>(tipoFacturacion.value);
    }
    if (lecturaAnterior.present) {
      map['lectura_anterior'] = Variable<int>(lecturaAnterior.value);
    }
    if (consumoAnteriorServidor.present) {
      map['consumo_anterior_servidor'] = Variable<int>(
        consumoAnteriorServidor.value,
      );
    }
    if (lecturaActualServidor.present) {
      map['lectura_actual_servidor'] = Variable<int>(
        lecturaActualServidor.value,
      );
    }
    if (estadoMedidorServidor.present) {
      map['estado_medidor_servidor'] = Variable<String>(
        estadoMedidorServidor.value,
      );
    }
    if (estadoMedidor.present) {
      map['estado_medidor'] = Variable<String>(estadoMedidor.value);
    }
    if (celular.present) {
      map['celular'] = Variable<String>(celular.value);
    }
    if (ordenRuta.present) {
      map['orden_ruta'] = Variable<int>(ordenRuta.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LecturasCompanion(')
          ..write('id: $id, ')
          ..write('lectura: $lectura, ')
          ..write('textoCrudo: $textoCrudo, ')
          ..write('rutaFoto: $rutaFoto, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('altitud: $altitud, ')
          ..write('precision: $precision, ')
          ..write('direccionAproximada: $direccionAproximada, ')
          ..write('fechaLectura: $fechaLectura, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('fechaSync: $fechaSync, ')
          ..write('intentosSync: $intentosSync, ')
          ..write('codigoMedidor: $codigoMedidor, ')
          ..write('predioCodigo: $predioCodigo, ')
          ..write('notas: $notas, ')
          ..write('nombreAbonado: $nombreAbonado, ')
          ..write('sector: $sector, ')
          ..write('esAbonado: $esAbonado, ')
          ..write('tieneLecturaReal: $tieneLecturaReal, ')
          ..write('impreso: $impreso, ')
          ..write('fechaImpresion: $fechaImpresion, ')
          ..write('tipoFacturacion: $tipoFacturacion, ')
          ..write('lecturaAnterior: $lecturaAnterior, ')
          ..write('consumoAnteriorServidor: $consumoAnteriorServidor, ')
          ..write('lecturaActualServidor: $lecturaActualServidor, ')
          ..write('estadoMedidorServidor: $estadoMedidorServidor, ')
          ..write('estadoMedidor: $estadoMedidor, ')
          ..write('celular: $celular, ')
          ..write('ordenRuta: $ordenRuta, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RegistrosGpsTable extends RegistrosGps
    with TableInfo<$RegistrosGpsTable, RegistrosGp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RegistrosGpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _latitudMeta = const VerificationMeta(
    'latitud',
  );
  @override
  late final GeneratedColumn<double> latitud = GeneratedColumn<double>(
    'latitud',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudMeta = const VerificationMeta(
    'longitud',
  );
  @override
  late final GeneratedColumn<double> longitud = GeneratedColumn<double>(
    'longitud',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudMeta = const VerificationMeta(
    'altitud',
  );
  @override
  late final GeneratedColumn<double> altitud = GeneratedColumn<double>(
    'altitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _precisionMeta = const VerificationMeta(
    'precision',
  );
  @override
  late final GeneratedColumn<double> precision = GeneratedColumn<double>(
    'precision',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _velocidadMeta = const VerificationMeta(
    'velocidad',
  );
  @override
  late final GeneratedColumn<double> velocidad = GeneratedColumn<double>(
    'velocidad',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lecturaIdMeta = const VerificationMeta(
    'lecturaId',
  );
  @override
  late final GeneratedColumn<String> lecturaId = GeneratedColumn<String>(
    'lectura_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    latitud,
    longitud,
    altitud,
    precision,
    velocidad,
    timestamp,
    lecturaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'registros_gps';
  @override
  VerificationContext validateIntegrity(
    Insertable<RegistrosGp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('latitud')) {
      context.handle(
        _latitudMeta,
        latitud.isAcceptableOrUnknown(data['latitud']!, _latitudMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudMeta);
    }
    if (data.containsKey('longitud')) {
      context.handle(
        _longitudMeta,
        longitud.isAcceptableOrUnknown(data['longitud']!, _longitudMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudMeta);
    }
    if (data.containsKey('altitud')) {
      context.handle(
        _altitudMeta,
        altitud.isAcceptableOrUnknown(data['altitud']!, _altitudMeta),
      );
    }
    if (data.containsKey('precision')) {
      context.handle(
        _precisionMeta,
        precision.isAcceptableOrUnknown(data['precision']!, _precisionMeta),
      );
    } else if (isInserting) {
      context.missing(_precisionMeta);
    }
    if (data.containsKey('velocidad')) {
      context.handle(
        _velocidadMeta,
        velocidad.isAcceptableOrUnknown(data['velocidad']!, _velocidadMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('lectura_id')) {
      context.handle(
        _lecturaIdMeta,
        lecturaId.isAcceptableOrUnknown(data['lectura_id']!, _lecturaIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RegistrosGp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RegistrosGp(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      latitud:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}latitud'],
          )!,
      longitud:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}longitud'],
          )!,
      altitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitud'],
      ),
      precision:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}precision'],
          )!,
      velocidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}velocidad'],
      ),
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
      lecturaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lectura_id'],
      ),
    );
  }

  @override
  $RegistrosGpsTable createAlias(String alias) {
    return $RegistrosGpsTable(attachedDatabase, alias);
  }
}

class RegistrosGp extends DataClass implements Insertable<RegistrosGp> {
  final int id;
  final double latitud;
  final double longitud;
  final double? altitud;
  final double precision;
  final double? velocidad;
  final DateTime timestamp;
  final String? lecturaId;
  const RegistrosGp({
    required this.id,
    required this.latitud,
    required this.longitud,
    this.altitud,
    required this.precision,
    this.velocidad,
    required this.timestamp,
    this.lecturaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['latitud'] = Variable<double>(latitud);
    map['longitud'] = Variable<double>(longitud);
    if (!nullToAbsent || altitud != null) {
      map['altitud'] = Variable<double>(altitud);
    }
    map['precision'] = Variable<double>(precision);
    if (!nullToAbsent || velocidad != null) {
      map['velocidad'] = Variable<double>(velocidad);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || lecturaId != null) {
      map['lectura_id'] = Variable<String>(lecturaId);
    }
    return map;
  }

  RegistrosGpsCompanion toCompanion(bool nullToAbsent) {
    return RegistrosGpsCompanion(
      id: Value(id),
      latitud: Value(latitud),
      longitud: Value(longitud),
      altitud:
          altitud == null && nullToAbsent
              ? const Value.absent()
              : Value(altitud),
      precision: Value(precision),
      velocidad:
          velocidad == null && nullToAbsent
              ? const Value.absent()
              : Value(velocidad),
      timestamp: Value(timestamp),
      lecturaId:
          lecturaId == null && nullToAbsent
              ? const Value.absent()
              : Value(lecturaId),
    );
  }

  factory RegistrosGp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RegistrosGp(
      id: serializer.fromJson<int>(json['id']),
      latitud: serializer.fromJson<double>(json['latitud']),
      longitud: serializer.fromJson<double>(json['longitud']),
      altitud: serializer.fromJson<double?>(json['altitud']),
      precision: serializer.fromJson<double>(json['precision']),
      velocidad: serializer.fromJson<double?>(json['velocidad']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      lecturaId: serializer.fromJson<String?>(json['lecturaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'latitud': serializer.toJson<double>(latitud),
      'longitud': serializer.toJson<double>(longitud),
      'altitud': serializer.toJson<double?>(altitud),
      'precision': serializer.toJson<double>(precision),
      'velocidad': serializer.toJson<double?>(velocidad),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'lecturaId': serializer.toJson<String?>(lecturaId),
    };
  }

  RegistrosGp copyWith({
    int? id,
    double? latitud,
    double? longitud,
    Value<double?> altitud = const Value.absent(),
    double? precision,
    Value<double?> velocidad = const Value.absent(),
    DateTime? timestamp,
    Value<String?> lecturaId = const Value.absent(),
  }) => RegistrosGp(
    id: id ?? this.id,
    latitud: latitud ?? this.latitud,
    longitud: longitud ?? this.longitud,
    altitud: altitud.present ? altitud.value : this.altitud,
    precision: precision ?? this.precision,
    velocidad: velocidad.present ? velocidad.value : this.velocidad,
    timestamp: timestamp ?? this.timestamp,
    lecturaId: lecturaId.present ? lecturaId.value : this.lecturaId,
  );
  RegistrosGp copyWithCompanion(RegistrosGpsCompanion data) {
    return RegistrosGp(
      id: data.id.present ? data.id.value : this.id,
      latitud: data.latitud.present ? data.latitud.value : this.latitud,
      longitud: data.longitud.present ? data.longitud.value : this.longitud,
      altitud: data.altitud.present ? data.altitud.value : this.altitud,
      precision: data.precision.present ? data.precision.value : this.precision,
      velocidad: data.velocidad.present ? data.velocidad.value : this.velocidad,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      lecturaId: data.lecturaId.present ? data.lecturaId.value : this.lecturaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosGp(')
          ..write('id: $id, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('altitud: $altitud, ')
          ..write('precision: $precision, ')
          ..write('velocidad: $velocidad, ')
          ..write('timestamp: $timestamp, ')
          ..write('lecturaId: $lecturaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    latitud,
    longitud,
    altitud,
    precision,
    velocidad,
    timestamp,
    lecturaId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RegistrosGp &&
          other.id == this.id &&
          other.latitud == this.latitud &&
          other.longitud == this.longitud &&
          other.altitud == this.altitud &&
          other.precision == this.precision &&
          other.velocidad == this.velocidad &&
          other.timestamp == this.timestamp &&
          other.lecturaId == this.lecturaId);
}

class RegistrosGpsCompanion extends UpdateCompanion<RegistrosGp> {
  final Value<int> id;
  final Value<double> latitud;
  final Value<double> longitud;
  final Value<double?> altitud;
  final Value<double> precision;
  final Value<double?> velocidad;
  final Value<DateTime> timestamp;
  final Value<String?> lecturaId;
  const RegistrosGpsCompanion({
    this.id = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.altitud = const Value.absent(),
    this.precision = const Value.absent(),
    this.velocidad = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.lecturaId = const Value.absent(),
  });
  RegistrosGpsCompanion.insert({
    this.id = const Value.absent(),
    required double latitud,
    required double longitud,
    this.altitud = const Value.absent(),
    required double precision,
    this.velocidad = const Value.absent(),
    required DateTime timestamp,
    this.lecturaId = const Value.absent(),
  }) : latitud = Value(latitud),
       longitud = Value(longitud),
       precision = Value(precision),
       timestamp = Value(timestamp);
  static Insertable<RegistrosGp> custom({
    Expression<int>? id,
    Expression<double>? latitud,
    Expression<double>? longitud,
    Expression<double>? altitud,
    Expression<double>? precision,
    Expression<double>? velocidad,
    Expression<DateTime>? timestamp,
    Expression<String>? lecturaId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (altitud != null) 'altitud': altitud,
      if (precision != null) 'precision': precision,
      if (velocidad != null) 'velocidad': velocidad,
      if (timestamp != null) 'timestamp': timestamp,
      if (lecturaId != null) 'lectura_id': lecturaId,
    });
  }

  RegistrosGpsCompanion copyWith({
    Value<int>? id,
    Value<double>? latitud,
    Value<double>? longitud,
    Value<double?>? altitud,
    Value<double>? precision,
    Value<double?>? velocidad,
    Value<DateTime>? timestamp,
    Value<String?>? lecturaId,
  }) {
    return RegistrosGpsCompanion(
      id: id ?? this.id,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      altitud: altitud ?? this.altitud,
      precision: precision ?? this.precision,
      velocidad: velocidad ?? this.velocidad,
      timestamp: timestamp ?? this.timestamp,
      lecturaId: lecturaId ?? this.lecturaId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (latitud.present) {
      map['latitud'] = Variable<double>(latitud.value);
    }
    if (longitud.present) {
      map['longitud'] = Variable<double>(longitud.value);
    }
    if (altitud.present) {
      map['altitud'] = Variable<double>(altitud.value);
    }
    if (precision.present) {
      map['precision'] = Variable<double>(precision.value);
    }
    if (velocidad.present) {
      map['velocidad'] = Variable<double>(velocidad.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (lecturaId.present) {
      map['lectura_id'] = Variable<String>(lecturaId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RegistrosGpsCompanion(')
          ..write('id: $id, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('altitud: $altitud, ')
          ..write('precision: $precision, ')
          ..write('velocidad: $velocidad, ')
          ..write('timestamp: $timestamp, ')
          ..write('lecturaId: $lecturaId')
          ..write(')'))
        .toString();
  }
}

class $NovedadesLocalesTable extends NovedadesLocales
    with TableInfo<$NovedadesLocalesTable, NovedadesLocale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NovedadesLocalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _predioIdMeta = const VerificationMeta(
    'predioId',
  );
  @override
  late final GeneratedColumn<int> predioId = GeneratedColumn<int>(
    'predio_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conceptoMeta = const VerificationMeta(
    'concepto',
  );
  @override
  late final GeneratedColumn<String> concepto = GeneratedColumn<String>(
    'concepto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorCuotaMeta = const VerificationMeta(
    'valorCuota',
  );
  @override
  late final GeneratedColumn<int> valorCuota = GeneratedColumn<int>(
    'valor_cuota',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cuotasPendientesMeta = const VerificationMeta(
    'cuotasPendientes',
  );
  @override
  late final GeneratedColumn<int> cuotasPendientes = GeneratedColumn<int>(
    'cuotas_pendientes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalPendienteMeta = const VerificationMeta(
    'totalPendiente',
  );
  @override
  late final GeneratedColumn<int> totalPendiente = GeneratedColumn<int>(
    'total_pendiente',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    predioId,
    concepto,
    valorCuota,
    cuotasPendientes,
    totalPendiente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'novedades_locales';
  @override
  VerificationContext validateIntegrity(
    Insertable<NovedadesLocale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('predio_id')) {
      context.handle(
        _predioIdMeta,
        predioId.isAcceptableOrUnknown(data['predio_id']!, _predioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_predioIdMeta);
    }
    if (data.containsKey('concepto')) {
      context.handle(
        _conceptoMeta,
        concepto.isAcceptableOrUnknown(data['concepto']!, _conceptoMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptoMeta);
    }
    if (data.containsKey('valor_cuota')) {
      context.handle(
        _valorCuotaMeta,
        valorCuota.isAcceptableOrUnknown(data['valor_cuota']!, _valorCuotaMeta),
      );
    } else if (isInserting) {
      context.missing(_valorCuotaMeta);
    }
    if (data.containsKey('cuotas_pendientes')) {
      context.handle(
        _cuotasPendientesMeta,
        cuotasPendientes.isAcceptableOrUnknown(
          data['cuotas_pendientes']!,
          _cuotasPendientesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cuotasPendientesMeta);
    }
    if (data.containsKey('total_pendiente')) {
      context.handle(
        _totalPendienteMeta,
        totalPendiente.isAcceptableOrUnknown(
          data['total_pendiente']!,
          _totalPendienteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalPendienteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NovedadesLocale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NovedadesLocale(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      predioId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}predio_id'],
          )!,
      concepto:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}concepto'],
          )!,
      valorCuota:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}valor_cuota'],
          )!,
      cuotasPendientes:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}cuotas_pendientes'],
          )!,
      totalPendiente:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}total_pendiente'],
          )!,
    );
  }

  @override
  $NovedadesLocalesTable createAlias(String alias) {
    return $NovedadesLocalesTable(attachedDatabase, alias);
  }
}

class NovedadesLocale extends DataClass implements Insertable<NovedadesLocale> {
  final int id;
  final int predioId;
  final String concepto;
  final int valorCuota;
  final int cuotasPendientes;
  final int totalPendiente;
  const NovedadesLocale({
    required this.id,
    required this.predioId,
    required this.concepto,
    required this.valorCuota,
    required this.cuotasPendientes,
    required this.totalPendiente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['predio_id'] = Variable<int>(predioId);
    map['concepto'] = Variable<String>(concepto);
    map['valor_cuota'] = Variable<int>(valorCuota);
    map['cuotas_pendientes'] = Variable<int>(cuotasPendientes);
    map['total_pendiente'] = Variable<int>(totalPendiente);
    return map;
  }

  NovedadesLocalesCompanion toCompanion(bool nullToAbsent) {
    return NovedadesLocalesCompanion(
      id: Value(id),
      predioId: Value(predioId),
      concepto: Value(concepto),
      valorCuota: Value(valorCuota),
      cuotasPendientes: Value(cuotasPendientes),
      totalPendiente: Value(totalPendiente),
    );
  }

  factory NovedadesLocale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NovedadesLocale(
      id: serializer.fromJson<int>(json['id']),
      predioId: serializer.fromJson<int>(json['predioId']),
      concepto: serializer.fromJson<String>(json['concepto']),
      valorCuota: serializer.fromJson<int>(json['valorCuota']),
      cuotasPendientes: serializer.fromJson<int>(json['cuotasPendientes']),
      totalPendiente: serializer.fromJson<int>(json['totalPendiente']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'predioId': serializer.toJson<int>(predioId),
      'concepto': serializer.toJson<String>(concepto),
      'valorCuota': serializer.toJson<int>(valorCuota),
      'cuotasPendientes': serializer.toJson<int>(cuotasPendientes),
      'totalPendiente': serializer.toJson<int>(totalPendiente),
    };
  }

  NovedadesLocale copyWith({
    int? id,
    int? predioId,
    String? concepto,
    int? valorCuota,
    int? cuotasPendientes,
    int? totalPendiente,
  }) => NovedadesLocale(
    id: id ?? this.id,
    predioId: predioId ?? this.predioId,
    concepto: concepto ?? this.concepto,
    valorCuota: valorCuota ?? this.valorCuota,
    cuotasPendientes: cuotasPendientes ?? this.cuotasPendientes,
    totalPendiente: totalPendiente ?? this.totalPendiente,
  );
  NovedadesLocale copyWithCompanion(NovedadesLocalesCompanion data) {
    return NovedadesLocale(
      id: data.id.present ? data.id.value : this.id,
      predioId: data.predioId.present ? data.predioId.value : this.predioId,
      concepto: data.concepto.present ? data.concepto.value : this.concepto,
      valorCuota:
          data.valorCuota.present ? data.valorCuota.value : this.valorCuota,
      cuotasPendientes:
          data.cuotasPendientes.present
              ? data.cuotasPendientes.value
              : this.cuotasPendientes,
      totalPendiente:
          data.totalPendiente.present
              ? data.totalPendiente.value
              : this.totalPendiente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NovedadesLocale(')
          ..write('id: $id, ')
          ..write('predioId: $predioId, ')
          ..write('concepto: $concepto, ')
          ..write('valorCuota: $valorCuota, ')
          ..write('cuotasPendientes: $cuotasPendientes, ')
          ..write('totalPendiente: $totalPendiente')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    predioId,
    concepto,
    valorCuota,
    cuotasPendientes,
    totalPendiente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NovedadesLocale &&
          other.id == this.id &&
          other.predioId == this.predioId &&
          other.concepto == this.concepto &&
          other.valorCuota == this.valorCuota &&
          other.cuotasPendientes == this.cuotasPendientes &&
          other.totalPendiente == this.totalPendiente);
}

class NovedadesLocalesCompanion extends UpdateCompanion<NovedadesLocale> {
  final Value<int> id;
  final Value<int> predioId;
  final Value<String> concepto;
  final Value<int> valorCuota;
  final Value<int> cuotasPendientes;
  final Value<int> totalPendiente;
  const NovedadesLocalesCompanion({
    this.id = const Value.absent(),
    this.predioId = const Value.absent(),
    this.concepto = const Value.absent(),
    this.valorCuota = const Value.absent(),
    this.cuotasPendientes = const Value.absent(),
    this.totalPendiente = const Value.absent(),
  });
  NovedadesLocalesCompanion.insert({
    this.id = const Value.absent(),
    required int predioId,
    required String concepto,
    required int valorCuota,
    required int cuotasPendientes,
    required int totalPendiente,
  }) : predioId = Value(predioId),
       concepto = Value(concepto),
       valorCuota = Value(valorCuota),
       cuotasPendientes = Value(cuotasPendientes),
       totalPendiente = Value(totalPendiente);
  static Insertable<NovedadesLocale> custom({
    Expression<int>? id,
    Expression<int>? predioId,
    Expression<String>? concepto,
    Expression<int>? valorCuota,
    Expression<int>? cuotasPendientes,
    Expression<int>? totalPendiente,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (predioId != null) 'predio_id': predioId,
      if (concepto != null) 'concepto': concepto,
      if (valorCuota != null) 'valor_cuota': valorCuota,
      if (cuotasPendientes != null) 'cuotas_pendientes': cuotasPendientes,
      if (totalPendiente != null) 'total_pendiente': totalPendiente,
    });
  }

  NovedadesLocalesCompanion copyWith({
    Value<int>? id,
    Value<int>? predioId,
    Value<String>? concepto,
    Value<int>? valorCuota,
    Value<int>? cuotasPendientes,
    Value<int>? totalPendiente,
  }) {
    return NovedadesLocalesCompanion(
      id: id ?? this.id,
      predioId: predioId ?? this.predioId,
      concepto: concepto ?? this.concepto,
      valorCuota: valorCuota ?? this.valorCuota,
      cuotasPendientes: cuotasPendientes ?? this.cuotasPendientes,
      totalPendiente: totalPendiente ?? this.totalPendiente,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (predioId.present) {
      map['predio_id'] = Variable<int>(predioId.value);
    }
    if (concepto.present) {
      map['concepto'] = Variable<String>(concepto.value);
    }
    if (valorCuota.present) {
      map['valor_cuota'] = Variable<int>(valorCuota.value);
    }
    if (cuotasPendientes.present) {
      map['cuotas_pendientes'] = Variable<int>(cuotasPendientes.value);
    }
    if (totalPendiente.present) {
      map['total_pendiente'] = Variable<int>(totalPendiente.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NovedadesLocalesCompanion(')
          ..write('id: $id, ')
          ..write('predioId: $predioId, ')
          ..write('concepto: $concepto, ')
          ..write('valorCuota: $valorCuota, ')
          ..write('cuotasPendientes: $cuotasPendientes, ')
          ..write('totalPendiente: $totalPendiente')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LecturasTable lecturas = $LecturasTable(this);
  late final $RegistrosGpsTable registrosGps = $RegistrosGpsTable(this);
  late final $NovedadesLocalesTable novedadesLocales = $NovedadesLocalesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lecturas,
    registrosGps,
    novedadesLocales,
  ];
}

typedef $$LecturasTableCreateCompanionBuilder =
    LecturasCompanion Function({
      required String id,
      required int lectura,
      required String textoCrudo,
      required String rutaFoto,
      required double latitud,
      required double longitud,
      Value<double?> altitud,
      Value<double?> precision,
      Value<String?> direccionAproximada,
      required DateTime fechaLectura,
      Value<String> estadoSync,
      Value<DateTime?> fechaSync,
      Value<int> intentosSync,
      Value<String?> codigoMedidor,
      Value<String?> predioCodigo,
      Value<String?> notas,
      Value<String?> nombreAbonado,
      Value<String?> sector,
      Value<bool> esAbonado,
      Value<bool> tieneLecturaReal,
      Value<bool> impreso,
      Value<DateTime?> fechaImpresion,
      Value<int?> tipoFacturacion,
      Value<int?> lecturaAnterior,
      Value<int?> consumoAnteriorServidor,
      Value<int?> lecturaActualServidor,
      Value<String?> estadoMedidorServidor,
      Value<String?> estadoMedidor,
      Value<String?> celular,
      Value<int> ordenRuta,
      Value<int> rowid,
    });
typedef $$LecturasTableUpdateCompanionBuilder =
    LecturasCompanion Function({
      Value<String> id,
      Value<int> lectura,
      Value<String> textoCrudo,
      Value<String> rutaFoto,
      Value<double> latitud,
      Value<double> longitud,
      Value<double?> altitud,
      Value<double?> precision,
      Value<String?> direccionAproximada,
      Value<DateTime> fechaLectura,
      Value<String> estadoSync,
      Value<DateTime?> fechaSync,
      Value<int> intentosSync,
      Value<String?> codigoMedidor,
      Value<String?> predioCodigo,
      Value<String?> notas,
      Value<String?> nombreAbonado,
      Value<String?> sector,
      Value<bool> esAbonado,
      Value<bool> tieneLecturaReal,
      Value<bool> impreso,
      Value<DateTime?> fechaImpresion,
      Value<int?> tipoFacturacion,
      Value<int?> lecturaAnterior,
      Value<int?> consumoAnteriorServidor,
      Value<int?> lecturaActualServidor,
      Value<String?> estadoMedidorServidor,
      Value<String?> estadoMedidor,
      Value<String?> celular,
      Value<int> ordenRuta,
      Value<int> rowid,
    });

class $$LecturasTableFilterComposer
    extends Composer<_$AppDatabase, $LecturasTable> {
  $$LecturasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lectura => $composableBuilder(
    column: $table.lectura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textoCrudo => $composableBuilder(
    column: $table.textoCrudo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rutaFoto => $composableBuilder(
    column: $table.rutaFoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitud => $composableBuilder(
    column: $table.altitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precision => $composableBuilder(
    column: $table.precision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get direccionAproximada => $composableBuilder(
    column: $table.direccionAproximada,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaLectura => $composableBuilder(
    column: $table.fechaLectura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaSync => $composableBuilder(
    column: $table.fechaSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intentosSync => $composableBuilder(
    column: $table.intentosSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigoMedidor => $composableBuilder(
    column: $table.codigoMedidor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get predioCodigo => $composableBuilder(
    column: $table.predioCodigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreAbonado => $composableBuilder(
    column: $table.nombreAbonado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esAbonado => $composableBuilder(
    column: $table.esAbonado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get tieneLecturaReal => $composableBuilder(
    column: $table.tieneLecturaReal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get impreso => $composableBuilder(
    column: $table.impreso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fechaImpresion => $composableBuilder(
    column: $table.fechaImpresion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tipoFacturacion => $composableBuilder(
    column: $table.tipoFacturacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lecturaAnterior => $composableBuilder(
    column: $table.lecturaAnterior,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get consumoAnteriorServidor => $composableBuilder(
    column: $table.consumoAnteriorServidor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lecturaActualServidor => $composableBuilder(
    column: $table.lecturaActualServidor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoMedidorServidor => $composableBuilder(
    column: $table.estadoMedidorServidor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoMedidor => $composableBuilder(
    column: $table.estadoMedidor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get celular => $composableBuilder(
    column: $table.celular,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordenRuta => $composableBuilder(
    column: $table.ordenRuta,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LecturasTableOrderingComposer
    extends Composer<_$AppDatabase, $LecturasTable> {
  $$LecturasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lectura => $composableBuilder(
    column: $table.lectura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textoCrudo => $composableBuilder(
    column: $table.textoCrudo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rutaFoto => $composableBuilder(
    column: $table.rutaFoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitud => $composableBuilder(
    column: $table.altitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precision => $composableBuilder(
    column: $table.precision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direccionAproximada => $composableBuilder(
    column: $table.direccionAproximada,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaLectura => $composableBuilder(
    column: $table.fechaLectura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaSync => $composableBuilder(
    column: $table.fechaSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intentosSync => $composableBuilder(
    column: $table.intentosSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigoMedidor => $composableBuilder(
    column: $table.codigoMedidor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predioCodigo => $composableBuilder(
    column: $table.predioCodigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notas => $composableBuilder(
    column: $table.notas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreAbonado => $composableBuilder(
    column: $table.nombreAbonado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esAbonado => $composableBuilder(
    column: $table.esAbonado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get tieneLecturaReal => $composableBuilder(
    column: $table.tieneLecturaReal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get impreso => $composableBuilder(
    column: $table.impreso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fechaImpresion => $composableBuilder(
    column: $table.fechaImpresion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tipoFacturacion => $composableBuilder(
    column: $table.tipoFacturacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lecturaAnterior => $composableBuilder(
    column: $table.lecturaAnterior,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get consumoAnteriorServidor => $composableBuilder(
    column: $table.consumoAnteriorServidor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lecturaActualServidor => $composableBuilder(
    column: $table.lecturaActualServidor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoMedidorServidor => $composableBuilder(
    column: $table.estadoMedidorServidor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoMedidor => $composableBuilder(
    column: $table.estadoMedidor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get celular => $composableBuilder(
    column: $table.celular,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordenRuta => $composableBuilder(
    column: $table.ordenRuta,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LecturasTableAnnotationComposer
    extends Composer<_$AppDatabase, $LecturasTable> {
  $$LecturasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lectura =>
      $composableBuilder(column: $table.lectura, builder: (column) => column);

  GeneratedColumn<String> get textoCrudo => $composableBuilder(
    column: $table.textoCrudo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rutaFoto =>
      $composableBuilder(column: $table.rutaFoto, builder: (column) => column);

  GeneratedColumn<double> get latitud =>
      $composableBuilder(column: $table.latitud, builder: (column) => column);

  GeneratedColumn<double> get longitud =>
      $composableBuilder(column: $table.longitud, builder: (column) => column);

  GeneratedColumn<double> get altitud =>
      $composableBuilder(column: $table.altitud, builder: (column) => column);

  GeneratedColumn<double> get precision =>
      $composableBuilder(column: $table.precision, builder: (column) => column);

  GeneratedColumn<String> get direccionAproximada => $composableBuilder(
    column: $table.direccionAproximada,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaLectura => $composableBuilder(
    column: $table.fechaLectura,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fechaSync =>
      $composableBuilder(column: $table.fechaSync, builder: (column) => column);

  GeneratedColumn<int> get intentosSync => $composableBuilder(
    column: $table.intentosSync,
    builder: (column) => column,
  );

  GeneratedColumn<String> get codigoMedidor => $composableBuilder(
    column: $table.codigoMedidor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get predioCodigo => $composableBuilder(
    column: $table.predioCodigo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notas =>
      $composableBuilder(column: $table.notas, builder: (column) => column);

  GeneratedColumn<String> get nombreAbonado => $composableBuilder(
    column: $table.nombreAbonado,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  GeneratedColumn<bool> get esAbonado =>
      $composableBuilder(column: $table.esAbonado, builder: (column) => column);

  GeneratedColumn<bool> get tieneLecturaReal => $composableBuilder(
    column: $table.tieneLecturaReal,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get impreso =>
      $composableBuilder(column: $table.impreso, builder: (column) => column);

  GeneratedColumn<DateTime> get fechaImpresion => $composableBuilder(
    column: $table.fechaImpresion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tipoFacturacion => $composableBuilder(
    column: $table.tipoFacturacion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lecturaAnterior => $composableBuilder(
    column: $table.lecturaAnterior,
    builder: (column) => column,
  );

  GeneratedColumn<int> get consumoAnteriorServidor => $composableBuilder(
    column: $table.consumoAnteriorServidor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lecturaActualServidor => $composableBuilder(
    column: $table.lecturaActualServidor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoMedidorServidor => $composableBuilder(
    column: $table.estadoMedidorServidor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoMedidor => $composableBuilder(
    column: $table.estadoMedidor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get celular =>
      $composableBuilder(column: $table.celular, builder: (column) => column);

  GeneratedColumn<int> get ordenRuta =>
      $composableBuilder(column: $table.ordenRuta, builder: (column) => column);
}

class $$LecturasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LecturasTable,
          Lectura,
          $$LecturasTableFilterComposer,
          $$LecturasTableOrderingComposer,
          $$LecturasTableAnnotationComposer,
          $$LecturasTableCreateCompanionBuilder,
          $$LecturasTableUpdateCompanionBuilder,
          (Lectura, BaseReferences<_$AppDatabase, $LecturasTable, Lectura>),
          Lectura,
          PrefetchHooks Function()
        > {
  $$LecturasTableTableManager(_$AppDatabase db, $LecturasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$LecturasTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$LecturasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$LecturasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> lectura = const Value.absent(),
                Value<String> textoCrudo = const Value.absent(),
                Value<String> rutaFoto = const Value.absent(),
                Value<double> latitud = const Value.absent(),
                Value<double> longitud = const Value.absent(),
                Value<double?> altitud = const Value.absent(),
                Value<double?> precision = const Value.absent(),
                Value<String?> direccionAproximada = const Value.absent(),
                Value<DateTime> fechaLectura = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<DateTime?> fechaSync = const Value.absent(),
                Value<int> intentosSync = const Value.absent(),
                Value<String?> codigoMedidor = const Value.absent(),
                Value<String?> predioCodigo = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<String?> nombreAbonado = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<bool> esAbonado = const Value.absent(),
                Value<bool> tieneLecturaReal = const Value.absent(),
                Value<bool> impreso = const Value.absent(),
                Value<DateTime?> fechaImpresion = const Value.absent(),
                Value<int?> tipoFacturacion = const Value.absent(),
                Value<int?> lecturaAnterior = const Value.absent(),
                Value<int?> consumoAnteriorServidor = const Value.absent(),
                Value<int?> lecturaActualServidor = const Value.absent(),
                Value<String?> estadoMedidorServidor = const Value.absent(),
                Value<String?> estadoMedidor = const Value.absent(),
                Value<String?> celular = const Value.absent(),
                Value<int> ordenRuta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LecturasCompanion(
                id: id,
                lectura: lectura,
                textoCrudo: textoCrudo,
                rutaFoto: rutaFoto,
                latitud: latitud,
                longitud: longitud,
                altitud: altitud,
                precision: precision,
                direccionAproximada: direccionAproximada,
                fechaLectura: fechaLectura,
                estadoSync: estadoSync,
                fechaSync: fechaSync,
                intentosSync: intentosSync,
                codigoMedidor: codigoMedidor,
                predioCodigo: predioCodigo,
                notas: notas,
                nombreAbonado: nombreAbonado,
                sector: sector,
                esAbonado: esAbonado,
                tieneLecturaReal: tieneLecturaReal,
                impreso: impreso,
                fechaImpresion: fechaImpresion,
                tipoFacturacion: tipoFacturacion,
                lecturaAnterior: lecturaAnterior,
                consumoAnteriorServidor: consumoAnteriorServidor,
                lecturaActualServidor: lecturaActualServidor,
                estadoMedidorServidor: estadoMedidorServidor,
                estadoMedidor: estadoMedidor,
                celular: celular,
                ordenRuta: ordenRuta,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int lectura,
                required String textoCrudo,
                required String rutaFoto,
                required double latitud,
                required double longitud,
                Value<double?> altitud = const Value.absent(),
                Value<double?> precision = const Value.absent(),
                Value<String?> direccionAproximada = const Value.absent(),
                required DateTime fechaLectura,
                Value<String> estadoSync = const Value.absent(),
                Value<DateTime?> fechaSync = const Value.absent(),
                Value<int> intentosSync = const Value.absent(),
                Value<String?> codigoMedidor = const Value.absent(),
                Value<String?> predioCodigo = const Value.absent(),
                Value<String?> notas = const Value.absent(),
                Value<String?> nombreAbonado = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<bool> esAbonado = const Value.absent(),
                Value<bool> tieneLecturaReal = const Value.absent(),
                Value<bool> impreso = const Value.absent(),
                Value<DateTime?> fechaImpresion = const Value.absent(),
                Value<int?> tipoFacturacion = const Value.absent(),
                Value<int?> lecturaAnterior = const Value.absent(),
                Value<int?> consumoAnteriorServidor = const Value.absent(),
                Value<int?> lecturaActualServidor = const Value.absent(),
                Value<String?> estadoMedidorServidor = const Value.absent(),
                Value<String?> estadoMedidor = const Value.absent(),
                Value<String?> celular = const Value.absent(),
                Value<int> ordenRuta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LecturasCompanion.insert(
                id: id,
                lectura: lectura,
                textoCrudo: textoCrudo,
                rutaFoto: rutaFoto,
                latitud: latitud,
                longitud: longitud,
                altitud: altitud,
                precision: precision,
                direccionAproximada: direccionAproximada,
                fechaLectura: fechaLectura,
                estadoSync: estadoSync,
                fechaSync: fechaSync,
                intentosSync: intentosSync,
                codigoMedidor: codigoMedidor,
                predioCodigo: predioCodigo,
                notas: notas,
                nombreAbonado: nombreAbonado,
                sector: sector,
                esAbonado: esAbonado,
                tieneLecturaReal: tieneLecturaReal,
                impreso: impreso,
                fechaImpresion: fechaImpresion,
                tipoFacturacion: tipoFacturacion,
                lecturaAnterior: lecturaAnterior,
                consumoAnteriorServidor: consumoAnteriorServidor,
                lecturaActualServidor: lecturaActualServidor,
                estadoMedidorServidor: estadoMedidorServidor,
                estadoMedidor: estadoMedidor,
                celular: celular,
                ordenRuta: ordenRuta,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LecturasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LecturasTable,
      Lectura,
      $$LecturasTableFilterComposer,
      $$LecturasTableOrderingComposer,
      $$LecturasTableAnnotationComposer,
      $$LecturasTableCreateCompanionBuilder,
      $$LecturasTableUpdateCompanionBuilder,
      (Lectura, BaseReferences<_$AppDatabase, $LecturasTable, Lectura>),
      Lectura,
      PrefetchHooks Function()
    >;
typedef $$RegistrosGpsTableCreateCompanionBuilder =
    RegistrosGpsCompanion Function({
      Value<int> id,
      required double latitud,
      required double longitud,
      Value<double?> altitud,
      required double precision,
      Value<double?> velocidad,
      required DateTime timestamp,
      Value<String?> lecturaId,
    });
typedef $$RegistrosGpsTableUpdateCompanionBuilder =
    RegistrosGpsCompanion Function({
      Value<int> id,
      Value<double> latitud,
      Value<double> longitud,
      Value<double?> altitud,
      Value<double> precision,
      Value<double?> velocidad,
      Value<DateTime> timestamp,
      Value<String?> lecturaId,
    });

class $$RegistrosGpsTableFilterComposer
    extends Composer<_$AppDatabase, $RegistrosGpsTable> {
  $$RegistrosGpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitud => $composableBuilder(
    column: $table.altitud,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precision => $composableBuilder(
    column: $table.precision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get velocidad => $composableBuilder(
    column: $table.velocidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lecturaId => $composableBuilder(
    column: $table.lecturaId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RegistrosGpsTableOrderingComposer
    extends Composer<_$AppDatabase, $RegistrosGpsTable> {
  $$RegistrosGpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitud => $composableBuilder(
    column: $table.latitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitud => $composableBuilder(
    column: $table.longitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitud => $composableBuilder(
    column: $table.altitud,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precision => $composableBuilder(
    column: $table.precision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get velocidad => $composableBuilder(
    column: $table.velocidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lecturaId => $composableBuilder(
    column: $table.lecturaId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RegistrosGpsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RegistrosGpsTable> {
  $$RegistrosGpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitud =>
      $composableBuilder(column: $table.latitud, builder: (column) => column);

  GeneratedColumn<double> get longitud =>
      $composableBuilder(column: $table.longitud, builder: (column) => column);

  GeneratedColumn<double> get altitud =>
      $composableBuilder(column: $table.altitud, builder: (column) => column);

  GeneratedColumn<double> get precision =>
      $composableBuilder(column: $table.precision, builder: (column) => column);

  GeneratedColumn<double> get velocidad =>
      $composableBuilder(column: $table.velocidad, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get lecturaId =>
      $composableBuilder(column: $table.lecturaId, builder: (column) => column);
}

class $$RegistrosGpsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RegistrosGpsTable,
          RegistrosGp,
          $$RegistrosGpsTableFilterComposer,
          $$RegistrosGpsTableOrderingComposer,
          $$RegistrosGpsTableAnnotationComposer,
          $$RegistrosGpsTableCreateCompanionBuilder,
          $$RegistrosGpsTableUpdateCompanionBuilder,
          (
            RegistrosGp,
            BaseReferences<_$AppDatabase, $RegistrosGpsTable, RegistrosGp>,
          ),
          RegistrosGp,
          PrefetchHooks Function()
        > {
  $$RegistrosGpsTableTableManager(_$AppDatabase db, $RegistrosGpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$RegistrosGpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$RegistrosGpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$RegistrosGpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> latitud = const Value.absent(),
                Value<double> longitud = const Value.absent(),
                Value<double?> altitud = const Value.absent(),
                Value<double> precision = const Value.absent(),
                Value<double?> velocidad = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> lecturaId = const Value.absent(),
              }) => RegistrosGpsCompanion(
                id: id,
                latitud: latitud,
                longitud: longitud,
                altitud: altitud,
                precision: precision,
                velocidad: velocidad,
                timestamp: timestamp,
                lecturaId: lecturaId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double latitud,
                required double longitud,
                Value<double?> altitud = const Value.absent(),
                required double precision,
                Value<double?> velocidad = const Value.absent(),
                required DateTime timestamp,
                Value<String?> lecturaId = const Value.absent(),
              }) => RegistrosGpsCompanion.insert(
                id: id,
                latitud: latitud,
                longitud: longitud,
                altitud: altitud,
                precision: precision,
                velocidad: velocidad,
                timestamp: timestamp,
                lecturaId: lecturaId,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RegistrosGpsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RegistrosGpsTable,
      RegistrosGp,
      $$RegistrosGpsTableFilterComposer,
      $$RegistrosGpsTableOrderingComposer,
      $$RegistrosGpsTableAnnotationComposer,
      $$RegistrosGpsTableCreateCompanionBuilder,
      $$RegistrosGpsTableUpdateCompanionBuilder,
      (
        RegistrosGp,
        BaseReferences<_$AppDatabase, $RegistrosGpsTable, RegistrosGp>,
      ),
      RegistrosGp,
      PrefetchHooks Function()
    >;
typedef $$NovedadesLocalesTableCreateCompanionBuilder =
    NovedadesLocalesCompanion Function({
      Value<int> id,
      required int predioId,
      required String concepto,
      required int valorCuota,
      required int cuotasPendientes,
      required int totalPendiente,
    });
typedef $$NovedadesLocalesTableUpdateCompanionBuilder =
    NovedadesLocalesCompanion Function({
      Value<int> id,
      Value<int> predioId,
      Value<String> concepto,
      Value<int> valorCuota,
      Value<int> cuotasPendientes,
      Value<int> totalPendiente,
    });

class $$NovedadesLocalesTableFilterComposer
    extends Composer<_$AppDatabase, $NovedadesLocalesTable> {
  $$NovedadesLocalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get predioId => $composableBuilder(
    column: $table.predioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorCuota => $composableBuilder(
    column: $table.valorCuota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cuotasPendientes => $composableBuilder(
    column: $table.cuotasPendientes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPendiente => $composableBuilder(
    column: $table.totalPendiente,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NovedadesLocalesTableOrderingComposer
    extends Composer<_$AppDatabase, $NovedadesLocalesTable> {
  $$NovedadesLocalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get predioId => $composableBuilder(
    column: $table.predioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concepto => $composableBuilder(
    column: $table.concepto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorCuota => $composableBuilder(
    column: $table.valorCuota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cuotasPendientes => $composableBuilder(
    column: $table.cuotasPendientes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPendiente => $composableBuilder(
    column: $table.totalPendiente,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NovedadesLocalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NovedadesLocalesTable> {
  $$NovedadesLocalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get predioId =>
      $composableBuilder(column: $table.predioId, builder: (column) => column);

  GeneratedColumn<String> get concepto =>
      $composableBuilder(column: $table.concepto, builder: (column) => column);

  GeneratedColumn<int> get valorCuota => $composableBuilder(
    column: $table.valorCuota,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cuotasPendientes => $composableBuilder(
    column: $table.cuotasPendientes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalPendiente => $composableBuilder(
    column: $table.totalPendiente,
    builder: (column) => column,
  );
}

class $$NovedadesLocalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NovedadesLocalesTable,
          NovedadesLocale,
          $$NovedadesLocalesTableFilterComposer,
          $$NovedadesLocalesTableOrderingComposer,
          $$NovedadesLocalesTableAnnotationComposer,
          $$NovedadesLocalesTableCreateCompanionBuilder,
          $$NovedadesLocalesTableUpdateCompanionBuilder,
          (
            NovedadesLocale,
            BaseReferences<
              _$AppDatabase,
              $NovedadesLocalesTable,
              NovedadesLocale
            >,
          ),
          NovedadesLocale,
          PrefetchHooks Function()
        > {
  $$NovedadesLocalesTableTableManager(
    _$AppDatabase db,
    $NovedadesLocalesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$NovedadesLocalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$NovedadesLocalesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$NovedadesLocalesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> predioId = const Value.absent(),
                Value<String> concepto = const Value.absent(),
                Value<int> valorCuota = const Value.absent(),
                Value<int> cuotasPendientes = const Value.absent(),
                Value<int> totalPendiente = const Value.absent(),
              }) => NovedadesLocalesCompanion(
                id: id,
                predioId: predioId,
                concepto: concepto,
                valorCuota: valorCuota,
                cuotasPendientes: cuotasPendientes,
                totalPendiente: totalPendiente,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int predioId,
                required String concepto,
                required int valorCuota,
                required int cuotasPendientes,
                required int totalPendiente,
              }) => NovedadesLocalesCompanion.insert(
                id: id,
                predioId: predioId,
                concepto: concepto,
                valorCuota: valorCuota,
                cuotasPendientes: cuotasPendientes,
                totalPendiente: totalPendiente,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NovedadesLocalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NovedadesLocalesTable,
      NovedadesLocale,
      $$NovedadesLocalesTableFilterComposer,
      $$NovedadesLocalesTableOrderingComposer,
      $$NovedadesLocalesTableAnnotationComposer,
      $$NovedadesLocalesTableCreateCompanionBuilder,
      $$NovedadesLocalesTableUpdateCompanionBuilder,
      (
        NovedadesLocale,
        BaseReferences<_$AppDatabase, $NovedadesLocalesTable, NovedadesLocale>,
      ),
      NovedadesLocale,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LecturasTableTableManager get lecturas =>
      $$LecturasTableTableManager(_db, _db.lecturas);
  $$RegistrosGpsTableTableManager get registrosGps =>
      $$RegistrosGpsTableTableManager(_db, _db.registrosGps);
  $$NovedadesLocalesTableTableManager get novedadesLocales =>
      $$NovedadesLocalesTableTableManager(_db, _db.novedadesLocales);
}
