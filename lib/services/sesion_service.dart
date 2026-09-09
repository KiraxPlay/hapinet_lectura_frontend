import 'package:shared_preferences/shared_preferences.dart';
import '../models/acueducto.dart';

class SesionService {
  static const _keySesion = 'sesion_acueducto_activa';
  static const _keyToken = 'token_jwt'; // ← nuevo
  static const _keyUsuario = 'usuario_datos'; // ← nuevo (opcional)

  // Guarda la sesión: acueducto + token
  static Future<void> guardarSesion(Acueducto acueducto, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySesion, acueducto.tipo.name);
    await prefs.setString(_keyToken, token); // ← guardar el token
  }

  // Recuperar el token para las llamadas al API
  static Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<Acueducto?> sesionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    final tipo = prefs.getString(_keySesion);
    if (tipo == null) return null;
    return Acueducto.porTipo(tipo);
  }

  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySesion);
    await prefs.remove(_keyToken); // ← borrar el token también
    await prefs.remove(_keyUsuario);
  }

  // Agregar este método en SesionService
  static Future<void> guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }
}
