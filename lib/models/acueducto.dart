import 'package:flutter_dotenv/flutter_dotenv.dart';

enum TipoAcueducto { asoaguapo, temporal }

class Acueducto {
  final TipoAcueducto tipo;
  final String nombre;
  final String nombreBd;
  final String colorHex;
  final String apiUrl;

  const Acueducto({
    required this.tipo,
    required this.nombre,
    required this.nombreBd,
    required this.colorHex,
    required this.apiUrl,
  });

  static String get _apiUrlDesdeEnv {
    try {
      return dotenv.env['API_URL'] ?? 'https://hapinet.com.co/api';
    } catch (_) {
      return 'https://hapinet.com.co/api';
    }
  }

  static Acueducto get activo {
    return Acueducto(
      tipo: TipoAcueducto.asoaguapo,
      nombre: 'ASOAGUAPO',
      nombreBd: 'bd_asoaguapo',
      colorHex: '#1565C0',
      apiUrl: _apiUrlDesdeEnv,
    );
  }

  static List<Acueducto> get _cuentas => [activo];

  static Acueducto get predeterminado => activo;

  static Acueducto? porTipo(String tipo) {
    try {
      return _cuentas.firstWhere((c) => c.tipo.name == tipo);
    } catch (_) {
      return _cuentas.isNotEmpty ? _cuentas.first : null;
    }
  }

  static List<Acueducto> get todos => _cuentas;
}