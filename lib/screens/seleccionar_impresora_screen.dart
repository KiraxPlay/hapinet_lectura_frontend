// lib/screens/seleccionar_impresora_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import '../models/acueducto.dart';
import '../services/impresora_service.dart';

class SeleccionarImpresoraScreen extends StatefulWidget {
  final Acueducto acueducto;
  const SeleccionarImpresoraScreen({super.key, required this.acueducto});

  @override
  State<SeleccionarImpresoraScreen> createState() =>
      _SeleccionarImpresoraScreenState();
}

class _SeleccionarImpresoraScreenState
    extends State<SeleccionarImpresoraScreen> {
  List<BluetoothDevice> _dispositivos = [];
  bool _buscando = false;
  bool _probando = false;
  String? _macGuardada;
  String? _nombreGuardado;
  late final ImpresoraService _service;

  @override
  void initState() {
    super.initState();
    _service = ImpresoraService(acueducto: widget.acueducto);
    _cargarGuardada();
    _buscar();
  }

  Future<void> _cargarGuardada() async {
    final mac    = await _service.obtenerMacGuardada();
    final nombre = await _service.obtenerNombreGuardado();
    if (mounted) setState(() {
      _macGuardada    = mac;
      _nombreGuardado = nombre;
    });
  }

  void _buscar() {
    setState(() { _buscando = true; _dispositivos = []; });

    FlutterBluetoothPrinter.discovery.listen(
      (state) {
        if (!mounted) return;
        if (state is BluetoothDevice) {
          // Un dispositivo encontrado
          setState(() {
            if (!_dispositivos.any((d) => d.address == state.address)) {
              _dispositivos = [..._dispositivos, state];
            }
          });
        } else if (state is DiscoveryResult) {
          // Lista final de dispositivos
          setState(() => _dispositivos = state.devices);
        }
      },
      onDone: () {
        if (mounted) setState(() => _buscando = false);
      },
      onError: (_) {
        if (mounted) setState(() => _buscando = false);
      },
    );

    // Parar después de 8 segundos
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) setState(() => _buscando = false);
    });
  }

  Future<void> _seleccionar(BluetoothDevice dev) async {
    await _service.guardarImpresora(dev.address, dev.name ?? 'Impresora');
    if (mounted) {
      setState(() {
        _macGuardada    = dev.address;
        _nombreGuardado = dev.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✓ Impresora ${dev.name} configurada'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _probar(BluetoothDevice dev) async {
    setState(() => _probando = true);
    try {
      final r = await _service.imprimirPrueba(dev.address);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(r.exitoso
              ? '✓ Prueba impresa correctamente'
              : r.error ?? 'Error'),
          backgroundColor: r.exitoso ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _probando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar impresora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _buscando ? null : _buscar,
            tooltip: 'Buscar de nuevo',
          ),
        ],
      ),
      body: Column(
        children: [
          // Impresora configurada
          if (_macGuardada != null)
            Container(
              color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Configurada',
                          style: TextStyle(
                              fontSize: 11, color: Colors.green)),
                      Text(_nombreGuardado ?? _macGuardada!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ]),
            ),

          // Lista
          Expanded(
            child: _buscando && _dispositivos.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Buscando impresoras Bluetooth...'),
                      ],
                    ),
                  )
                : _dispositivos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bluetooth_disabled,
                                size: 56, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('No se encontraron impresoras',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              'Asegúrate de que la SAT AF330\nestá encendida y en modo Bluetooth.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _buscar,
                              icon: const Icon(Icons.search),
                              label: const Text('Buscar de nuevo'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _dispositivos.length,
                        itemBuilder: (_, i) {
                          final dev = _dispositivos[i];
                          final sel = dev.address == _macGuardada;
                          return Card(
                            child: ListTile(
                              leading: Icon(Icons.print,
                                  color: sel ? Colors.green : Colors.grey,
                                  size: 32),
                              title: Text(
                                dev.name ?? 'Dispositivo desconocido',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(dev.address),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (sel)
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                  const SizedBox(width: 4),
                                  _probando
                                      ? const SizedBox(
                                          width: 20, height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2))
                                      : IconButton(
                                          icon: const Icon(
                                              Icons.print_outlined),
                                          tooltip: 'Prueba de impresión',
                                          onPressed: () => _probar(dev),
                                        ),
                                ],
                              ),
                              onTap: () => _seleccionar(dev),
                            ),
                          );
                        },
                      ),
          ),

          if (_buscando)
            const LinearProgressIndicator(),
        ],
      ),
    );
  }
}