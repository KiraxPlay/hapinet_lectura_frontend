// lib/services/api/api_client.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _instancia = ApiClient._();
  static ApiClient get instancia => _instancia;
  ApiClient._();

  // Lee API_URL del archivo .env
  // Si no existe la variable, usa localhost como fallback
  static String get baseUrl =>
      dotenv.env['API_URL'] ?? 'http://192.168.18.8:8000/api';

  static const _keyToken = 'api_token';
  static const _timeout  = Duration(seconds: 30);

  // ─────────────────────────────────────────────
  // TOKEN
  // ─────────────────────────────────────────────

  Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<void> guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  Future<void> limpiarToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  Future<bool> tieneToken() async {
    final token = await obtenerToken();
    return token != null && token.isNotEmpty;
  }

  // ─────────────────────────────────────────────
  // HEADERS — agrega el token automáticamente
  // ─────────────────────────────────────────────

  Future<Map<String, String>> _headers() async {
    final token = await obtenerToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? params]) {
    final uri = Uri.parse('$baseUrl$path');
    if (params == null) return uri;
    return uri.replace(
        queryParameters:
            params.map((k, v) => MapEntry(k, v.toString())));
  }

  // ─────────────────────────────────────────────
  // MÉTODOS HTTP
  // ─────────────────────────────────────────────

  Future<ApiResponse> get(String path,
      {Map<String, dynamic>? params}) async {
    try {
      final response = await http
          .get(_uri(path, params), headers: await _headers())
          .timeout(_timeout);
      return ApiResponse.deHttp(response);
    } catch (e) {
      return ApiResponse.error(_mensajeError(e));
    }
  }

  Future<ApiResponse> post(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .post(_uri(path),
              headers: await _headers(),
              body: body != null ? jsonEncode(body) : null)
          .timeout(_timeout);
      return ApiResponse.deHttp(response);
    } catch (e) {
      return ApiResponse.error(_mensajeError(e));
    }
  }

  Future<ApiResponse> put(String path, {Map<String, dynamic>? body}) async {
    try {
      final response = await http
          .put(_uri(path),
              headers: await _headers(),
              body: body != null ? jsonEncode(body) : null)
          .timeout(_timeout);
      return ApiResponse.deHttp(response);
    } catch (e) {
      return ApiResponse.error(_mensajeError(e));
    }
  }

  // ─────────────────────────────────────────────
  // VERIFICAR CONEXIÓN
  // ─────────────────────────────────────────────

  Future<bool> tieneConexion() async {
    try {
      final response = await http
          .get(_uri('/ping'), headers: await _headers())
          .timeout(const Duration(seconds: 5));
      return response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  String _mensajeError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('timeout')) return 'Tiempo de espera agotado';
    if (msg.contains('socket') || msg.contains('connection')) {
      return 'Sin conexión al servidor';
    }
    return 'Error de red: $e';
  }
}

// ─────────────────────────────────────────────
// RESPUESTA UNIFICADA
// ─────────────────────────────────────────────

class ApiResponse {
  final int? statusCode;
  final dynamic data;
  final String? error;

  bool get exitoso =>
      error == null && statusCode != null && statusCode! < 400;
  bool get sinConexion => error != null;
  bool get noAutorizado => statusCode == 401;

  const ApiResponse._({this.statusCode, this.data, this.error});

  factory ApiResponse.deHttp(http.Response r) {
    try {
      final data = r.body.isNotEmpty ? jsonDecode(r.body) : null;
      return ApiResponse._(statusCode: r.statusCode, data: data);
    } catch (_) {
      return ApiResponse._(statusCode: r.statusCode, data: r.body);
    }
  }

  factory ApiResponse.error(String mensaje) =>
      ApiResponse._(error: mensaje);
}