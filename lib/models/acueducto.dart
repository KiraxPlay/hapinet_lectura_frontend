// lib/models/acueducto.dart

// Define los acueductos disponibles en la app
// Para agregar uno nuevo: añadir entrada al enum y a la lista _cuentas
enum TipoAcueducto { asoaguapo, aguaviva }

class Acueducto {
  final TipoAcueducto tipo;
  final String nombre;        // Nombre visible en la UI
  final String usuario;       // Login
  final String contrasena;    // Contraseña
  final String jsonAsset;     // Ruta del JSON en assets
  final String nombreBd;      // Nombre del archivo SQLite
  final String colorHex;      // Color principal de la app al iniciar sesión

  const Acueducto({
    required this.tipo,
    required this.nombre,
    required this.usuario,
    required this.contrasena,
    required this.jsonAsset,
    required this.nombreBd,
    required this.colorHex,
  });

  // ── Cuentas registradas ──────────────────────────────────────
  // Credenciales hardcodeadas — no se envían a ningún servidor
  static const List<Acueducto> _cuentas = [
    Acueducto(
      tipo: TipoAcueducto.asoaguapo,
      nombre: 'ASOAGUAPO',
      usuario: 'asoaguapo',
      contrasena: 'asoaguapo2026',
      jsonAsset: 'assets/abonados_asoaguapo.json',
      nombreBd: 'bd_asoaguapo',
      colorHex: '#1565C0', // Azul
    ),
    Acueducto(
      tipo: TipoAcueducto.aguaviva,
      nombre: 'AGUAVIVA',
      usuario: 'aguaviva',
      contrasena: 'aguaviva',
      jsonAsset: 'assets/abonados_aguaviva.json',
      nombreBd: 'bd_aguaviva',
      colorHex: '#2E7D32', // Verde
    ),
  ];

  // Busca la cuenta por usuario y contraseña
  // Retorna null si no coincide ninguna
  static Acueducto? login(String usuario, String contrasena) {
    try {
      return _cuentas.firstWhere(
        (c) =>
            c.usuario == usuario.trim().toLowerCase() &&
            c.contrasena == contrasena.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  // Busca por tipo (para restaurar sesión guardada)
  static Acueducto? porTipo(String tipo) {
    try {
      return _cuentas.firstWhere((c) => c.tipo.name == tipo);
    } catch (_) {
      return null;
    }
  }
}