import 'package:flutter/material.dart';

/// Envolve um widget clicável para dar feedback visual ao passar o mouse
/// por cima: leve aumento de escala + opacidade, com transição suave.
class HoverScale extends StatefulWidget {
  final Widget child;
  final double scale;

  const HoverScale({super.key, required this.child, this.scale = 1.05});

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _hovering ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: widget.child,
        ),
      ),
    );
  }
}
