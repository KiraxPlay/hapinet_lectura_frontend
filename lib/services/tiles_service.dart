// lib/services/tiles_service.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pre-descarga los tiles de OpenStreetMap para Gigante, Huila
/// para que el mapa funcione offline desde la primera vez
class TilesService {
  static const _keyTilesDescargados = 'tiles_gigante_descargados_v1';

  // Área de Gigante, Huila — cubre los 3 sectores de ASOAGUAPO
  static const _latMin = 2.35;
  static const _latMax = 2.42;
  static const _lonMin = -75.57;
  static const _lonMax = -75.51;

  // Zoom 12 = municipio, 13-14 = sectores, 15-16 = calles
  static const _zoomMin = 12;
  static const _zoomMax = 16;

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Descarga tiles solo si no se han descargado antes
  Future<void> descargarSiNecesario({
    void Function(double progreso, int descargados, int total)? onProgreso,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyTilesDescargados) == true) return;

    await descargar(onProgreso: onProgreso);
    await prefs.setBool(_keyTilesDescargados, true);
  }

  Future<void> descargar({
    void Function(double progreso, int descargados, int total)? onProgreso,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/map_tiles_cache');
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);

    final tiles = _calcularTiles();
    int descargados = 0;
    final total = tiles.length;

    for (final tile in tiles) {
      try {
        final rutaArchivo =
            '${cacheDir.path}/${tile.zoom}_${tile.x}_${tile.y}.png';
        final archivo = File(rutaArchivo);

        if (!await archivo.exists()) {
          final url =
              'https://tile.openstreetmap.org/${tile.zoom}/${tile.x}/${tile.y}.png';

          final response = await _dio.get<List<int>>(
            url,
            options: Options(
              responseType: ResponseType.bytes,
              headers: {
                'User-Agent':
                    'MedidorASOAGUAPO/1.0 (medidores@asoaguapo.com)',
              },
            ),
          );

          if (response.data != null) {
            await archivo.writeAsBytes(response.data!);
          }
        }
      } catch (_) {
        // Si falla un tile, continuar
      }

      descargados++;
      onProgreso?.call(descargados / total, descargados, total);

      // Pausa para no saturar OSM (máx ~1 req/50ms)
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  static List<_Tile> _calcularTiles() {
    final tiles = <_Tile>[];
    for (int zoom = _zoomMin; zoom <= _zoomMax; zoom++) {
      final xMin = _lonToX(_lonMin, zoom);
      final xMax = _lonToX(_lonMax, zoom);
      final yMin = _latToY(_latMax, zoom);
      final yMax = _latToY(_latMin, zoom);
      for (int x = xMin; x <= xMax; x++) {
        for (int y = yMin; y <= yMax; y++) {
          tiles.add(_Tile(zoom, x, y));
        }
      }
    }
    return tiles;
  }

  static int contarTiles() => _calcularTiles().length;

  // Fórmula estándar OSM: https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
  static int _lonToX(double lon, int zoom) =>
      ((lon + 180) / 360 * math.pow(2, zoom)).floor();

  static int _latToY(double lat, int zoom) {
    final latRad = lat * math.pi / 180;
    return ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
            2 *
            math.pow(2, zoom))
        .floor();
  }
}

class _Tile {
  final int zoom, x, y;
  const _Tile(this.zoom, this.x, this.y);
}