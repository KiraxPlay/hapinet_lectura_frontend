// lib/services/api/api_service.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../data/database.dart';
import '../../models/acueducto.dart';
import '../../models/estado_medidor.dart';
import '../../models/punto_mapa.dart';
import '../sesion_service.dart';

class ApiService {
  final Acueducto acueducto;
  ApiService(this.acueducto);

  String get _baseUrl => acueducto.apiUrl;

  // ── Headers con token ──────────────────────
  Future<Map<String, String>> get _headers async {
    final token = await SesionService.obtenerToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────
  // AUTENTICACIÓN
  // ─────────────────────────────────────────────

  // POST /api/login
  Future<Map<String, dynamic>> login(String usuario, String clave) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'usuario_usuario': usuario, 'usuario_clave': clave}),
    );
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return body; // login_screen lee body['token'] y body['message']
  }

  // POST /api/logout
  Future<void> logout() async {
    try {
      await http
          .post(Uri.parse('$_baseUrl/logout'), headers: await _headers)
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  // POST /api/refresh
  Future<String?> refresh() async {
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/refresh'),
        headers: await _headers,
      );
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body)['token'] as String?;
      }
    } catch (_) {}
    return null;
  }

  // ─────────────────────────────────────────────
  // PREDIOS / ABONADOS
  // ─────────────────────────────────────────────

  // GET /api/novedadesMasivas — todas las novedades de predios sin lectura
  // Para importación offline al iniciar la app
  Future<List<dynamic>> novedadesMasivas() async {
    final resp = await _getConRefresh(Uri.parse('$_baseUrl/novedadesMasivas'));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    }
    return []; // sin novedades no es error crítico
  }

  // GET /api/novedadesPredio/{predio_id}
  Future<List<dynamic>> novedadesPredio(int predioId) async {
    final resp = await _getConRefresh(
      Uri.parse('$_baseUrl/novedadesPredio/$predioId'),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    }
    throw Exception('Error al obtener novedades: ${resp.statusCode}');
  }

  // GET /api/tutoriales — ruta pública, no requiere token
  Future<List<dynamic>> tutoriales() async {
    final resp = await http
        .get(
          Uri.parse('$_baseUrl/tutoriales'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    }
    throw Exception('Error al cargar tutoriales: ${resp.statusCode}');
  }

  // GET /api/listPredios
  Future<List<dynamic>> listPredios() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/listPredios'),
      headers: await _headers,
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    }
    var detalle = resp.body.trim();
    try {
      final body = jsonDecode(resp.body);
      if (body is Map<String, dynamic>) {
        detalle = (body['message'] ?? body['error'] ?? detalle).toString();
      }
    } catch (_) {
      // La respuesta puede ser HTML cuando Laravel lanza un 500.
    }
    final detalleCorto =
        detalle.length > 180 ? '${detalle.substring(0, 180)}...' : detalle;
    throw Exception(
      'Error al descargar predios: ${resp.statusCode} $detalleCorto',
    );
  }

  // Busca predio_id por predio_codigo en la lista de predios
  Future<int?> obtenerPredioIdPorCodigo(String codigo) async {
    final predios = await listPredios();
    for (final item in predios) {
      final mapa = item as Map<String, dynamic>;
      if (mapa['predio_codigo']?.toString() == codigo) {
        return int.tryParse(mapa['predio_id'].toString());
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────
  // PERIODO ACTIVO
  // ─────────────────────────────────────────────

  // Callback para cerrar sesión automáticamente cuando el token expira
  // Se asigna desde main.dart al iniciar la app
  static Future<void> Function()? onSesionExpirada;

  Future<void> _manejarSesionExpirada() async {
    await SesionService.cerrarSesion();
    await onSesionExpirada?.call();
  }

  // GET con refresh automático
  Future<http.Response> _getConRefresh(Uri uri) async {
    var resp = await http.get(uri, headers: await _headers);
    if (resp.statusCode == 401) {
      // Token expirado — intentar refrescar
      final nuevoToken = await refresh();
      if (nuevoToken != null) {
        await SesionService.guardarToken(nuevoToken);
        resp = await http.get(uri, headers: await _headers);
      } else {
        // Refresh también falló — sesión expirada definitivamente
        await _manejarSesionExpirada();
        throw Exception('Sesión expirada — inicia sesión de nuevo');
      }
    }
    return resp;
  }

  // POST con refresh automático
  Future<http.Response> _postConRefresh(Uri uri, {String? body}) async {
    var resp = await http.post(uri, headers: await _headers, body: body);
    if (resp.statusCode == 401) {
      final nuevoToken = await refresh();
      if (nuevoToken != null) {
        await SesionService.guardarToken(nuevoToken);
        resp = await http.post(uri, headers: await _headers, body: body);
      } else {
        await _manejarSesionExpirada();
        throw Exception('Sesión expirada — inicia sesión de nuevo');
      }
    }
    return resp;
  }

  // GET /api/periodoActivo
  Future<Map<String, dynamic>> periodoActivo() async {
    final resp = await _getConRefresh(Uri.parse('$_baseUrl/periodoActivo'));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('No se pudo obtener el período activo: ${resp.statusCode}');
  }

  Future<void> sincronizarNombrePeriodoActivo(AppDatabase db) async {
    final periodo = await periodoActivo();
    final nombre = periodo['periodo_nombre']?.toString().trim();
    if (nombre == null || nombre.isEmpty) {
      throw const FormatException(
        'El período activo no contiene periodo_nombre',
      );
    }
    await db.guardarNombrePeriodoActivo(nombre);
  }

  // GET /api/fechasPeriodoActivo
  Future<Map<String, dynamic>> fechasPeriodoActivo() async {
    final resp = await _getConRefresh(
      Uri.parse('$_baseUrl/fechasPeriodoActivo'),
    ).timeout(const Duration(seconds: 10));
    if (resp.statusCode == 200) {
      final fechas = jsonDecode(resp.body) as Map<String, dynamic>;
      for (final campo in [
        'periodo_inicio',
        'periodo_fin',
        'periodo_limite',
        'periodo_suspencion',
      ]) {
        if (fechas[campo] != null && fechas[campo] is! String) {
          throw FormatException(
            'La respuesta de fechasPeriodoActivo contiene $campo inválido',
          );
        }
      }
      return fechas;
    }
    throw Exception(
      'No se pudieron obtener las fechas del período activo: ${resp.statusCode}',
    );
  }

  Future<Map<String, dynamic>> sincronizarFechasPeriodoActivo(
    AppDatabase db,
  ) async {
    final fechas = await fechasPeriodoActivo();
    await db.guardarFechasPeriodoActivo(
      periodoInicio: fechas['periodo_inicio'] as String?,
      periodoFin: fechas['periodo_fin'] as String?,
      periodoLimite: fechas['periodo_limite'] as String?,
      periodoSuspencion: fechas['periodo_suspencion'] as String?,
    );
    return fechas;
  }

  // GET /api/historicoConsumo?predio_id={id}&periodos={n}
  // Cada lectura incluye lectura_uuid; las estimadas _ESPROMEDIO se excluyen
  // del historial que devuelve el servidor.
  Future<Map<String, dynamic>?> consumosAnteriores(
    int predioId, {
    int periodos = 6,
  }) async {
    final uri = Uri.parse('$_baseUrl/historicoConsumo').replace(
      queryParameters: {'predio_id': '$predioId', 'periodos': '$periodos'},
    );
    final resp = await _getConRefresh(uri);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    if (resp.statusCode == 404) return null;
    throw Exception(
      'Error al obtener consumos anteriores: ${resp.statusCode} - ${resp.body}',
    );
  }

  // ─────────────────────────────────────────────
  // EMPRESA
  // ─────────────────────────────────────────────

  // GET /api/Empresa
  // Retorna datos de la empresa para el encabezado del PDF
  Future<Map<String, dynamic>> infoEmpresa() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/Empresa'),
      headers: await _headers,
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Error al obtener empresa: ${resp.statusCode}');
  }

  // ─────────────────────────────────────────────
  // TARIFAS
  // ─────────────────────────────────────────────

  // GET /api/tarifas
  // Retorna CargoBasico y TarifaBasicaConsumo para cálculo offline
  Future<List<dynamic>> tarifas() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/tarifas'),
      headers: await _headers,
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    }
    throw Exception('Error al obtener tarifas: ${resp.statusCode}');
  }

  // ─────────────────────────────────────────────
  // FACTURACIÓN
  // ─────────────────────────────────────────────

  // POST /api/generarFactura
  // Genera factura oficial en el servidor para un predio
  Future<Map<String, dynamic>> generarFactura(int predioId) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/generarFactura'),
      headers: await _headers,
      body: jsonEncode({'predio_id': predioId}),
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    throw Exception(
      body['message'] ?? 'Error al generar factura: ${resp.statusCode}',
    );
  }

  // GET /api/detalleFactura/{factura_id}
  Future<Map<String, dynamic>> detalleFactura(int facturaId) async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/detalleFactura/$facturaId'),
      headers: await _headers,
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Error al obtener detalle de factura: ${resp.statusCode}');
  }

  // GET /api/deudaAbonado/{predio_id}
  Future<Map<String, dynamic>> deudaAbonado(int predioId) async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/deudaAbonado/$predioId'),
      headers: await _headers,
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Error al obtener deuda: ${resp.statusCode}');
  }

  // ─────────────────────────────────────────────
  // SINCRONIZACIÓN DE LECTURAS
  // ─────────────────────────────────────────────

  // POST /api/sincronizacionLecturas
  // Envía batch de lecturas al servidor
  Future<Map<String, dynamic>> sincronizarLecturas(
    List<Map<String, dynamic>> lecturas,
  ) async {
    final url = '$_baseUrl/sincronizacionLecturas';
    final resp = await _postConRefresh(
      Uri.parse(url),
      body: jsonEncode({'lecturas': lecturas}),
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Error al sincronizar: ${resp.statusCode} - ${resp.body}');
  }

  Future<Map<String, int>> _obtenerIdsEstadosMedidor() async {
    final resp = await _getConRefresh(Uri.parse('$_baseUrl/estadosMedidor'));
    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener estados del medidor: ${resp.statusCode} - ${resp.body}',
      );
    }

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final estados = body['estados_medidor'];
    if (estados is! List) {
      throw const FormatException(
        'La respuesta de estadosMedidor no contiene estados_medidor',
      );
    }

    final idsPorNombre = <String, int>{};
    for (final item in estados) {
      if (item is! Map<String, dynamic> ||
          item['parametro_nombre'] is! String ||
          item['parametro_id'] is! num) {
        throw const FormatException(
          'La respuesta de estadosMedidor contiene un parámetro inválido',
        );
      }
      idsPorNombre[_normalizarNombreParametro(
            item['parametro_nombre'] as String,
          )] =
          (item['parametro_id'] as num).toInt();
    }
    return idsPorNombre;
  }

  Future<Map<int, EstadoServidorPredio>> estadosMedidorPredios() async {
    final resp = await _getConRefresh(
      Uri.parse('$_baseUrl/estadosMedidorPredios'),
    );
    developer.log(
      'GET estadosMedidorPredios status=${resp.statusCode}',
      name: 'estados_medidor.api',
    );
    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener estados actuales: ${resp.statusCode} - ${resp.body}',
      );
    }

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final estados = body['estados'];
    if (estados is! List) {
      throw const FormatException(
        'La respuesta no contiene la lista de estados actuales',
      );
    }
    developer.log(
      'El API devolvió ${estados.length} registros de estado.',
      name: 'estados_medidor.api',
    );

    final porPredio = <int, EstadoServidorPredio>{};
    for (final item in estados) {
      if (item is! Map<String, dynamic> ||
          item['predio_id'] is! num ||
          item['lectura_actual'] is! num ||
          (item['error_id'] is! num && item['parametro_nombre'] is! String)) {
        throw const FormatException(
          'La respuesta de estados actuales contiene un registro inválido',
        );
      }
      final estado =
          EstadoMedidor.desdeParametroId((item['error_id'] as num?)?.toInt()) ??
          EstadoMedidor.desdeNombreParametro(
            item['parametro_nombre'] is String
                ? item['parametro_nombre'] as String
                : null,
          );
      if (estado == null) {
        throw FormatException(
          'Estado de medidor desconocido: '
          '${item['error_id'] ?? item['parametro_nombre']}',
        );
      }
      porPredio[(item['predio_id'] as num).toInt()] = (
        estado: estado,
        lecturaActual: (item['lectura_actual'] as num).toInt(),
      );
      developer.log(
        'predio_id=${item['predio_id']}, error_id=${item['error_id']}, '
        'parametro_nombre=${item['parametro_nombre']}, estado=${estado.clave}',
        name: 'estados_medidor.api',
      );
    }
    return porPredio;
  }

  Future<void> guardarEstadosMedidorLocales(AppDatabase db) async {
    final estados = await estadosMedidorPredios();
    var guardados = 0;
    var noEncontrados = 0;
    for (final entry in estados.entries) {
      final guardado = await db.guardarEstadoMedidorRemoto(
        predioId: entry.key,
        lecturaActual: entry.value.lecturaActual,
        estadoMedidor: entry.value.estado.clave,
      );
      if (guardado) {
        guardados++;
      } else {
        noEncontrados++;
      }
    }
    developer.log(
      'Persistencia de estados finalizada: recibidos=${estados.length}, '
      'guardados=$guardados, sinFilaLocal=$noEncontrados.',
      name: 'estados_medidor.api',
    );
  }

  String _normalizarNombreParametro(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(RegExp(r'[^a-z0-9]'), '');

  int _errorIdDesdeEstado(String? estado, Map<String, int> idsPorNombre) {
    final estadoMedidor = EstadoMedidor.desdeClave(estado);
    if (estado != null && estadoMedidor == null) {
      throw FormatException('Estado de medidor no reconocido: $estado');
    }
    final nombreParametro =
        (estadoMedidor ?? EstadoMedidor.lecturaRealizada).nombreParametro;
    final nombreNormalizado = _normalizarNombreParametro(nombreParametro);
    final errorId = idsPorNombre[nombreNormalizado];
    if (errorId == null) {
      throw FormatException(
        'El estado "$nombreParametro" no está configurado en el servidor',
      );
    }
    return errorId;
  }

  // Sincroniza todas las lecturas pendientes de la BD local
  Future<void> sincronizarLecturasPendientes(AppDatabase db) async {
    final pendientes = await db.obtenerPendientesSync();
    if (pendientes.isEmpty) return;

    final periodo = await periodoActivo();
    final periodoNombre = periodo['periodo_nombre']?.toString().trim();
    if (periodoNombre == null || periodoNombre.isEmpty) {
      throw const FormatException(
        'El período activo no contiene periodo_nombre',
      );
    }
    final periodoCodigo =
        periodoNombre.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final idsEstadosMedidor = await _obtenerIdsEstadosMedidor();

    final payload = <Map<String, dynamic>>[];
    final uuidsPorLectura = <String, String>{};
    for (final l in pendientes) {
      final codigoPredio = l.predioCodigo?.trim();
      if (codigoPredio == null || codigoPredio.isEmpty) continue;

      // Extraer predio_id del id local — 'predio_123' → 123
      final match = RegExp(r'predio_(\d+)').firstMatch(l.id);
      final predioId = match != null ? int.tryParse(match.group(1)!) : null;
      if (predioId == null) continue;

      final uuidBase = '${codigoPredio}_$periodoCodigo';
      final uuid =
          l.tipoFacturacion == 65 ? '${uuidBase}_ESPROMEDIO' : uuidBase;
      final consumo =
          l.lecturaAnterior == null
              ? 0
              : (l.lectura - l.lecturaAnterior!).clamp(0, 999999);

      uuidsPorLectura[l.id] = uuid;
      payload.add({
        'uuid': uuid,
        'predio_id': predioId,
        'lectura_actual': l.lectura,
        'lectura_consumo': consumo,
        'error_id': _errorIdDesdeEstado(l.estadoMedidor, idsEstadosMedidor),
      });
    }

    if (payload.isEmpty) return;

    //Para color del debugging en consola
    //const String reset = '\x1B[0m';
    //const String green = '\x1B[32m';
    //const String cyan = '\x1B[36m';
    //print('$green Enviando ${payload.length} lecturas: $cyan${jsonEncode(payload)}$reset');
    final respuesta = await sincronizarLecturas(payload);
    final uuidsOk =
        (respuesta['uuids_ok'] as List<dynamic>? ?? []).cast<String>();

    for (final l in pendientes) {
      final uuid = uuidsPorLectura[l.id];
      if (uuid == null) continue;
      if (uuidsOk.contains(uuid)) {
        await db.actualizarEstadoSync(l.id, 'sincronizado', DateTime.now());
      } else {
        await db.incrementarIntentosFallidos(l.id);
      }
    }
  }
}
