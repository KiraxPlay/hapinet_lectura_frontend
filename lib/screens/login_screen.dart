// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../models/acueducto.dart';
import '../services/sesion_service.dart';
import '../utils/constantes.dart';

class LoginScreen extends StatefulWidget {
  final void Function(Acueducto acueducto) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _contrasenaCtrl = TextEditingController();
  final _focusContrasena = FocusNode();

  Acueducto? _acueductoSeleccionado;
  bool _verContrasena = false;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _contrasenaCtrl.dispose();
    _focusContrasena.dispose();
    super.dispose();
  }

  void _seleccionarAcueducto(Acueducto acueducto) {
    setState(() {
      _acueductoSeleccionado = acueducto;
      _error = null;
      _contrasenaCtrl.clear();
    });
    // Enfocar campo de contraseña automáticamente
    Future.delayed(const Duration(milliseconds: 200), () {
      _focusContrasena.requestFocus();
    });
  }

  Future<void> _login() async {
    if (_acueductoSeleccionado == null) {
      setState(() => _error = 'Selecciona un acueducto');
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
    });

    await Future.delayed(const Duration(milliseconds: 200));

    final acueducto = Acueducto.login(
      _acueductoSeleccionado!.usuario,
      contrasena,
    );

    if (acueducto == null) {
      setState(() {
        _error = 'Contraseña incorrecta';
        _cargando = false;
      });
      return;
    }

    await SesionService.guardarSesion(acueducto);
    if (mounted) widget.onLogin(acueducto);
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

                      // ── Botones de selección de acueducto ──
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
                            TipoAcueducto.aguaviva,
                            'AGUAVIVA',
                            const Color(0xFF2E7D32),
                            Icons.water_drop,
                          ),
                        ],
                      ),

                      // ── Usuario precargado ─────────────────
                      if (_acueductoSeleccionado != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 10),
                              Text(
                                _acueductoSeleccionado!.usuario,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.lock_outline,
                                  size: 14, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      // ── Contraseña ─────────────────────────
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
                          prefixIcon:
                              const Icon(Icons.lock_outline),
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

                      // ── Error ──────────────────────────────
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
                              Text(_error!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Botón ingresar ─────────────────────
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
                                        TipoAcueducto.aguaviva
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
                  color: seleccionado ? Colors.white : color, size: 28),
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