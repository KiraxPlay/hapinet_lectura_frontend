// lib/screens/captura_screen.dart
// Pantalla principal de captura — orquesta cámara, OCR, GPS y guardado
import 'dart:async';
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
import '../components/captura/confirmacion_captura.dart';
import '../models/acueducto.dart';
import '../services/captura_facturacion_service.dart';
import '../services/exportar_pdf.dart';
import '../models/alerta_lectura.dart';
import '../components/captura/dialogo_alerta_lectura.dart';
import 'visor_pdf_screen.dart';

enum EstadoCaptura {
  iniciando,
  listo,
  tomandoFoto,
  procesandoOcr,
  confirmando,
  error,
}

class CapturaScreen extends StatefulWidget {
  final AppDatabase db;
  final Acueducto acueducto;
  final String? codigoMedidor;
  final String? nombreAbonado;
  final int? lecturaAnterior;
  final double? latitudReferencia;
  final double? longitudReferencia;
  final int? predioId; // ID del predio en Laravel para facturación en sitio

  const CapturaScreen({
    super.key,
    required this.db,
    required this.acueducto,
    this.codigoMedidor,
    this.nombreAbonado,
    this.lecturaAnterior,
    this.latitudReferencia,
    this.longitudReferencia,
    this.predioId,
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
  final _capturaFacturacion = CapturaFacturacionService();
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
  bool _lecturaGuardada = false;
  bool _facturandoEnSitio = false;
  OpcionFacturacion? _opcionFacturacion;

  // ── ASR Whisper (offline) ──
  bool _asrDisponible = false;
  String? _campoEscuchando; // 'lectura' | 'notas' | null
  String? _campoTranscribiendo; // 'lectura' | 'notas' | null
  double _nivelVolumen = 0.0;
  Timer? _timerVolumen;

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
    _asrDisponible = _asr.listo;

    // Si Whisper aún está descargando en background,
    // revisar cada 3 segundos hasta que esté listo
    if (!_asrDisponible) {
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return false;
        if (_asr.listo) {
          setState(() => _asrDisponible = true);
          return false; // detener el loop
        }
        return true; // seguir revisando
      });
    }
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
    _timerVolumen?.cancel();
    _asr.cancelar();
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
      if (mounted)
        setState(() {
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
      if (mounted)
        _snack(
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
    if (_campoTranscribiendo != null) return;

    if (_campoEscuchando == campo) {
      await _finalizarGrabacionAsr(campo);
      return;
    }

    if (_campoEscuchando != null) {
      _timerVolumen?.cancel();
      await _asr.cancelar();
    }

    _limpiarCampoAntesDeGrabar(campo);

    final iniciado = await _asr.iniciarGrabacion();
    if (!iniciado) return;

    if (mounted) {
      setState(() {
        _campoEscuchando = campo;
        _nivelVolumen = 0.0;
      });
    }

    _timerVolumen = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted || _campoEscuchando == null) return;
      setState(() => _nivelVolumen = (_nivelVolumen + 2.5) % 10.0);
    });
  }

  Future<void> _finalizarGrabacionAsr(String campo) async {
    _timerVolumen?.cancel();
    final campoQueTranscribe = campo;

    if (mounted) {
      setState(() {
        _campoEscuchando = null;
        _campoTranscribiendo = campoQueTranscribe;
        _nivelVolumen = 0.0;
      });
    }

    final resultado = await _asr.detenerYTranscribir();
    final texto = resultado?.texto;

    if (mounted && texto != null && texto.isNotEmpty) {
      _aplicarTextoAsr(campo: campo, texto: texto);
    }

    if (mounted) setState(() => _campoTranscribiendo = null);
  }

  void _limpiarCampoAntesDeGrabar(String campo) {
    if (campo == 'lectura') {
      _lecturaController.clear();
    } else {
      _notasController.clear();
    }
  }

  void _aplicarTextoAsr({required String campo, required String texto}) {
    if (campo == 'lectura') {
      final numero = _palabrasANumero(texto);
      _lecturaController.text = numero;
      _lecturaController.selection = TextSelection.fromPosition(
        TextPosition(offset: numero.length),
      );
      return;
    }

    _notasController.text = texto;
    _notasController.selection = TextSelection.fromPosition(
      TextPosition(offset: texto.length),
    );
  }

  // Convierte palabras numéricas a dígitos
  // "cero uno dos tres cuatro" → "01234"
  String _palabrasANumero(String texto) {
    const mapa = {
      'cero': '0',
      'uno': '1',
      'dos': '2',
      'tres': '3',
      'cuatro': '4',
      'cinco': '5',
      'seis': '6',
      'siete': '7',
      'ocho': '8',
      'nueve': '9',
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
    final numero = int.tryParse(texto);
    if (numero == null) {
      _snack('El valor debe ser un número entero');
      return;
    }
    final notas = _notasController.text.trim();
    if (numero == 0 && notas.isEmpty) {
      _snack(
        'Lectura 0: debes escribir una observación',
        color: Colors.orange,
        duracion: 4,
      );
      return;
    }

    // ── Detectar alertas ───────────────────────
    final alerta = DetectorAlertas.detectar(
      lecturaActual: numero,
      lecturaAnterior: widget.lecturaAnterior,
    );
    if (alerta != null && mounted) {
      final opcion = await mostrarDialogoAlerta(
        context: context,
        alerta: alerta,
        lecturaActual: numero,
        lecturaAnterior: widget.lecturaAnterior,
      );
      if (opcion == null) return; // técnico quiere corregir
      _opcionFacturacion = opcion;
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
          tipoFacturacion: _opcionFacturacion?.errorId,
        );
      } else {
        await widget.db.insertarLectura(
          LecturasCompanion.insert(
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
          ),
        );
        if (_posicion != null)
          await _geo.guardarPosicionParaLectura(_posicion!, '');
      }
      if (mounted) {
        _snack(
          numero == 0
              ? '✓ Registrado sin lectura'
              : '✓ Lectura $numero guardada',
          color: Colors.green,
        );
        // Si tiene predioId → mostrar botón de facturar en sitio
        if (widget.predioId != null) {
          setState(() => _lecturaGuardada = true);
        } else {
          Navigator.of(context).pop(true);
        }
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

  Future<void> _facturarEnSitio() async {
    if (widget.predioId == null) return;
    setState(() => _facturandoEnSitio = true);
    try {
      final facturacion = await _capturaFacturacion.facturar(
        db: widget.db,
        acueducto: widget.acueducto,
        codigoMedidor: widget.codigoMedidor ?? '',
        predioId: widget.predioId!,
      );
      if (facturacion == null) {
        _snack('No se encontró la lectura guardada');
        return;
      }

      final novedades = await widget.db.obtenerNovedadesPredio(
        widget.predioId!,
      );
      final rutaPdf = await ExportarPdfService(
        widget.db,
        acueducto: widget.acueducto,
      ).exportarFacturaAbonado(
        facturacion.lectura,
        novedades: novedades,
        resultado: facturacion.resultado,
      );

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => VisorPdfScreen(
                rutaPdf: rutaPdf,
                titulo:
                    facturacion.resultado.esOficial
                        ? 'Factura N° ${facturacion.resultado.facturaNumero}'
                        : 'Comprobante estimado',
                lectura: facturacion.lectura,
                db: widget.db,
                acueducto: widget.acueducto,
                predioId: widget.predioId,
                lecturaId: facturacion.lectura.id,
                novedades: novedades,
                totalAPagar: facturacion.resultado.total,
                esOficial: facturacion.resultado.esOficial,
                facturaNumero: facturacion.resultado.facturaNumero,
              ),
        ),
      );
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _facturandoEnSitio = false);
    }
  }

  void _snack(String msg, {Color? color, int duracion = 3}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          duration: Duration(seconds: duracion),
        ),
      );

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
        actions: _buildAppBarActions(),
      ),
      body: switch (_estado) {
        EstadoCaptura.iniciando => _buildCargando('Iniciando cámara...'),
        EstadoCaptura.listo => _buildVistaPrevia(),
        EstadoCaptura.tomandoFoto => _buildCargando('Capturando foto...'),
        EstadoCaptura.procesandoOcr => _buildCargando(
          'Leyendo medidor (offline)...',
        ),
        EstadoCaptura.confirmando => _buildConfirmacion(),
        EstadoCaptura.error => _buildError(),
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_estado != EstadoCaptura.listo) return const [];

    return [
      IconButton(
        icon: Icon(_flashActivo ? Icons.flash_on : Icons.flash_off),
        onPressed: () async {
          await _camara.toggleFlash();
          setState(() => _flashActivo = !_flashActivo);
        },
      ),
    ];
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
            _camara.enfocarEn(
              d.localPosition.dx / s.width,
              d.localPosition.dy / s.height,
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
          child: _buildBotonCaptura(),
        ),
      ],
    );
  }

  Widget _buildBotonCaptura() {
    return Center(
      child: GestureDetector(
        onTap: _tomarFotoYProcesar,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            color: Colors.white24,
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CONFIRMACIÓN — delegado a ConfirmacionCaptura
  // ─────────────────────────────────────────────

  Widget _buildConfirmacion() {
    // Si la lectura ya se guardó y tiene predioId → mostrar opción de facturar
    if (_lecturaGuardada && widget.predioId != null) {
      return _buildPantallaPostGuardado();
    }
    return _buildFormularioCaptura();
  }

  Widget _buildPantallaPostGuardado() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Lectura guardada',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildBotonFacturar(),
            const SizedBox(height: 12),
            _buildBotonVolverSinFacturar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonFacturar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _facturandoEnSitio ? null : _facturarEnSitio,
        icon:
            _facturandoEnSitio
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Icon(Icons.receipt_long),
        label: Text(
          _facturandoEnSitio ? 'Generando factura...' : 'Liquidar y facturar',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBotonVolverSinFacturar() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pop(true),
        icon: const Icon(Icons.arrow_back, color: Colors.white70),
        label: const Text(
          'Sin facturar por ahora',
          style: TextStyle(color: Colors.white70),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white30),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFormularioCaptura() => ConfirmacionCaptura(
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
    campoTranscribiendo: _campoTranscribiendo,
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
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 16),
        Text(
          mensaje,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
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