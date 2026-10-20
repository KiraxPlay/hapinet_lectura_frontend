// lib/components/funciones/detalle_lectura_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';
import '../../models/acueducto.dart';
import '../../models/calculo_consumo.dart';
import '../../models/estado_medidor.dart';
import 'color_sector.dart';
import 'fila.dart';

// Panel inferior que muestra una lectura y permite editarla, eliminarla o
// solicitar la facturación. Se abre al tocar una TarjetaLectura.
class DetalleLecturaSheet extends StatefulWidget {
  // Datos que se muestran y base local donde se guardan los cambios.
  final Lectura lectura;
  final AppDatabase db;

  // Callback del padre para volver a cargar la lista después de modificarla.
  final VoidCallback onActualizado;

  // Contexto del acueducto y acción opcional de facturación, definidos por
  // la pantalla que abre el panel.
  final Acueducto acueducto;
  final VoidCallback? onFacturar;

  const DetalleLecturaSheet({
    super.key,
    required this.lectura,
    required this.db,
    required this.onActualizado,
    required this.acueducto,
    this.onFacturar,
  });

  @override
  State<DetalleLecturaSheet> createState() => _DetalleLecturaSheetState();
}

class _DetalleLecturaSheetState extends State<DetalleLecturaSheet> {
  bool _editando = false;
  late final TextEditingController _lecturaCtrl;
  late final TextEditingController _notasCtrl;

  @override
  void initState() {
    super.initState();
    // Los campos de edición comienzan con los valores que ya tiene la lectura.
    _lecturaCtrl = TextEditingController(
      text: widget.lectura.lectura.toString(),
    );
    _notasCtrl = TextEditingController(text: widget.lectura.notas ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final color = colorDeSector(widget.lectura.sector);
    // El modelo centraliza las reglas para calcular consumo según el estado
    // del medidor y los valores local/servidor disponibles.
    final consumo = CalculoConsumo.calcular(
      estado:
          EstadoMedidor.desdeClave(widget.lectura.estadoMedidor) ??
          EstadoMedidor.lecturaRealizada,
      lecturaAnterior: widget.lectura.lecturaAnterior,
      lecturaActual: widget.lectura.lectura,
      consumoAnterior: widget.lectura.consumoAnteriorServidor,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder:
          (_, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lectura.nombreAbonado ??
                              widget.lectura.codigoMedidor ??
                              '—',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.lectura.codigoMedidor != null)
                          Text(
                            widget.lectura.codigoMedidor!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!widget.lectura.impreso)
                    TextButton.icon(
                      onPressed: () => setState(() => _editando = !_editando),
                      icon: Icon(
                        _editando ? Icons.close : Icons.edit,
                        size: 16,
                      ),
                      label: Text(_editando ? 'Cancelar' : 'Editar'),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Muestra la foto guardada en el dispositivo, si existe una ruta.
              if (widget.lectura.rutaFoto.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.lectura.rutaFoto),
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),

              const SizedBox(height: 16),

              // La pantalla padre decide qué hacer al facturar; este panel solo
              // invoca el callback recibido.
              if (!widget.lectura.impreso &&
                  !_editando &&
                  widget.onFacturar != null)
                ElevatedButton.icon(
                  onPressed: widget.onFacturar,
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Hacer factura'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),

              // Lectura anterior
              if (widget.lectura.lecturaAnterior != null)
                Fila(
                  'Lectura anterior',
                  valor: widget.lectura.lecturaAnterior.toString(),
                ),

              // Lectura actual (editable)
              Fila(
                'Lectura actual',
                child:
                    _editando
                        ? TextField(
                          controller: _lecturaCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            color: color,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        )
                        : Text(
                          widget.lectura.lectura.toString(),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            color: color,
                          ),
                        ),
              ),

              // Consumo calculado
              if (consumo != null) Fila('Consumo', valor: '$consumo m³'),

              Fila(
                'Fecha y hora',
                valor: DateFormat(
                  'dd/MM/yyyy HH:mm:ss',
                ).format(widget.lectura.fechaLectura),
              ),

              if (widget.lectura.latitud != 0)
                Fila(
                  'Coordenadas GPS',
                  valor:
                      '${widget.lectura.latitud.toStringAsFixed(6)}, ${widget.lectura.longitud.toStringAsFixed(6)}',
                ),

              // Observaciones (editables)
              Fila(
                widget.lectura.lectura == 0
                    ? 'Observación (obligatoria)'
                    : 'Observaciones',
                child:
                    _editando
                        ? TextField(
                          controller: _notasCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Escribe una observación...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        )
                        : Text(
                          widget.lectura.notas?.isNotEmpty == true
                              ? widget.lectura.notas!
                              : 'Sin observaciones',
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                widget.lectura.notas?.isNotEmpty == true
                                    ? null
                                    : Colors.grey,
                            fontStyle:
                                widget.lectura.notas?.isNotEmpty == true
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                          ),
                        ),
              ),

              const SizedBox(height: 16),

              // Botón guardar edición
              if (_editando)
                ElevatedButton.icon(
                  onPressed: _guardarEdicion,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar cambios'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

              // Botón eliminar
              if (!_editando) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    // La base decide si el abonado se reinicia o si la lectura
                    // libre se elimina; luego se refresca la lista y se cierra.
                    await widget.db.eliminarLectura(widget.lectura.id);
                    widget.onActualizado();
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Eliminar lectura',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
    );
  }

  // ── Lógica de guardado ────────────────────────

  Future<void> _guardarEdicion() async {
    // Valida la lectura antes de escribirla. Una lectura de cero requiere nota.
    final nuevaLectura = int.tryParse(_lecturaCtrl.text.trim());
    if (nuevaLectura == null) {
      _snack('Número inválido');
      return;
    }
    final notas = _notasCtrl.text.trim();
    if (nuevaLectura == 0 && notas.isEmpty) {
      _snack('Lectura 0 requiere una observación', color: Colors.orange);
      return;
    }

    // Persiste el cambio en SQLite a través de Drift. La base actualiza también
    // datos asociados, como lectura anterior, fecha y estado de sincronización.
    await widget.db.actualizarLecturaAbonado(
      id: widget.lectura.id,
      codigoMedidor: widget.lectura.codigoMedidor ?? '',
      nuevaLectura: nuevaLectura,
      rutaFoto: widget.lectura.rutaFoto,
      latitud: widget.lectura.latitud,
      longitud: widget.lectura.longitud,
      notas: notas.isEmpty ? null : notas,
    );

    // Avisa al padre (por ejemplo, HistorialScreen) para refrescar sus datos.
    widget.onActualizado();
    if (mounted) {
      setState(() => _editando = false);
      _snack('✓ Lectura actualizada', color: Colors.green);
    }
  }

  // Presenta validaciones y confirmaciones breves dentro de esta pantalla.
  void _snack(String mensaje, {Color? color}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
  }

  @override
  void dispose() {
    // Libera los controladores de los campos al cerrar el panel.
    _lecturaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }
}
