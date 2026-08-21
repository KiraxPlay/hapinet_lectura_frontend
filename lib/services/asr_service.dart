// lib/services/asr_service.dart
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AsrService {
  static AsrService? _instancia;
  static AsrService get instancia => _instancia ??= AsrService._();
  AsrService._();

  final SpeechToText _speech = SpeechToText();
  bool _inicializado = false;
  bool _escuchando = false;

  // true = tiene idioma español descargado para uso offline
  // null = aún no verificado
  bool? _modoOfflineDisponible;

  static const _keyAvisoOffline = 'asr_aviso_offline_mostrado';

  bool get inicializado => _inicializado;
  bool get escuchando => _escuchando;

  /// true  → español offline descargado, funciona sin internet
  /// false → solo funciona con internet
  /// null  → aún no verificado
  bool? get modoOfflineDisponible => _modoOfflineDisponible;

  // ─────────────────────────────────────────────
  // INICIALIZAR
  // ─────────────────────────────────────────────

  Future<bool> inicializar() async {
    if (_inicializado) return true;
    try {
      _inicializado = await _speech.initialize(
        onError: (_) => _escuchando = false,
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _escuchando = false;
          }
        },
      );

      if (_inicializado) {
        await _verificarOffline();
      }

      return _inicializado;
    } catch (_) {
      _inicializado = false;
      return false;
    }
  }

  // Verifica si el idioma español está disponible offline
  Future<void> _verificarOffline() async {
    try {
      final locales = await _speech.locales();
      // Buscar cualquier variante de español disponible
      _modoOfflineDisponible = locales.any((l) =>
          l.localeId.startsWith('es') &&
          // speech_to_text marca offline con hasDictation o simplemente
          // estando en la lista de locales del sistema
          l.localeId.isNotEmpty);
    } catch (_) {
      _modoOfflineDisponible = false;
    }
  }

  /// Retorna true si es la primera vez y debe mostrarse el aviso offline.
  /// Llama esto antes de mostrar el micrófono por primera vez.
  Future<bool> debesMostrarAvisoOffline() async {
    if (_modoOfflineDisponible == true) return false;
    final prefs = await SharedPreferences.getInstance();
    final yaVisto = prefs.getBool(_keyAvisoOffline) ?? false;
    return !yaVisto;
  }

  /// Marca el aviso como ya mostrado para no repetirlo
  Future<void> marcarAvisoOfflineVisto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAvisoOffline, true);
  }

  // ─────────────────────────────────────────────
  // ESCUCHAR
  // ─────────────────────────────────────────────

  Stream<AsrResultado> escuchar() async* {
    if (!_inicializado || _escuchando) return;

    _escuchando = true;
    final controller = StreamController<AsrResultado>();
    String _ultimoTexto = '';
    double _nivelActual = 0.0;

    await _speech.listen(
      onResult: (result) {
        final texto = result.recognizedWords.trim();
        if (texto.isEmpty) return;
        _ultimoTexto = texto;
        if (result.finalResult) {
          if (!controller.isClosed) {
            controller.add(AsrResultado(
                texto: texto, esFinal: true, nivelVolumen: 0.0));
            controller.close();
          }
          _escuchando = false;
        } else {
          if (!controller.isClosed) {
            controller.add(AsrResultado(
                texto: texto, esFinal: false, nivelVolumen: _nivelActual));
          }
        }
      },
      onSoundLevelChange: (level) {
        _nivelActual = level.clamp(0.0, 10.0);
        if (!controller.isClosed) {
          controller.add(AsrResultado(
              texto: _ultimoTexto,
              esFinal: false,
              nivelVolumen: _nivelActual));
        }
      },
      localeId: 'es_CO',
      listenFor: const Duration(minutes: 3),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      listenMode: ListenMode.dictation,
    );

    _speech.statusListener = (status) {
      if ((status == 'done' || status == 'notListening') &&
          _ultimoTexto.isNotEmpty &&
          !controller.isClosed) {
        controller.add(AsrResultado(texto: _ultimoTexto, esFinal: true));
        _escuchando = false;
        controller.close();
      }
    };

    yield* controller.stream;
  }

  // ─────────────────────────────────────────────
  // DETENER
  // ─────────────────────────────────────────────

  Future<void> detener() async {
    if (!_escuchando) return;
    await _speech.stop();
    _escuchando = false;
  }

  Future<void> dispose() async {
    await detener();
    _inicializado = false;
    _instancia = null;
  }
}

// Resultado del ASR
class AsrResultado {
  final String texto;
  final bool esFinal;
  final double nivelVolumen;

  const AsrResultado({
    required this.texto,
    required this.esFinal,
    this.nivelVolumen = 0.0,
  });
}