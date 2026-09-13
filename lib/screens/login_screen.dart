// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../models/acueducto.dart';
import '../services/api/api_service.dart';
import '../services/sesion_service.dart';
import '../utils/constantes.dart';

class LoginScreen extends StatefulWidget {
  final void Function(Acueducto acueducto) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioCtrl   = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  final _focusContrasena = FocusNode();

  Acueducto? _acueductoSeleccionado;
  bool _verContrasena = false;
  bool _cargando = false;
  String? _error;
  String? _mensajeExito;

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _contrasenaCtrl.dispose();
    _focusContrasena.dispose();
    super.dispose();
  }

  void _seleccionarAcueducto(Acueducto acueducto) {
    setState(() {
      _acueductoSeleccionado = acueducto;
      _error = null;
      _mensajeExito = null;
      _usuarioCtrl.clear();
      _contrasenaCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _focusContrasena.requestFocus();
    });
  }

  Future<void> _login() async {
    if (_acueductoSeleccionado == null) {
      setState(() => _error = 'Selecciona un acueducto');
      return;
    }
    final usuario = _usuarioCtrl.text.trim();
    if (usuario.isEmpty) {
      setState(() => _error = 'Ingresa tu usuario');
      return;
    }
    final contrasena = _contrasenaCtrl.text.trim();
    if (contrasena.isEmpty) {
      setState(() => _error = 'Ingresa la contraseña');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
      _mensajeExito = null;
    });

    try {
      final acueducto = _acueductoSeleccionado!;
      final api = ApiService(acueducto);

      final resultado = await api.login(usuario, contrasena);

      final token   = resultado['token']   as String?;
      final mensaje = resultado['message'] as String?;

      if (token == null) {
        setState(() {
          _error = mensaje ?? 'Credenciales incorrectas';
          _cargando = false;
        });
        return;
      }

      setState(() => _mensajeExito = mensaje ?? 'Inicio de sesión exitoso');
      await Future.delayed(const Duration(milliseconds: 600));

      await SesionService.guardarSesion(acueducto, token);
      if (mounted) widget.onLogin(acueducto);
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: verifica tu red';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // ── Logo ──────────────────────────────
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/hapinet_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Sistema de Lectura',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Hapinet',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 32),

                // ── Card de login ──────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        'Selecciona tu acueducto',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Botones acueducto ──────────────
                      Row(
                        children: [
                          _botonAcueducto(
                            TipoAcueducto.asoaguapo,
                            'ASOAGUAPO',
                            const Color(0xFF1565C0),
                            Icons.water,
                          ),
                          const SizedBox(width: 10),
                          _botonAcueducto(
                            TipoAcueducto.temporal,
                            'AGUAVIVA',
                            const Color(0xFF2E7D32),
                            Icons.water_drop,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Usuario ────────────────────────
                      TextField(
                        controller: _usuarioCtrl,
                        enabled: _acueductoSeleccionado != null,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _focusContrasena.requestFocus(),
                        decoration: InputDecoration(
                          labelText: 'Usuario',
                          hintText: _acueductoSeleccionado == null
                              ? 'Selecciona un acueducto primero'
                              : 'Ingresa tu usuario',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: _acueductoSeleccionado == null,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Contraseña ─────────────────────
                      TextField(
                        controller: _contrasenaCtrl,
                        focusNode: _focusContrasena,
                        obscureText: !_verContrasena,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        enabled: _acueductoSeleccionado != null,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: _acueductoSeleccionado == null
                              ? 'Selecciona un acueducto primero'
                              : null,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_verContrasena
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _verContrasena = !_verContrasena),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: _acueductoSeleccionado == null,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),

                      // ── Éxito ──────────────────────────
                      if (_mensajeExito != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_mensajeExito!,
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ── Error ──────────────────────────
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_error!,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Botón ingresar ─────────────────
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_cargando ||
                                  _acueductoSeleccionado == null)
                              ? null
                              : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _acueductoSeleccionado?.tipo ==
                                        TipoAcueducto.temporal
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFF0D47A1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Ingresar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'v$kVersion — ${kNombreApp.toUpperCase()}',
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonAcueducto(
    TipoAcueducto tipo,
    String nombre,
    Color color,
    IconData icono,
  ) {
    final acueducto = Acueducto.porTipo(tipo.name);
    if (acueducto == null) return const SizedBox.shrink();
    final seleccionado = _acueductoSeleccionado?.tipo == tipo;

    return Expanded(
      child: GestureDetector(
        onTap: () => _seleccionarAcueducto(acueducto),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: seleccionado ? color : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado ? color : color.withOpacity(0.3),
              width: seleccionado ? 2 : 1,
            ),
            boxShadow: seleccionado
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(icono,
                  color: seleccionado ? Colors.white : color,
                  size: 28),
              const SizedBox(height: 6),
              Text(
                nombre,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: seleccionado ? Colors.white : color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}