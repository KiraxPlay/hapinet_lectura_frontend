// lib/screens/tutorial_screen.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// ─────────────────────────────────────────────
// MODELO DE UN CAPÍTULO DEL TUTORIAL
// ─────────────────────────────────────────────
class CapituloTutorial {
  final String titulo;
  final String descripcion;
  final String assetVideo; // ruta en assets/videos/
  final IconData icono;
  final Color color;

  const CapituloTutorial({
    required this.titulo,
    required this.descripcion,
    required this.assetVideo,
    required this.icono,
    required this.color,
  });
}

// ─────────────────────────────────────────────
// LISTA DE CAPÍTULOS
// Para agregar uno nuevo: añade una entrada aquí
// y agrega el .mp4 en assets/videos/
// ─────────────────────────────────────────────
const _capitulos = [
  CapituloTutorial(
    titulo: 'Cómo tomar una lectura',
    descripcion:
        'Busca el abonado, toma la foto del medidor, verifica el número '
        'que detectó el OCR y guarda la lectura.',
    assetVideo: 'assets/videos/tutoriales/tutorial_toma_lectura.mp4',
    icono: Icons.camera_alt_outlined,
    color: Color(0xFF1565C0),
  ),
  CapituloTutorial(
    titulo: 'Lectura y observaciones por voz',
    descripcion:
        'Usa el micrófono para dictar el número del medidor y las '
        'observaciones sin necesidad de escribir.',
    assetVideo: 'assets/videos/tutoriales/tutorial_toma_lectura_voz.mp4',
    icono: Icons.record_voice_over_outlined,
    color: Color(0xFF2E7D32),
  ),
  CapituloTutorial(
    titulo: 'Usar el mapa',
    descripcion:
        'Filtra medidores por sector, toca un marcador para ver su '
        'información y toma la lectura directamente desde el mapa.',
    assetVideo: 'assets/videos/tutoriales/tutorial_mapa.mp4',
    icono: Icons.map_outlined,
    color: Color(0xFF6A1B9A),
  ),
  CapituloTutorial(
    titulo: 'Exportar lecturas',
    descripcion:
        'Abre el historial, expande el día y exporta el Excel con '
        'fotos o genera las facturas PDF para compartir.',
    assetVideo: 'assets/videos/tutoriales/tutorial_exportacion.mp4',
    icono: Icons.upload_file_outlined,
    color: Color(0xFFE65100),
  ),
];

// ─────────────────────────────────────────────
// PANTALLA PRINCIPAL DEL TUTORIAL
// ─────────────────────────────────────────────
class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _capitulos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _TarjetaCapitulo(
          capitulo: _capitulos[i],
          numero: i + 1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TARJETA DE UN CAPÍTULO
// ─────────────────────────────────────────────
class _TarjetaCapitulo extends StatelessWidget {
  final CapituloTutorial capitulo;
  final int numero;

  const _TarjetaCapitulo({
    required this.capitulo,
    required this.numero,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ReproductorScreen(capitulo: capitulo),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Número + icono
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: capitulo.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: capitulo.color.withOpacity(0.3)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(capitulo.icono,
                        color: capitulo.color, size: 24),
                    Positioned(
                      right: 0, bottom: 0,
                      child: Container(
                        width: 18, height: 18,
                        decoration: BoxDecoration(
                          color: capitulo.color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('$numero',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Título y descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(capitulo.titulo,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(capitulo.descripcion,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Icon(Icons.play_circle_outline,
                  color: capitulo.color, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PANTALLA REPRODUCTORA DE VIDEO
// ─────────────────────────────────────────────
class _ReproductorScreen extends StatefulWidget {
  final CapituloTutorial capitulo;

  const _ReproductorScreen({required this.capitulo});

  @override
  State<_ReproductorScreen> createState() => _ReproductorScreenState();
}

class _ReproductorScreenState extends State<_ReproductorScreen> {
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _inicializarVideo();
  }

  Future<void> _inicializarVideo() async {
    try {
      _videoCtrl = VideoPlayerController.asset(widget.capitulo.assetVideo);
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
        // Subtítulos opcionales — agregar si se tienen archivos .vtt
        // subtitle: Subtitles(...),
      );

      if (mounted) setState(() => _cargando = false);
    } catch (e) {
      if (mounted) setState(() {
        _cargando = false;
        _error = 'No se pudo cargar el video';
      });
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
      ),
      body: Column(
        children: [
          // ── Reproductor ──
          AspectRatio(
            aspectRatio: _videoCtrl?.value.aspectRatio ?? 16 / 9,
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 40),
                            const SizedBox(height: 12),
                            Text(_error!,
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      )
                    : Chewie(controller: _chewieCtrl!),
          ),

          // ── Info del capítulo ──
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(widget.capitulo.icono,
                          color: widget.capitulo.color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.capitulo.titulo,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.capitulo.color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.capitulo.descripcion,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade700),
                  ),

                  const Spacer(),

                  // Navegación entre capítulos
                  _NavegacionCapitulos(capituloActual: widget.capitulo),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// NAVEGACIÓN ENTRE CAPÍTULOS
// ─────────────────────────────────────────────
class _NavegacionCapitulos extends StatelessWidget {
  final CapituloTutorial capituloActual;

  const _NavegacionCapitulos({required this.capituloActual});

  @override
  Widget build(BuildContext context) {
    final indiceActual =
        _capitulos.indexWhere((c) => c.assetVideo == capituloActual.assetVideo);
    final anterior = indiceActual > 0 ? _capitulos[indiceActual - 1] : null;
    final siguiente = indiceActual < _capitulos.length - 1
        ? _capitulos[indiceActual + 1]
        : null;

    return Row(
      children: [
        if (anterior != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _irA(context, anterior),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: Text(anterior.titulo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        if (anterior != null && siguiente != null)
          const SizedBox(width: 10),
        if (siguiente != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _irA(context, siguiente),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(siguiente.titulo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: capituloActual.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
      ],
    );
  }

  void _irA(BuildContext context, CapituloTutorial capitulo) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _ReproductorScreen(capitulo: capitulo),
      ),
    );
  }
}