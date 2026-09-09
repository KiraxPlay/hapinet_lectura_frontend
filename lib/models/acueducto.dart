enum TipoAcueducto { asoaguapo, aguaviva }

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
      apiUrl: 'http://192.168.18.8:8000/api',
    ),
    Acueducto(
      tipo: TipoAcueducto.aguaviva,
      nombre: 'AGUAVIVA',
      nombreBd: 'bd_aguaviva',
      colorHex: '#2E7D32',
      apiUrl: 'http://192.168.18.8:8000/api/aguaviva/',
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