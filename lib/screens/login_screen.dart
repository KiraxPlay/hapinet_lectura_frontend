// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../models/acueducto.dart';
import '../services/sesion_service.dart';

class LoginScreen extends StatefulWidget {
  // Callback que se llama con el acueducto cuando el login es exitoso
  final void Function(Acueducto acueducto) onLogin;

  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  bool _verContrasena = false;
  bool _cargando = false;
  String? _error;

  Future<void> _login() async {
    final usuario = _usuarioCtrl.text.trim();
    final contrasena = _contrasenaCtrl.text.trim();

    if (usuario.isEmpty || contrasena.isEmpty) {
      setState(() => _error = 'Ingresa usuario y contraseña');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    // Pequeña pausa para que el loading se vea
    await Future.delayed(const Duration(milliseconds: 300));

    final acueducto = Acueducto.login(usuario, contrasena);

    if (acueducto == null) {
      setState(() {
        _error = 'Creentiales inválidas';
        _cargando = false;
      });
      return;
    }

    // Guardar sesión y navegar
    await SesionService.guardarSesion(acueducto);
    if (mounted) widget.onLogin(acueducto);
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
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
                // ── Logo ──────────────────────────────────
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

                // ── Título ────────────────────────────────
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 40),

                // ── Card de login ─────────────────────────
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
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D47A1),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Usuario
                      TextField(
                        controller: _usuarioCtrl,
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Contraseña
                      TextField(
                        controller: _contrasenaCtrl,
                        obscureText: !_verContrasena,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
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
                        ),
                      ),

                      // Error
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _error!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Botón
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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

                // Versión
                const Text(
                  'v1.0.0 — Hapinet',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}