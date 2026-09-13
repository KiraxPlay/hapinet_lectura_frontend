// lib/components/funciones/detalle_lectura_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database.dart';
import '../../models/acueducto.dart';
import 'color_sector.dart';
import 'fila.dart';

class DetalleLecturaSheet extends StatefulWidget {
  final Lectura lectura;
  final AppDatabase db;
  final VoidCallback onActualizado;
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
    _lecturaCtrl = TextEditingController(
      text: widget.lectura.lectura.toString(),
    );
    _notasCtrl = TextEditingController(text: widget.lectura.notas ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final color = colorDeSector(widget.lectura.sector);

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

              // Foto
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
              if (widget.lectura.lecturaAnterior != null &&
                  widget.lectura.lectura > 0)
                Fila(
                  'Consumo',
                  valor:
                      '${widget.lectura.lectura - widget.lectura.lecturaAnterior!} m³',
                ),

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

              if (widget.lectura.precision != null)
                Fila(
                  'Precisión GPS',
                  valor: '${widget.lectura.precision!.toStringAsFixed(1)} m',
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

    await widget.db.actualizarLecturaAbonado(
      codigoMedidor: widget.lectura.codigoMedidor ?? '',
      nuevaLectura: nuevaLectura,
      rutaFoto: widget.lectura.rutaFoto,
      latitud: widget.lectura.latitud,
      longitud: widget.lectura.longitud,
      notas: notas.isEmpty ? null : notas,
    );

    widget.onActualizado();
    if (mounted) {
      setState(() => _editando = false);
      _snack('✓ Lectura actualizada', color: Colors.green);
    }
  }

  void _snack(String mensaje, {Color? color}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
  }

  @override
  void dispose() {
    _lecturaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }
}
