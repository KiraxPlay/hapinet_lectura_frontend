// lib/services/camara_service.dart
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../models/foto_result.dart';

class CamaraService {
  CameraController? _controller;
  List<CameraDescription> _camaras = [];
  bool _inicializado = false;

  bool get estaInicializado => _inicializado;
  CameraController? get controller => _controller;

  // ─────────────────────────────────────────────
  // INICIALIZACIÓN
  // ─────────────────────────────────────────────

  Future<void> inicializar() async {
    final permiso = await Permission.camera.request();
    if (!permiso.isGranted) {
      throw CamaraException(
        'Permiso de cámara denegado.',
        tipo: TipoErrorCamara.permisoDenegado,
      );
    }

    _camaras = await availableCameras();
    if (_camaras.isEmpty) {
      throw CamaraException(
        'No se encontraron cámaras disponibles.',
        tipo: TipoErrorCamara.sinCamara,
      );
    }

    final camaraTrasera = _camaras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _camaras.first,
    );

    _controller = CameraController(
      camaraTrasera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      await _configurarParaOCR();
      _inicializado = true;
    } catch (e) {
      throw CamaraException(
        'Error al inicializar la cámara: $e',
        tipo: TipoErrorCamara.errorInicializacion,
      );
    }
  }

  Future<void> _configurarParaOCR() async {
    if (_controller == null) return;
    try {
      await _controller!.setExposureMode(ExposureMode.auto);
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setFlashMode(FlashMode.off);
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  // CAPTURA
  // ─────────────────────────────────────────────

  Future<FotoResult> tomarFoto({String? codigoMedidor}) async {
    if (!_inicializado || _controller == null) {
      throw CamaraException(
        'Cámara no inicializada.',
        tipo: TipoErrorCamara.noInicializada,
      );
    }

    try {
      final XFile foto = await _controller!.takePicture();
      final rutaFinal =
          await _guardarFotoLocalmente(foto.path, codigoMedidor: codigoMedidor);

      return FotoResult(
        rutaLocal: rutaFinal,
        tamanoBytes: await File(rutaFinal).length(),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw CamaraException(
        'Error al tomar la foto: $e',
        tipo: TipoErrorCamara.errorCaptura,
      );
    }
  }

  // ─────────────────────────────────────────────
  // ALMACENAMIENTO LOCAL
  // ─────────────────────────────────────────────

  Future<String> _guardarFotoLocalmente(String rutaTemporal,
      {String? codigoMedidor}) async {
    final dirDocumentos = await getApplicationDocumentsDirectory();
    final dirFotos =
        Directory(p.join(dirDocumentos.path, 'fotos_medidores'));

    if (!await dirFotos.exists()) await dirFotos.create(recursive: true);

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final prefijo = codigoMedidor != null ? '${codigoMedidor}_' : '';
    final nombreArchivo = '${prefijo}medidor_$timestamp.jpg';
    final rutaDestino = p.join(dirFotos.path, nombreArchivo);

    await File(rutaTemporal).copy(rutaDestino);

    try {
      await File(rutaTemporal).delete();
    } catch (_) {}

    return rutaDestino;
  }

  Future<List<FileSystemEntity>> obtenerFotosLocales() async {
    final dirDocumentos = await getApplicationDocumentsDirectory();
    final dirFotos =
        Directory(p.join(dirDocumentos.path, 'fotos_medidores'));
    if (!await dirFotos.exists()) return [];
    return dirFotos.listSync().where((f) => f.path.endsWith('.jpg')).toList()
      ..sort((a, b) => b.path.compareTo(a.path));
  }

  Future<void> eliminarFoto(String ruta) async {
    final file = File(ruta);
    if (await file.exists()) await file.delete();
  }

  Future<double> calcularEspacioUsadoMB() async {
    final fotos = await obtenerFotosLocales();
    int totalBytes = 0;
    for (final foto in fotos) {
      totalBytes += await File(foto.path).length();
    }
    return totalBytes / (1024 * 1024);
  }

  // ─────────────────────────────────────────────
  // CONTROLES DE CÁMARA
  // ─────────────────────────────────────────────

  Future<void> toggleFlash() async {
    if (_controller == null) return;
    final modoActual = _controller!.value.flashMode;
    await _controller!.setFlashMode(
      modoActual == FlashMode.off ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> enfocarEn(double x, double y) async {
    if (_controller == null) return;
    try {
      await _controller!.setFocusPoint(Offset(x, y));
      await _controller!.setExposurePoint(Offset(x, y));
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _inicializado = false;
  }
}