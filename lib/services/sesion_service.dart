// lib/services/sesion_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/acueducto.dart';

class SesionService {
  static const _keySesion = 'sesion_acueducto_activa';

  // Guarda la sesión activa en SharedPreferences
  // Se llama al hacer login exitoso
  static Future<void> guardarSesion(Acueducto acueducto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySesion, acueducto.tipo.name);
  }

  // Retorna el acueducto con sesión activa, o null si no hay sesión
  // Se llama al abrir la app para saber si mostrar login o ir directo
  static Future<Acueducto?> sesionActiva() async {
    final prefs = await SharedPreferences.getInstance();
    final tipo = prefs.getString(_keySesion);
    if (tipo == null) return null;
    return Acueducto.porTipo(tipo);
  }

  // Cierra la sesión — borra la clave de SharedPreferences
  static Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySesion);
  }
}