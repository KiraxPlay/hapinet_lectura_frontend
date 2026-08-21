// lib/components/captura/guia_encuadre.dart
import 'package:flutter/material.dart';

class GuiaEncuadre extends StatelessWidget {
  const GuiaEncuadre({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Centra el display del medidor aquí',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}