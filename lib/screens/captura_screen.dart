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
import '../components/captura/guia_encuadre.dart';
import '../components/captura/banner_gps.dart';
import '../components/captura/tarjeta_ocr.dart';
import '../components/captura/tarjeta_gps.dart';
import '../components/captura/selector_estado_medidor.dart';

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
  late final CamaraService _camara;
  late final OcrService _ocr;
  late final GeolocalizacionService _geo;

  EstadoCaptura _estado = EstadoCaptura.iniciando;
  String? _mensajeError;

  FotoResult? _foto;
  OcrResult? _ocrResult;
  PosicionResult? _posicion;

  late TextEditingController _lecturaController;
  final _notasController = TextEditingController();

  bool _flashActivo = false;
  bool _procesando = false;
  String? _estadoMedidor;

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
      if (mounted) {
        setState(() {
          _estado = EstadoCaptura.error;
          _mensajeError = e.mensaje;
        });
      }
    }
  }

  Future<void> _obtenerGps() async {
    try {
      // Primero la última posición conocida (instantánea)
      _posicion = await _geo.obtenerUltimaPosicion();
      if (mounted && _posicion != null) setState(() {});

      // Luego la posición actual (puede tardar hasta 15s)
      final posicionActual = await _geo.obtenerPosicionActual();
      _posicion = posicionActual;
      if (mounted) setState(() {});
    } on GeolocalizacionException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('GPS: ${e.mensaje}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ));
      }
    } catch (e) {
      // Si falla por cualquier razón, la lectura se guarda sin coordenadas
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'No se pudo obtener GPS — la lectura se guardará sin coordenadas'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ));
      }
    }
  }

  /// Reintenta obtener GPS si aún no se tiene al momento de guardar
  Future<void> _reintentarGps() async {
    if (_posicion != null) return;
    setState(() {});
    await _obtenerGps();
  }

  // ─────────────────────────────────────────────
  // FLUJO PRINCIPAL
  // ─────────────────────────────────────────────

  Future<void> _tomarFotoYProcesar() async {
    if (_procesando) return;
    setState(() {
      _procesando = true;
      _estado = EstadoCaptura.tomandoFoto;
    });
    try {
      _foto = await _camara.tomarFoto(codigoMedidor: widget.codigoMedidor);
      setState(() => _estado = EstadoCaptura.procesandoOcr);
      _ocrResult = await _ocr.leerMedidor(_foto!.rutaLocal);
      if (_ocrResult!.esExitoso) {
        _lecturaController.text = _ocrResult!.lectura.toString();
      }
      setState(() => _estado = EstadoCaptura.confirmando);
    } catch (e) {
      setState(() {
        _estado = EstadoCaptura.error;
        _mensajeError = 'Error: $e';
      });
    } finally {
      setState(() => _procesando = false);
    }
  }

  Future<void> _guardarLectura() async {
    final texto = _lecturaController.text.trim();
    if (texto.isEmpty) {
      _snack('Ingresa el número del medidor');
      return;
    }
    final numeroFinal = int.tryParse(texto);
    if (numeroFinal == null) {
      _snack('El valor debe ser un número entero');
      return;
    }
    final notas = _notasController.text.trim();
    if (numeroFinal == 0 && notas.isEmpty) {
      _snack(
        'Lectura 0: debes escribir una observación explicando por qué no se pudo leer',
        color: Colors.orange,
        duracion: 4,
      );
      return;
    }

    setState(() => _procesando = true);
    try {
      // Si aún no hay GPS, intentar una última vez antes de guardar
      if (_posicion == null) await _reintentarGps();
      if (widget.codigoMedidor != null) {
        await widget.db.actualizarLecturaAbonado(
          codigoMedidor: widget.codigoMedidor!,
          nuevaLectura: numeroFinal,
          rutaFoto: _foto?.rutaLocal ?? '',
          latitud: _posicion?.latitud ?? 0.0,
          longitud: _posicion?.longitud ?? 0.0,
          textoCrudo: _ocrResult?.textoCrudo,
          notas: notas.isEmpty ? null : notas,
          estadoMedidor: _estadoMedidor,
        );
      } else {
        await widget.db.insertarLectura(
          LecturasCompanion.insert(
            id: const Uuid().v4(),
            lectura: numeroFinal,
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
          ),
        );
        if (_posicion != null) {
          await _geo.guardarPosicionParaLectura(_posicion!, '');
        }
      }

      if (mounted) {
        _snack(
          numeroFinal == 0
              ? '✓ Registrado sin lectura — observación guardada'
              : '✓ Lectura $numeroFinal guardada correctamente',
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
    _foto = null;
    _ocrResult = null;
    _lecturaController.clear();
    _notasController.clear();
    setState(() {
      _estado = EstadoCaptura.listo;
      _estadoMedidor = null;
    });
  }

  void _snack(String mensaje, {Color? color, int duracion = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(mensaje),
      backgroundColor: color,
      duration: Duration(seconds: duracion),
    ));
  }

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
              icon: Icon(
                  _flashActivo ? Icons.flash_on : Icons.flash_off),
              onPressed: () async {
                await _camara.toggleFlash();
                setState(() => _flashActivo = !_flashActivo);
              },
            ),
        ],
      ),
      body: switch (_estado) {
        EstadoCaptura.iniciando =>
          _buildCargando('Iniciando cámara...'),
        EstadoCaptura.listo => _buildVistaPrevia(),
        EstadoCaptura.tomandoFoto =>
          _buildCargando('Capturando foto...'),
        EstadoCaptura.procesandoOcr =>
          _buildCargando('Leyendo medidor (offline)...'),
        EstadoCaptura.confirmando => _buildConfirmacion(),
        EstadoCaptura.error => _buildError(),
      },
    );
  }

  // ─────────────────────────────────────────────
  // VISTA PREVIA (CÁMARA)
  // ─────────────────────────────────────────────

  Widget _buildVistaPrevia() {
    if (!_camara.estaInicializado || _camara.controller == null) {
      return _buildCargando('Preparando cámara...');
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTapUp: (details) {
            final size = MediaQuery.of(context).size;
            _camara.enfocarEn(
              details.localPosition.dx / size.width,
              details.localPosition.dy / size.height,
            );
          },
          child: CameraPreview(_camara.controller!),
        ),
        const GuiaEncuadre(),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: BannerGps(posicion: _posicion),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(child: _botonCaptura()),
        ),
      ],
    );
  }

  Widget _botonCaptura() {
    return GestureDetector(
      onTap: _tomarFotoYProcesar,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          color: Colors.white24,
        ),
        child:
            const Icon(Icons.camera_alt, color: Colors.white, size: 36),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CONFIRMACIÓN
  // ─────────────────────────────────────────────

  Widget _buildConfirmacion() {
    return Column(
      children: [
        // ── Contenido scrolleable ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto tomada
                if (_foto != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_foto!.rutaLocal),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),

                // Resultado OCR
                TarjetaOcr(ocrResult: _ocrResult),
                const SizedBox(height: 16),

                // Campo número
                const Text('Número del medidor',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _campoNumero(),
                const SizedBox(height: 16),

                // GPS
                TarjetaGps(
                  posicion: _posicion,
                  geo: _geo,
                  onReintentar:
                      _posicion == null ? _reintentarGps : null,
                ),
                const SizedBox(height: 16),

                // Estado del medidor
                SelectorEstadoMedidor(
                  estadoSeleccionado: _estadoMedidor,
                  onCambio: (clave) =>
                      setState(() => _estadoMedidor = clave),
                ),
                const SizedBox(height: 12),

                // Notas / observaciones
                _campoNotas(),

                // Espacio para que el teclado no tape el campo de notas
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // ── Botones FIJOS en la parte inferior ──
        Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          child: _botonesAccion(),
        ),
      ],
    );
  }

  Widget _campoNumero() {
    return TextField(
      controller: _lecturaController,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 4,
      ),
      decoration: InputDecoration(
        hintText: 'Ej: 012345',
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }

  Widget _campoNotas() {
    final borde = BorderSide(
      color: _esLecturaCero
          ? Colors.orange.withOpacity(0.5)
          : Colors.white24,
    );
    return TextField(
      controller: _notasController,
      style: const TextStyle(color: Colors.white),
      maxLines: 2,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: _esLecturaCero
            ? '⚠ Observación obligatoria: ¿por qué no se pudo leer?'
            : 'Notas del técnico (opcional)',
        hintStyle: TextStyle(
          color:
              _esLecturaCero ? Colors.orange.shade300 : Colors.white30,
          fontSize: 12,
        ),
        filled: true,
        fillColor: _esLecturaCero
            ? Colors.orange.withOpacity(0.1)
            : Colors.white10,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: borde),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: borde),
      ),
    );
  }

  Widget _botonesAccion() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _reiniciar,
            icon: const Icon(Icons.refresh, color: Colors.white70),
            label: const Text('Repetir',
                style: TextStyle(color: Colors.white70)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _procesando ? null : _guardarLectura,
            icon: _procesando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            label: Text(
                _procesando ? 'Guardando...' : 'Guardar lectura'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // ESTADOS GENÉRICOS
  // ─────────────────────────────────────────────

  Widget _buildCargando(String mensaje) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(mensaje,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _mensajeError ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }
}

enum EstadoCaptura {
  iniciando,
  listo,
  tomandoFoto,
  procesandoOcr,
  confirmando,
  error,
}