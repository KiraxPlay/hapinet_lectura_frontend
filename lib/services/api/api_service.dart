// lib/services/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/database.dart';
import '../../models/acueducto.dart';
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
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      body: jsonEncode({'usuario_usuario': usuario, 'usuario_clave': clave}),
    );
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    return body; // login_screen lee body['token'] y body['message']
  }

  // POST /api/logout
  Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: await _headers,
      ).timeout(const Duration(seconds: 5));
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
    final resp = await _getConRefresh(
        Uri.parse('$_baseUrl/novedadesMasivas'));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    }
    return []; // sin novedades no es error crítico
  }



  // GET /api/novedadesPredio/{predio_id}
  Future<List<dynamic>> novedadesPredio(int predioId) async {
    final resp = await _getConRefresh(
        Uri.parse('$_baseUrl/novedadesPredio/$predioId'));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as List<dynamic>;
    }
    throw Exception('Error al obtener novedades: ${resp.statusCode}');
  }

  // GET /api/tutoriales — ruta pública, no requiere token
  Future<List<dynamic>> tutoriales() async {
    final resp = await http.get(
      Uri.parse('$_baseUrl/tutoriales'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));
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
    final detalleCorto = detalle.length > 180
        ? '${detalle.substring(0, 180)}...'
        : detalle;
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
    var resp = await http.post(uri,
        headers: await _headers, body: body);
    if (resp.statusCode == 401) {
      final nuevoToken = await refresh();
      if (nuevoToken != null) {
        await SesionService.guardarToken(nuevoToken);
        resp = await http.post(uri,
            headers: await _headers, body: body);
      } else {
        await _manejarSesionExpirada();
        throw Exception('Sesión expirada — inicia sesión de nuevo');
      }
    }
    return resp;
  }

  // GET /api/periodoActivo
  Future<Map<String, dynamic>> periodoActivo() async {
    final resp = await _getConRefresh(
        Uri.parse('$_baseUrl/periodoActivo'));
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception(
        'No se pudo obtener el período activo: ${resp.statusCode}');
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
    throw Exception(body['message'] ?? 'Error al generar factura: ${resp.statusCode}');
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
    final headers = await _headers;
    final url = '$_baseUrl/sincronizacionLecturas';
    print('📡 POST $url');
    print('📡 Headers: $headers');
    final resp = await _postConRefresh(
      Uri.parse(url),
      body: jsonEncode({'lecturas': lecturas}),
    );
    print('📡 Sync response ${resp.statusCode}: ${resp.body}');
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    throw Exception('Error al sincronizar: ${resp.statusCode} - ${resp.body}');
  }

  // Convierte estado del medidor → error_id de Laravel
  int _errorIdDesdeEstado(String? estado) => switch (estado) {
        'danado'          => 21,
        'empanado'        => 22,
        'sin_contador'    => 23,
        'con_fuga'        => 24,
        'acceso_denegado' => 0,
        _                 => 0,
      };

  // Sincroniza todas las lecturas pendientes de la BD local
  Future<void> sincronizarLecturasPendientes(AppDatabase db) async {
    final pendientes = await db.obtenerPendientesSync();
    if (pendientes.isEmpty) return;

    // Obtener período activo del servidor
    int? periodoId;
    try {
      print('🔄 Obteniendo período activo...');
      final periodo = await periodoActivo();
      periodoId = periodo['periodo_id'] as int?;
      print('✓ Período activo: $periodoId');
    } catch (e) {
      print('✗ Error obteniendo período: $e');
    }

    if (periodoId == null) {
      print('✗ periodoId es null — abortando sync');
      throw Exception('No se pudo obtener el período activo');
    }

    final payload = <Map<String, dynamic>>[];
    for (final l in pendientes) {
      if (l.codigoMedidor == null || l.codigoMedidor!.isEmpty) continue;

      // Extraer predio_id del id local — 'predio_123' → 123
      final match = RegExp(r'predio_(\d+)').firstMatch(l.id);
      final predioId = match != null ? int.tryParse(match.group(1)!) : null;
      if (predioId == null) continue;

      // UUID legible y único: TEN-0001_PERIODO9
      final uuid = '${l.codigoMedidor}_PERIODO$periodoId';

      payload.add({
        'uuid':           uuid,
        'predio_id':      predioId,
        'lectura_actual': l.lectura,
        'error_id':       _errorIdDesdeEstado(l.estadoMedidor),
      });
    }

    if (payload.isEmpty) return;

    print('📤 Enviando ${payload.length} lecturas: ${jsonEncode(payload)}');
    final respuesta = await sincronizarLecturas(payload);
    final uuidsOk = (respuesta['uuids_ok'] as List<dynamic>? ?? [])
        .cast<String>();

    for (final l in pendientes) {
      if (l.codigoMedidor == null) continue;
      final match = RegExp(r'predio_(\d+)').firstMatch(l.id);
      final predioId = match != null ? int.tryParse(match.group(1)!) : null;
      if (predioId == null) continue;

      final uuid = '${l.codigoMedidor}_PERIODO$periodoId';
      if (uuidsOk.contains(uuid)) {
        await db.actualizarEstadoSync(l.id, 'sincronizado', DateTime.now());
      } else {
        await db.incrementarIntentosFallidos(l.id);
      }
    }
  }
}