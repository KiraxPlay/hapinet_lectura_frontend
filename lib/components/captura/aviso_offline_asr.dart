// lib/components/captura/aviso_offline_asr.dart
// Diálogo que aparece la primera vez que el técnico usa el micrófono
// si el idioma español no está descargado para uso offline
import 'package:flutter/material.dart';

Future<void> mostrarAvisoOfflineAsr(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.wifi_off, color: Colors.orange, size: 36),
      title: const Text('Voz a texto sin internet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'El micrófono funciona mejor si descargas el idioma '
            'español para uso offline.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pasos (una sola vez):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),
          _paso('1', 'Abre Ajustes del celular'),
          _paso('2', 'Busca "Voz a texto" o "Reconocimiento de voz"'),
          _paso('3', 'Entra a Google Voice Typing → Idiomas'),
          _paso('4', 'Busca Español (Colombia) y toca ⬇ para descargar'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sin descargarlo, el micrófono necesita internet para funcionar.',
                    style: TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Ahora no'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}

Widget _paso(String numero, String texto) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.only(right: 8, top: 1),
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              numero,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(texto, style: const TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );
}