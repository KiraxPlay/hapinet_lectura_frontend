// lib/screens/tutorial_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medidor_hapinet_app/services/api/api_client.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../services/api/api_service.dart';
import '../models/acueducto.dart';

// ─────────────────────────────────────────────
// MODELO
// ─────────────────────────────────────────────
class CapituloTutorial {
  final String titulo;
  final String urlVideo;
  final IconData icono;
  final Color color;

  const CapituloTutorial({
    required this.titulo,
    required this.urlVideo,
    required this.icono,
    required this.color,
  });

  factory CapituloTutorial.fromJson(Map<String, dynamic> json, int index) {
    final iconos = [
      Icons.camera_alt_outlined,
      Icons.record_voice_over_outlined,
      Icons.map_outlined,
      Icons.upload_file_outlined,
    ];
    final colores = [
      const Color(0xFF1565C0),
      const Color(0xFF2E7D32),
      const Color(0xFF6A1B9A),
      const Color(0xFFE65100),
    ];
    return CapituloTutorial(
      titulo: json['titulo'] as String,
      urlVideo: json['url'] as String,
      icono: iconos[index % iconos.length],
      color: colores[index % colores.length],
    );
  }
}

// ─────────────────────────────────────────────
// PANTALLA PRINCIPAL
// ─────────────────────────────────────────────
class TutorialScreen extends StatefulWidget {
  final Acueducto acueducto;
  const TutorialScreen({super.key, required this.acueducto});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  List<CapituloTutorial> _capitulos = [];
  bool _cargando = true;
  String? _error;

  // Lista fija como fallback si no hay internet y no hay caché
  static const _capitulosFallback = [
    CapituloTutorial(
      titulo: 'Cómo tomar una lectura',
      urlVideo:
          'https://hapinet.com.co/videos/tutoriales_app/tutorial_toma_lectura.mp4',
      icono: Icons.camera_alt_outlined,
      color: Color(0xFF1565C0),
    ),
    CapituloTutorial(
      titulo: 'Cómo tomar lectura con voz',
      urlVideo:
          'https://hapinet.com.co/videos/tutoriales_app/tutorial_toma_lectura_voz.mp4',
      icono: Icons.record_voice_over_outlined,
      color: Color(0xFF2E7D32),
    ),
    CapituloTutorial(
      titulo: 'Cómo usar el mapa',
      urlVideo:
          'https://hapinet.com.co/videos/tutoriales_app/tutorial_mapa.mp4',
      icono: Icons.map_outlined,
      color: Color(0xFF6A1B9A),
    ),
    CapituloTutorial(
      titulo: 'Cómo exportar',
      urlVideo:
          'https://hapinet.com.co/videos/tutoriales_app/tutorial_exportacion.mp4',
      icono: Icons.upload_file_outlined,
      color: Color(0xFFE65100),
    ),
  ];
  @override
  void initState() {
    super.initState();
    // Mostrar lista fallback inmediatamente — siempre visible
    _capitulos = _capitulosFallback;
    _cargando = false;
    // Intentar cargar desde API en background
    _cargarTutoriales();
  }

  Future<void> _cargarTutoriales() async {
    try {
      final api = ApiService(widget.acueducto);
      final lista = await api.tutoriales().timeout(const Duration(seconds: 5));
      if (mounted) {
        setState(() {
          _capitulos =
              lista
                  .asMap()
                  .entries
                  .map(
                    (e) => CapituloTutorial.fromJson(
                      e.value as Map<String, dynamic>,
                      e.key,
                    ),
                  )
                  .toList();
        });
      }
    } catch (_) {
      // Sin internet — mantener lista fallback, ya está visible
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial')),
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _capitulos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder:
                    (_, i) => _TarjetaCapitulo(
                      capitulo: _capitulos[i],
                      numero: i + 1,
                    ),
              ),
    );
  }
}

// ─────────────────────────────────────────────
// TARJETA
// ─────────────────────────────────────────────
class _TarjetaCapitulo extends StatefulWidget {
  final CapituloTutorial capitulo;
  final int numero;
  const _TarjetaCapitulo({required this.capitulo, required this.numero});

  @override
  State<_TarjetaCapitulo> createState() => _TarjetaCapituloState();
}

class _TarjetaCapituloState extends State<_TarjetaCapitulo> {
  bool _descargado = false;

  @override
  void initState() {
    super.initState();
    _verificarDescarga();
  }

  Future<File> _archivoLocal() async {
    final dir =
        await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    final nombre = widget.capitulo.urlVideo.split('/').last;
    return File('${dir.path}/Hapinet/Tutoriales/$nombre');
  }

  Future<void> _verificarDescarga() async {
    final archivo = await _archivoLocal();
    if (mounted) setState(() => _descargado = archivo.existsSync());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => _ReproductorScreen(
                    capitulo: widget.capitulo,
                    capitulos:
                        [], // se pasa desde TutorialScreen si se necesita nav
                  ),
            ),
          );
          _verificarDescarga();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.capitulo.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.capitulo.color.withOpacity(0.3),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      widget.capitulo.icono,
                      color: widget.capitulo.color,
                      size: 24,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: widget.capitulo.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.numero}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.capitulo.titulo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_descargado) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.offline_bolt,
                            size: 11,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Disponible offline',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.play_circle_outline,
                color: widget.capitulo.color,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REPRODUCTOR
// ─────────────────────────────────────────────
class _ReproductorScreen extends StatefulWidget {
  final CapituloTutorial capitulo;
  final List<CapituloTutorial> capitulos;
  const _ReproductorScreen({required this.capitulo, required this.capitulos});

  @override
  State<_ReproductorScreen> createState() => _ReproductorScreenState();
}

class _ReproductorScreenState extends State<_ReproductorScreen> {
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _cargando = true;
  String? _error;
  bool _usandoRed = false;
  bool _descargando = false;
  double _progresoDescarga = 0;

  Future<File> _archivoLocal() async {
    final dir =
        await getExternalStorageDirectory() ??
        await getApplicationDocumentsDirectory();
    final carpeta = Directory('${dir.path}/Hapinet/Tutoriales');
    if (!await carpeta.exists()) await carpeta.create(recursive: true);
    final nombre = widget.capitulo.urlVideo.split('/').last;
    return File('${carpeta.path}/$nombre');
  }

  Future<bool> _tieneInternet() async {
    try {
      final resp = await http
          .head(Uri.parse('https://hapinet.com.co'))
          .timeout(const Duration(seconds: 5));
      return resp.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _inicializarVideo();
  }

  Future<void> _inicializarVideo() async {
    try {
      final archivo = await _archivoLocal();
      VideoPlayerController ctrl;

      if (archivo.existsSync()) {
        ctrl = VideoPlayerController.file(archivo);
        _usandoRed = false;
      } else {
        final tieneInternet = await _tieneInternet();
        if (!tieneInternet) {
          if (mounted)
            setState(() {
              _cargando = false;
              _error = 'Sin conexión\nDescarga el video para verlo offline';
            });
          return;
        }
        ctrl = VideoPlayerController.networkUrl(
          Uri.parse(widget.capitulo.urlVideo),
        );
        _usandoRed = true;
      }

      _videoCtrl = ctrl;
      await _videoCtrl!.initialize();

      _chewieCtrl = ChewieController(
        videoPlayerController: _videoCtrl!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoCtrl!.value.aspectRatio,
        placeholder: Container(color: Colors.black),
        materialProgressColors: ChewieProgressColors(
          playedColor: widget.capitulo.color,
          handleColor: widget.capitulo.color,
          backgroundColor: Colors.grey.shade800,
          bufferedColor: widget.capitulo.color.withOpacity(0.3),
        ),
      );

      if (mounted) setState(() => _cargando = false);
    } catch (e) {
      if (mounted)
        setState(() {
          _cargando = false;
          _error = 'No se pudo cargar el video';
        });
    }
  }

  Future<void> _descargar() async {
    if (_descargando) return;
    setState(() {
      _descargando = true;
      _progresoDescarga = 0;
    });
    try {
      final archivo = await _archivoLocal();
      final response = await http.Client().send(
        http.Request('GET', Uri.parse(widget.capitulo.urlVideo)),
      );
      final totalBytes = response.contentLength ?? 0;
      int bytesRecibidos = 0;
      final sink = archivo.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        bytesRecibidos += chunk.length;
        if (totalBytes > 0 && mounted) {
          setState(() => _progresoDescarga = bytesRecibidos / totalBytes);
        }
      }
      await sink.close();
      if (mounted) {
        setState(() {
          _descargando = false;
          _progresoDescarga = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Video descargado — disponible offline'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Compartir',
              textColor: Colors.white,
              onPressed: () => Share.shareXFiles([XFile(archivo.path)]),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _descargando = false;
          _progresoDescarga = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _chewieCtrl?.dispose();
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.capitulo.titulo),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_usandoRed && !_cargando && _error == null)
            _descargando
                ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: _progresoDescarga > 0 ? _progresoDescarga : null,
                      strokeWidth: 2,
                      color: widget.capitulo.color,
                    ),
                  ),
                )
                : IconButton(
                  icon: const Icon(Icons.download_outlined),
                  tooltip: 'Descargar para ver offline',
                  onPressed: _descargar,
                ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _videoCtrl?.value.aspectRatio ?? 16 / 9,
            child:
                _cargando
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.white54,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                    : Chewie(controller: _chewieCtrl!),
          ),

          // Indicador de fuente
          if (!_cargando && _error == null)
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _usandoRed ? Icons.wifi : Icons.offline_bolt,
                    size: 12,
                    color:
                        _usandoRed
                            ? Colors.green.shade400
                            : Colors.orange.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _usandoRed
                        ? 'Reproduciendo en línea'
                        : 'Reproduciendo offline',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          _usandoRed
                              ? Colors.green.shade400
                              : Colors.orange.shade400,
                    ),
                  ),
                ],
              ),
            ),

          // Info
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        widget.capitulo.icono,
                        color: widget.capitulo.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.capitulo.titulo,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.capitulo.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
