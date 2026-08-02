// lib/screens/captura_screen.dart
// Pantalla principal de captura — orquesta cámara, OCR, GPS y guardado
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;

import '../data/database.dart';
import '../models/foto_result.dart';
import '../models/ocr_result.dart';
import '../models/posicion_result.dart';
import '../services/camara_service.dart';
import '../services/ocr_service.dart';
import '../services/geolocalizacion_service.dart';
import '../services/asr_service.dart';
import '../components/captura/guia_encuadre.dart';
import '../components/captura/banner_gps.dart';
import '../components/captura/tarjeta_ocr.dart';
import '../components/captura/tarjeta_gps.dart';
import '../components/captura/selector_estado_medidor.dart';
import '../components/captura/campo_notas_asr.dart';
import '../components/captura/botones_confirmacion.dart';
import '../components/captura/confirmacion_captura.dart';
import '../components/captura/aviso_offline_asr.dart';

enum EstadoCaptura {
  iniciando, listo, tomandoFoto, procesandoOcr, confirmando, error
}

class CapturaScreen extends StatefulWidget {
  final AppDatabase db;
  final String? codigoMedidor;
  final String? nombreAbonado;
  final int? lecturaAnterior;
  final double? latitudReferencia;
  final double? longitudReferencia;

  const CapturaScreen({
    super.key,
    required this.db,
    this.codigoMedidor,
    this.nombreAbonado,
    this.lecturaAnterior,
    this.latitudReferencia,
    this.longitudReferencia,
  });

  @override
  State<CapturaScreen> createState() => _CapturaScreenState();
}

class _CapturaScreenState extends State<CapturaScreen>
    with WidgetsBindingObserver {

  // ── Servicios ──
  late final CamaraService _camara;
  late final OcrService _ocr;
  late final GeolocalizacionService _geo;
  final _asr = AsrService.instancia;

  // ── Estado de la pantalla ──
  EstadoCaptura _estado = EstadoCaptura.iniciando;
  String? _mensajeError;

  // ── Resultados de captura ──
  FotoResult? _foto;
  OcrResult? _ocrResult;
  PosicionResult? _posicion;

  // ── Controladores de formulario ──
  late TextEditingController _lecturaController;
  final _notasController = TextEditingController();

  // ── Estado del formulario ──
  bool _flashActivo = false;
  bool _procesando = false;
  String? _estadoMedidor;

  // ── ASR ──
  bool _asrDisponible = false;
  String? _campoEscuchando;
  StreamSubscription<AsrResultado>? _asrSub;
  double _nivelVolumen = 0.0;

  // ─────────────────────────────────────────────
  // CICLO DE VIDA
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lecturaController = TextEditingController();
    _camara = CamaraService();
    _ocr = OcrService();
    _geo = GeolocalizacionService(widget.db);
    _inicializar();
    _asrDisponible = _asr.inicializado;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_camara.estaInicializado) return;
    if (state == AppLifecycleState.inactive) {
      _camara.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _inicializarCamara();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camara.dispose();
    _ocr.dispose();
    _asrSub?.cancel();
    _asr.detener();
    _lecturaController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // INICIALIZACIÓN
  // ─────────────────────────────────────────────

  Future<void> _inicializar() async {
    await Future.wait([_inicializarCamara(), _obtenerGps()]);
  }

  Future<void> _inicializarCamara() async {
    try {
      await _camara.inicializar();
      if (mounted) setState(() => _estado = EstadoCaptura.listo);
    } on CamaraException catch (e) {
      if (mounted) setState(() {
        _estado = EstadoCaptura.error;
        _mensajeError = e.mensaje;
      });
    }
  }

  Future<void> _obtenerGps() async {
    try {
      _posicion = await _geo.obtenerUltimaPosicion();
      if (mounted && _posicion != null) setState(() {});
      _posicion = await _geo.obtenerPosicionActual();
      if (mounted) setState(() {});
    } on GeolocalizacionException catch (e) {
      if (mounted) _snack('GPS: ${e.mensaje}', color: Colors.orange);
    } catch (_) {
      if (mounted) _snack(
        'No se pudo obtener GPS — se guardará sin coordenadas',
        color: Colors.orange,
      );
    }
  }

  Future<void> _reintentarGps() async {
    if (_posicion != null) return;
    setState(() {});
    await _obtenerGps();
  }

  // ─────────────────────────────────────────────
  // ASR — maneja campo 'lectura' y 'notas'
  // Al presionar de nuevo → borra y reemplaza
  // ─────────────────────────────────────────────

  Future<void> _toggleAsr(String campo) async {
    // Si ya está escuchando el mismo campo → detener
    if (_campoEscuchando == campo) {
      await _asr.detener();
      await _asrSub?.cancel();
      if (mounted) setState(() => _campoEscuchando = null);
      return;
    }

    // Si está escuchando otro campo → detener primero
    if (_campoEscuchando != null) {
      await _asr.detener();
      await _asrSub?.cancel();
    }

    // Mostrar aviso offline la primera vez si no tiene español descargado
    if (mounted && await _asr.debesMostrarAvisoOffline()) {
      await mostrarAvisoOfflineAsr(context);
      await _asr.marcarAvisoOfflineVisto();
    }

    // Limpiar el campo ANTES de empezar — siempre reemplaza
    if (campo == 'lectura') {
      _lecturaController.clear();
    } else {
      _notasController.clear();
    }

    if (mounted) setState(() => _campoEscuchando = campo);

    _asrSub = _asr.escuchar().listen(
      (resultado) {
        if (!mounted) return;
        // Actualizar nivel de volumen siempre
        setState(() => _nivelVolumen = resultado.nivelVolumen);

        if (resultado.texto.isEmpty) return;
        final textoNuevo = resultado.texto;

        if (campo == 'lectura') {
          final numero = _palabrasANumero(textoNuevo);
          _lecturaController.text = numero;
          _lecturaController.selection = TextSelection.fromPosition(
            TextPosition(offset: numero.length),
          );
          if (resultado.esFinal) setState(() { _campoEscuchando = null; _nivelVolumen = 0.0; });
        } else {
          _notasController.text = textoNuevo;
          _notasController.selection = TextSelection.fromPosition(
            TextPosition(offset: textoNuevo.length),
          );
          if (resultado.esFinal) setState(() { _campoEscuchando = null; _nivelVolumen = 0.0; });
        }
      },
      onDone: () { if (mounted) setState(() { _campoEscuchando = null; _nivelVolumen = 0.0; }); },
      onError: (_) { if (mounted) setState(() { _campoEscuchando = null; _nivelVolumen = 0.0; }); },
    );
  }

  // Convierte palabras numéricas a dígitos
  // "cero uno dos tres cuatro" → "01234"
  String _palabrasANumero(String texto) {
    const mapa = {
      'cero': '0', 'uno': '1', 'dos': '2', 'tres': '3',
      'cuatro': '4', 'cinco': '5', 'seis': '6', 'siete': '7',
      'ocho': '8', 'nueve': '9',
    };
    // Si ya es número, devolverlo tal cual
    if (RegExp(r'^\d+$').hasMatch(texto.trim())) return texto.trim();
    // Convertir palabras a dígitos
    final palabras = texto.toLowerCase().trim().split(RegExp(r'\s+'));
    final digitos = palabras.map((p) => mapa[p] ?? p).join('');
    // Si el resultado tiene dígitos, retornarlo; si no, el original
    return RegExp(r'\d').hasMatch(digitos) ? digitos : texto.trim();
  }

  // ─────────────────────────────────────────────
  // FLUJO PRINCIPAL
  // ─────────────────────────────────────────────

  Future<void> _tomarFotoYProcesar() async {
    if (_procesando) return;
    setState(() { _procesando = true; _estado = EstadoCaptura.tomandoFoto; });
    try {
      _foto = await _camara.tomarFoto(codigoMedidor: widget.codigoMedidor);
      setState(() => _estado = EstadoCaptura.procesandoOcr);
      _ocrResult = await _ocr.leerMedidor(_foto!.rutaLocal);
      if (_ocrResult!.esExitoso) {
        _lecturaController.text = _ocrResult!.lectura.toString();
      }
      setState(() => _estado = EstadoCaptura.confirmando);
    } catch (e) {
      setState(() { _estado = EstadoCaptura.error; _mensajeError = 'Error: $e'; });
    } finally {
      setState(() => _procesando = false);
    }
  }

  Future<void> _guardarLectura() async {
    final texto = _lecturaController.text.trim();
    if (texto.isEmpty) { _snack('Ingresa el número del medidor'); return; }
    final numero = int.tryParse(texto);
    if (numero == null) { _snack('El valor debe ser un número entero'); return; }
    final notas = _notasController.text.trim();
    if (numero == 0 && notas.isEmpty) {
      _snack('Lectura 0: debes escribir una observación', color: Colors.orange, duracion: 4);
      return;
    }

    setState(() => _procesando = true);
    try {
      if (_posicion == null) await _reintentarGps();
      if (widget.codigoMedidor != null) {
        await widget.db.actualizarLecturaAbonado(
          codigoMedidor: widget.codigoMedidor!,
          nuevaLectura: numero,
          rutaFoto: _foto?.rutaLocal ?? '',
          latitud: _posicion?.latitud ?? 0.0,
          longitud: _posicion?.longitud ?? 0.0,
          textoCrudo: _ocrResult?.textoCrudo,
          notas: notas.isEmpty ? null : notas,
          estadoMedidor: _estadoMedidor,
        );
      } else {
        await widget.db.insertarLectura(LecturasCompanion.insert(
          id: const Uuid().v4(),
          lectura: numero,
          textoCrudo: _ocrResult?.textoCrudo ?? '',
          rutaFoto: _foto?.rutaLocal ?? '',
          latitud: _posicion?.latitud ?? 0.0,
          longitud: _posicion?.longitud ?? 0.0,
          altitud: Value(_posicion?.altitud),
          precision: Value(_posicion?.precision),
          fechaLectura: DateTime.now(),
          codigoMedidor: const Value(null),
          notas: Value(notas.isEmpty ? null : notas),
          tieneLecturaReal: const Value(true),
        ));
        if (_posicion != null) await _geo.guardarPosicionParaLectura(_posicion!, '');
      }
      if (mounted) {
        _snack(
          numero == 0 ? '✓ Registrado sin lectura' : '✓ Lectura $numero guardada',
          color: Colors.green,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) _snack('Error al guardar: $e');
    } finally {
      setState(() => _procesando = false);
    }
  }

  void _reiniciar() {
    _foto = null; _ocrResult = null;
    _lecturaController.clear(); _notasController.clear();
    setState(() { _estado = EstadoCaptura.listo; _estadoMedidor = null; });
  }

  void _snack(String msg, {Color? color, int duracion = 3}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), backgroundColor: color,
        duration: Duration(seconds: duracion),
      ));

  bool get _esLecturaCero {
    final v = int.tryParse(_lecturaController.text.trim());
    return v != null && v == 0;
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.nombreAbonado ?? 'Capturar medidor'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_estado == EstadoCaptura.listo)
            IconButton(
              icon: Icon(_flashActivo ? Icons.flash_on : Icons.flash_off),
              onPressed: () async {
                await _camara.toggleFlash();
                setState(() => _flashActivo = !_flashActivo);
              },
            ),
        ],
      ),
      body: switch (_estado) {
        EstadoCaptura.iniciando    => _buildCargando('Iniciando cámara...'),
        EstadoCaptura.listo        => _buildVistaPrevia(),
        EstadoCaptura.tomandoFoto  => _buildCargando('Capturando foto...'),
        EstadoCaptura.procesandoOcr => _buildCargando('Leyendo medidor (offline)...'),
        EstadoCaptura.confirmando  => _buildConfirmacion(),
        EstadoCaptura.error        => _buildError(),
      },
    );
  }

  // ─────────────────────────────────────────────
  // VISTA PREVIA
  // ─────────────────────────────────────────────

  Widget _buildVistaPrevia() {
    if (!_camara.estaInicializado || _camara.controller == null) {
      return _buildCargando('Preparando cámara...');
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTapUp: (d) {
            final s = MediaQuery.of(context).size;
            _camara.enfocarEn(d.localPosition.dx / s.width, d.localPosition.dy / s.height);
          },
          child: CameraPreview(_camara.controller!),
        ),
        const GuiaEncuadre(),
        Positioned(top: 12, left: 12, right: 12, child: BannerGps(posicion: _posicion)),
        Positioned(
          bottom: 40, left: 0, right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _tomarFotoYProcesar,
              child: Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: Colors.white24,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 36),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // CONFIRMACIÓN — delegado a ConfirmacionCaptura
  // ─────────────────────────────────────────────

  Widget _buildConfirmacion() => ConfirmacionCaptura(
    foto: _foto,
    ocrResult: _ocrResult,
    posicion: _posicion,
    geo: _geo,
    lecturaController: _lecturaController,
    notasController: _notasController,
    estadoMedidor: _estadoMedidor,
    esLecturaCero: _esLecturaCero,
    procesando: _procesando,
    asrDisponible: _asrDisponible,
    campoEscuchando: _campoEscuchando,
    nivelVolumen: _nivelVolumen,
    onToggleAsr: _toggleAsr,
    onReiniciar: _reiniciar,
    onGuardar: _guardarLectura,
    onReintentar: _reintentarGps,
    onChanged: () => setState(() {}),
    onCambioEstado: (clave, poneLecturaEnCero) {
      setState(() {
        _estadoMedidor = clave;
        if (poneLecturaEnCero) _lecturaController.text = '0';
      });
    },
  );

  Widget _buildCargando(String mensaje) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(color: Colors.white),
      const SizedBox(height: 16),
      Text(mensaje, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    ]),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 48),
        const SizedBox(height: 16),
        Text(_mensajeError ?? 'Error desconocido',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Volver'),
        ),
      ]),
    ),
  );
}