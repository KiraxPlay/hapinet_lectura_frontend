import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' show Size;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import '../models/ocr_result.dart';

class OcrService {
  late final TextRecognizer _recognizer;
  bool _modeloCalentado = false;

  OcrService() {
    _recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  // ─────────────────────────────────────────────
  // PRE-CARGA DEL MODELO
  // Llama esto desde el SplashScreen para que el modelo
  // esté listo cuando el técnico abra la cámara
  // ─────────────────────────────────────────────

  Future<void> precalentarModelo() async {
    if (_modeloCalentado) return;
    try {
      // Procesar una imagen en blanco de 1x1 pixel
      // Solo sirve para forzar la carga del modelo en memoria
      final imagen = InputImage.fromBytes(
        bytes: Uint8List.fromList([255, 255, 255]),
        metadata: InputImageMetadata(
          size: const Size(1, 1),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 1,
        ),
      );
      await _recognizer.processImage(imagen);
      _modeloCalentado = true;
    } catch (_) {
      // Ignorar errores — es solo pre-carga
    }
  }

  // ─────────────────────────────────────────────
  // LECTURA PRINCIPAL
  // ─────────────────────────────────────────────

  // Recorta la imagen al área central donde está el medidor
  Future<String> recortarZonaMedidor(String rutaImagen) async {
    final bytes = await File(rutaImagen).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final imagen = frame.image;

    final w = imagen.width.toDouble();
    final h = imagen.height.toDouble();

    // Zona central — coincide con el encuadre amarillo de la cámara
    final recorte = ui.Rect.fromLTWH(
      w * 0.1, // 10% desde la izquierda
      h * 0.35, // 35% desde arriba
      w * 0.8, // 80% de ancho
      h * 0.3, // 30% de alto
    );

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      imagen,
      recorte,
      ui.Rect.fromLTWH(0, 0, recorte.width, recorte.height),
      ui.Paint(),
    );

    final picture = recorder.endRecording();
    final recortada = await picture.toImage(
      recorte.width.toInt(),
      recorte.height.toInt(),
    );
    final byteData = await recortada.toByteData(format: ui.ImageByteFormat.png);

    // Guardar recorte temporal
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/ocr_recorte.png';
    await File(tempPath).writeAsBytes(byteData!.buffer.asUint8List());
    return tempPath;
  }

  /// Procesa una imagen y extrae el número del medidor (100% offline)
  Future<OcrResult> leerMedidor(String rutaImagen) async {
    final rutaRecorte = await recortarZonaMedidor(rutaImagen);
    final inputImage = InputImage.fromFilePath(rutaRecorte);
    try {
      final RecognizedText textoReconocido = await _recognizer.processImage(
        inputImage,
      );

      final textoCrudo = textoReconocido.text;

      if (textoCrudo.isEmpty) return OcrResult.sinTexto();

      return _extraerNumeroDeMedidor(textoCrudo, textoReconocido);
    } catch (e) {
      return OcrResult.error('Error al procesar la imagen: $e');
    }
  }

  // ─────────────────────────────────────────────
  // EXTRACCIÓN INTELIGENTE DEL NÚMERO
  // ─────────────────────────────────────────────

  OcrResult _extraerNumeroDeMedidor(
    String textoCrudo,
    RecognizedText textoReconocido,
  ) {
    final List<CandidatoNumerico> candidatos = [];

    for (final bloque in textoReconocido.blocks) {
      for (final linea in bloque.lines) {
        final textoLinea = linea.text.trim();
        final matches = RegExp(
          r'\d+',
        ).allMatches(textoLinea.replaceAll(' ', ''));

        for (final match in matches) {
          final secuencia = match.group(0)!;
          // Medidores de agua: entre 4 y 8 dígitos
          if (secuencia.length >= 4 && secuencia.length <= 8) {
            candidatos.add(
              CandidatoNumerico(
                valor: int.parse(secuencia),
                texto: secuencia,
                longitudDigitos: secuencia.length,
                confianza: _calcularConfianza(secuencia, linea),
              ),
            );
          }
        }
      }
    }

    if (candidatos.isEmpty) {
      // Intento secundario: cualquier número de al menos 2 dígitos
      final numeros =
          RegExp(r'\d+')
              .allMatches(textoCrudo)
              .map((m) => m.group(0)!)
              .where((n) => n.length >= 2)
              .toList();

      if (numeros.isEmpty) return OcrResult.sinNumeros(textoCrudo);

      numeros.sort((a, b) => b.length.compareTo(a.length));
      return OcrResult.conAdvertencia(
        lectura: int.parse(numeros.first),
        textoCrudo: textoCrudo,
        advertencia: 'Número extraído con baja confianza. Verifica la lectura.',
      );
    }

    candidatos.sort((a, b) => b.confianza.compareTo(a.confianza));
    final mejor = candidatos.first;

    return OcrResult.exitoso(
      lectura: mejor.valor,
      textoCrudo: textoCrudo,
      confianza: mejor.confianza,
      todosCandidatos: candidatos,
    );
  }

  double _calcularConfianza(String secuencia, TextLine linea) {
    double confianza = 0.5;
    if (secuencia.length == 5 || secuencia.length == 6) confianza += 0.3;
    if (secuencia.length == 7 || secuencia.length == 8) confianza += 0.2;
    if (secuencia.length == 4) confianza += 0.1;
    final bbox = linea.boundingBox;
    if (bbox.width > 100) confianza += 0.1;
    if (bbox.height > 30) confianza += 0.1;
    return confianza.clamp(0.0, 1.0);
  }

  void dispose() => _recognizer.close();
}
