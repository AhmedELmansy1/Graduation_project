import 'package:flutter/material.dart';

class ParallaxCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double maxTilt;

  const ParallaxCard({
    super.key,
    required this.child,
    required this.onTap,
    this.maxTilt = 0.05,
  });

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard> {
  double _x = 0.0;
  double _y = 0.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final size = context.size!;
        setState(() {
          _x = (event.localPosition.dy / size.height) - 0.5;
          _y = (event.localPosition.dx / size.width) - 0.5;
        });
      },
      onExit: (_) => setState(() {
        _x = 0.0;
        _y = 0.0;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_x * widget.maxTilt)
            ..rotateY(-_y * widget.maxTilt),
          alignment: FractionalOffset.center,
          child: widget.child,
        ),
      ),
    );
  }
}
