// lib/services/api/tarifas_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/acueducto.dart';
import 'api_service.dart';

class TarifasService {
  static const _keyCargoBasico    = 'tarifa_cargo_basico';
  static const _keyTarifaM3      = 'tarifa_m3';
  static const _keyEmpresaNombre  = 'empresa_nombre';
  static const _keyEmpresaNit     = 'empresa_nit';
  static const _keyEmpresaTel     = 'empresa_telefono';
  static const _keyEmpresaEmail   = 'empresa_email';
  static const _keyUltimaSync     = 'tarifas_ultima_sync';

  final Acueducto acueducto;
  TarifasService({required this.acueducto});

  // ─────────────────────────────────────────────
  // SINCRONIZAR — tarifas + empresa
  // ─────────────────────────────────────────────
  Future<bool> sincronizar() async {
    try {
      final api   = ApiService(acueducto);
      final prefs = await SharedPreferences.getInstance();

      // Tarifas
      final lista = await api.tarifas();
      for (final t in lista) {
        final variable = t['tarifa_variable'] as String;
        final valor    = double.tryParse(t['tarifa_valor'].toString()) ?? 0.0;
        if (variable == 'CargoBasico') {
          await prefs.setDouble(_keyCargoBasico, valor);
        } else if (variable == 'TarifaBasicaConsumo') {
          await prefs.setDouble(_keyTarifaM3, valor);
        }
      }

      // Empresa
      final emp = await api.infoEmpresa();
      await prefs.setString(_keyEmpresaNombre, emp['empresa_nombre']   ?? '');
      await prefs.setString(_keyEmpresaNit,    emp['empresa_nit']      ?? '');
      await prefs.setString(_keyEmpresaTel,    emp['empresa_telefono'] ?? '');
      await prefs.setString(_keyEmpresaEmail,  emp['empresa_email']    ?? '');
      await prefs.setString(_keyUltimaSync, DateTime.now().toIso8601String());

      return true;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // LEER LOCAL (offline)
  // ─────────────────────────────────────────────
  Future<TarifasLocal> obtenerLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return TarifasLocal(
      cargoBasico:     prefs.getDouble(_keyCargoBasico) ?? 0.0,
      tarifaM3:        prefs.getDouble(_keyTarifaM3)    ?? 0.0,
      empresaNombre:   prefs.getString(_keyEmpresaNombre)  ?? '',
      empresaNit:      prefs.getString(_keyEmpresaNit)     ?? '',
      empresaTelefono: prefs.getString(_keyEmpresaTel)     ?? '',
      empresaEmail:    prefs.getString(_keyEmpresaEmail)   ?? '',
      ultimaSync:      prefs.getString(_keyUltimaSync),
    );
  }

  Future<bool> tieneTarifasLocales() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyCargoBasico);
  }

  // ─────────────────────────────────────────────
  // CALCULAR OFFLINE
  // ─────────────────────────────────────────────
  Future<ComprobanteCalculo> calcularOffline({
    required int lecturaActual,
    required int lecturaAnterior,
  }) async {
    final t       = await obtenerLocal();
    final consumo = (lecturaActual - lecturaAnterior).clamp(0, 999999);
    final valCons = (consumo * t.tarifaM3).round();
    final total   = t.cargoBasico.round() + valCons;

    return ComprobanteCalculo(
      consumo:      consumo,
      cargoBasico:  t.cargoBasico.round(),
      valorConsumo: valCons,
      total:        total,
      esEstimado:   true,
      tarifas:      t,
    );
  }
}

// ─────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────

class TarifasLocal {
  final double cargoBasico;
  final double tarifaM3;
  final String empresaNombre;
  final String empresaNit;
  final String empresaTelefono;
  final String empresaEmail;
  final String? ultimaSync;

  const TarifasLocal({
    required this.cargoBasico,
    required this.tarifaM3,
    required this.empresaNombre,
    required this.empresaNit,
    required this.empresaTelefono,
    required this.empresaEmail,
    this.ultimaSync,
  });

  bool get tieneDatos => cargoBasico > 0 || tarifaM3 > 0;
}

class ComprobanteCalculo {
  final int consumo;
  final int cargoBasico;
  final int valorConsumo;
  final int total;
  final bool esEstimado;
  final TarifasLocal tarifas;

  const ComprobanteCalculo({
    required this.consumo,
    required this.cargoBasico,
    required this.valorConsumo,
    required this.total,
    required this.esEstimado,
    required this.tarifas,
  });
}