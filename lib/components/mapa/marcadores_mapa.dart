// lib/components/mapa/marcadores_mapa.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/punto_mapa.dart';
import '../../models/posicion_result.dart';
import '../../models/estado_medidor.dart';

/// ─────────────────────────────────────────────
/// MARCADORES DE MEDIDORES
/// ─────────────────────────────────────────────
/// Para cambiar el tamaño de los marcadores:
///   - [tamañoNormal] = tamaño del círculo cuando NO está seleccionado
///   - [tamañoSeleccionado] = tamaño cuando SÍ está seleccionado
///   - [iconoNormal] = tamaño del ícono dentro del círculo (normal)
///   - [iconoSeleccionado] = tamaño del ícono cuando seleccionado
///
/// Para cambiar colores → edita [PuntoMapa.color] en punto_mapa.dart
/// Para cambiar íconos → edita [EstadoMedidor.icono] en estado_medidor.dart

List<Marker> buildMarcadoresMedidores({
  required List<PuntoMapa> puntos,
  required PuntoMapa? puntoSeleccionado,
  required void Function(PuntoMapa) onTap,
}) {
  // ── Tamaños — ajusta estos valores para hacerlos más grandes o pequeños ──
  const tamannoNormal = 22.0;       // ← tamaño del círculo normal
  const tamannoSeleccionado = 40.0; // ← tamanno del círculo seleccionado
  const iconoNormal = 11.0;        // ← tamaño del ícono normal
  const iconoSeleccionado = 22.0;  // ← tamaño del ícono seleccionado
  const grosorBorde = 1.5;         // ← grosor del borde blanco

  return puntos.map((punto) {
    final seleccionado = puntoSeleccionado?.codigo == punto.codigo;
    final color = punto.color;
    final size = seleccionado ? tamannoSeleccionado : tamannoNormal;
    final iconSize = seleccionado ? iconoSeleccionado : iconoNormal;

    return Marker(
      point: LatLng(punto.latitud, punto.longitud),
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () => onTap(punto),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: grosorBorde),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: seleccionado ? 8 : 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            // Ícono según estado del medidor, o gota genérica
            punto.estadoMedidor != null
                ? punto.estadoMedidor!.icono
                : (punto.tieneLecturaReal
                    ? Icons.water_drop        // ← con lectura
                    : Icons.water_drop_outlined), // ← sin lectura
            color: Colors.white,
            size: iconSize,
          ),
        ),
      ),
    );
  }).toList();
}

/// ─────────────────────────────────────────────
/// MARCADOR DEL TÉCNICO (posición actual)
/// ─────────────────────────────────────────────
/// Para cambiar el estilo del marcador del técnico:
///   - Cambia [colorTecnico] para otro color
///   - Cambia [Icons.engineering] por otro ícono de Material Icons
///   - Cambia [tamañoCirculo] y [tamañoIcono] para el tamaño

Marker buildMarcadorPosicion(PosicionResult posicion) {
  // ── Personalización del marcador del técnico ──
  const colorTecnico = Color(0xFF00897B); // ← color teal del técnico
  const tamannoCirculo = 38.0;            // ← tamaño total del marcador
  const tamannoHalo = 50.0;              // ← tamaño del halo exterior
  const tamannoIcono = 18.0;             // ← tamaño del ícono

  return Marker(
    point: LatLng(posicion.latitud, posicion.longitud),
    width: tamannoHalo,
    height: tamannoHalo,
    child: Stack(
      alignment: Alignment.center,
      children: [
        // Halo exterior semitransparente
        Container(
          width: tamannoHalo,
          height: tamannoHalo,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorTecnico.withOpacity(0.18),
          ),
        ),
        // Círculo principal
        Container(
          width: tamannoCirculo,
          height: tamannoCirculo,
          decoration: BoxDecoration(
            color: colorTecnico,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          // ← Cambia el ícono aquí si quieres otro
          child: const Icon(
            Icons.engineering, // casco de técnico
            color: Colors.white,
            size: tamannoIcono,
          ),
        ),
      ],
    ),
  );
}

/// ─────────────────────────────────────────────
/// CÍRCULO DE PRECISIÓN GPS
/// ─────────────────────────────────────────────
/// Muestra el área de incertidumbre del GPS alrededor del técnico.
/// Para ocultarlo: elimina el CircleLayer en mapa_screen.dart

CircleMarker buildCirculoPrecision(PosicionResult posicion) {
  return CircleMarker(
    point: LatLng(posicion.latitud, posicion.longitud),
    radius: posicion.precision ?? 10,
    useRadiusInMeter: true,
    color: const Color(0xFF00897B).withOpacity(0.08), // ← mismo color del técnico
    borderColor: const Color(0xFF00897B).withOpacity(0.3),
    borderStrokeWidth: 1,
  );
}