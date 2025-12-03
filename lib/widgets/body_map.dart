import 'package:flutter/material.dart';

//O widget BodyMap aceita uma função de callback para notificar o componente pai sobre a área selecionada.
class BodyMap extends StatelessWidget {
  final Function(String selectedArea) onAreaSelected;

  const BodyMap({super.key, required this.onAreaSelected});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/corpo_icon.jpg',
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: height * 0.02,
              left: width * 0.40,
              width: width * 0.20,
              height: height * 0.10,
              child: _Hotspot(
                label: 'Cabeça',
                onTap: onAreaSelected,
              ),
            ),

            Positioned(
              top: height * 0.18,
              left: width * 0.32,
              width: width * 0.36,
              height: height * 0.15,
              child: _Hotspot(
                label: 'Peito',
                onTap: onAreaSelected,
              ),
            ),
            Positioned(
              top: height * 0.33,
              left: width * 0.32,
              width: width * 0.36,
              height: height * 0.15,
              child: _Hotspot(
                label: 'Abdômen',
                onTap: onAreaSelected,
              ),
            ),
            Positioned(
              top: height * 0.18,
              left: width * 0.05,
              width: width * 0.22,
              height: height * 0.35,
              child: _Hotspot(
                label: 'Braço Direito',
                onTap: onAreaSelected,
              ),
            ),
            Positioned(
              top: height * 0.18,
              right: width * 0.05,
              width: width * 0.22,
              height: height * 0.35,
              child: _Hotspot(
                label: 'Braço Esquerdo',
                onTap: onAreaSelected,
              ),
            ),
            Positioned(
              top: height * 0.50,
              left: width * 0.35,
              width: width * 0.12,
              height: height * 0.40,
              child: _Hotspot(
                label: 'Perna Direita',
                onTap: onAreaSelected,
              ),
            ),
            Positioned(
              top: height * 0.50,
              left: width * 0.52,
              width: width * 0.12,
              height: height * 0.40,
              child: _Hotspot(
                label: 'Perna Esquerda',
                onTap: onAreaSelected,
              ),
            ),
          ],
        );
      },
    );
  }
}
//Widget privado e transparente que detecta o toque e retorna o rótulo da área.
class _Hotspot extends StatelessWidget {
  final String label;
  final Function(String) onTap;

  const _Hotspot({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(label),
      child: Container(
        color: Colors.transparent,
      ),
    );
  }
}
