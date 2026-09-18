// lib/services/asr_service.dart
// Reconocimiento de voz 100% OFFLINE usando Whisper.cpp
// Grabación con flutter_sound (sin conflictos de versiones)
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asrResultado.dart';

class AsrService {
  static AsrService? _instancia;
  static AsrService get instancia => _instancia ??= AsrService._();
  AsrService._();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  Whisper? _whisper;

  bool _recorderAbierto = false;
  bool _inicializado = false;
  bool _escuchando = false;
  bool _modeloDescargado = false;
  String? _rutaWavActual;

  bool get inicializado => _inicializado;
  bool get escuchando => _escuchando;
  bool get listo => _inicializado && _modeloDescargado;

  static const _keyModeloDescargado = 'whisper_modelo_descargado';

  // ─────────────────────────────────────────────
  // INICIALIZAR
  // ─────────────────────────────────────────────

  Future<bool> inicializar() async {
    if (_inicializado) return true;
    try {
      // Inicializar recorder
      await _recorder.openRecorder();
      _recorderAbierto = true;

      // Inicializar Whisper
      _whisper = Whisper(
        model: WhisperModel.tiny,
        downloadHost:
            'https://huggingface.co/ggerganov/whisper.cpp/resolve/main',
      );

      final prefs = await SharedPreferences.getInstance();
      _modeloDescargado = prefs.getBool(_keyModeloDescargado) ?? false;

      if (!_modeloDescargado) {
        try {
          await _whisper!.getVersion();
          _modeloDescargado = true;
          await prefs.setBool(_keyModeloDescargado, true);
        } catch (_) {
          _modeloDescargado = false;
        }
      }

      _inicializado = _modeloDescargado;
      return _inicializado;
    } catch (_) {
      _inicializado = false;
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // INICIAR GRABACIÓN
  // ─────────────────────────────────────────────

  Future<bool> iniciarGrabacion() async {
    if (_escuchando || !listo) return false;

    // Verificar permiso de micrófono
    final status = await Permission.microphone.request();
    if (!status.isGranted) return false;

    final dir = await getTemporaryDirectory();
    _rutaWavActual = '${dir.path}/asr_temp.wav';

    await _recorder.startRecorder(
      toFile: _rutaWavActual,
      codec: Codec.pcm16WAV,
      sampleRate: 16000,
      numChannels: 1,
    );

    _escuchando = true;
    return true;
  }

  // ─────────────────────────────────────────────
  // DETENER Y TRANSCRIBIR
  // ─────────────────────────────────────────────

  Future<AsrResultado?> detenerYTranscribir() async {
    if (!_escuchando) return null;

    await _recorder.stopRecorder();
    _escuchando = false;

    final ruta = _rutaWavActual;
    _rutaWavActual = null;

    if (ruta == null || !File(ruta).existsSync()) return null;

    try {
      final respuesta = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: ruta,
          isTranslate: false,
          isNoTimestamps: true,
          language: 'es',
          threads: 4,
          isSpecialTokens: false,
        ),
      );

      final texto = _limpiarTexto(respuesta.text);
      if (texto == null) return null;

      return AsrResultado(texto: texto, esFinal: true, nivelVolumen: 0.0);
    } catch (_) {
      return null;
    }
  }
  // ─────────────────────────────────────────────
  // CANCELAR
  // ─────────────────────────────────────────────

  Future<void> cancelar() async {
    if (!_escuchando) return;
    try {
      await _recorder.stopRecorder();
      _escuchando = false;
      if (_rutaWavActual != null) {
        try {
          File(_rutaWavActual!).deleteSync();
        } catch (_) {}
        _rutaWavActual = null;
      }
    } catch (_) {
      _escuchando = false;
    }
  }

  String? _limpiarTexto(String? texto) {
    if (texto == null || texto.trim().isEmpty) return null;
    return texto
        .trim()
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> dispose() async {
    await cancelar();
    if (_recorderAbierto) {
      await _recorder.closeRecorder();
      _recorderAbierto = false;
    }
    _inicializado = false;
    _instancia = null;
  }
}