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

  static const List<Acueducto> _cuentas = [
    Acueducto(
      tipo: TipoAcueducto.asoaguapo,
      nombre: 'ASOAGUAPO',
      nombreBd: 'bd_asoaguapo',
      colorHex: '#1565C0',
      apiUrl: 'https://hapinet.com.co/api',
    ),
    Acueducto(
      tipo: TipoAcueducto.temporal,
      nombre: 'TEMPORAL',
      nombreBd: 'bd_TEMPORAL',
      colorHex: '#2E7D32',
      apiUrl: 'https://hapinet.com.co/api/temporal',
    ),
  ];

  static Acueducto? porTipo(String tipo) {
    try {
      return _cuentas.firstWhere((c) => c.tipo.name == tipo);
    } catch (_) {
      return null;
    }
  }

  static List<Acueducto> get todos => _cuentas;
}