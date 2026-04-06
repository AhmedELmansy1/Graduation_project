import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

enum BackgroundType { particles, grid, waves, circuit, scanner, dna, cosmos, matrix }

class ForensicBackground extends StatelessWidget {
  final BackgroundType type;
  final Widget child;

  const ForensicBackground({super.key, required this.type, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: AppColors.backgroundOled),
        _buildEffect(context),
        child,
      ],
    );
  }

  Widget _buildEffect(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primary = Theme.of(context).primaryColor;

    switch (type) {
      case BackgroundType.matrix:
        return RepaintBoundary(
          child: Stack(
            children: [
              // Dynamic Flowing Matrix Code Rain
              ...List.generate(15, (i) {
                final r = math.Random(i);
                final duration = (5 + r.nextInt(10)).seconds;
                final left = r.nextDouble() * size.width;
                return Positioned(
                  left: left,
                  top: -200,
                  child: Column(
                    children: List.generate(20, (j) {
                      return Text(
                        r.nextBool() ? "1" : "0",
                        style: TextStyle(
                          color: primary.withOpacity(0.15),
                          fontSize: 8,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ).animate(onPlay: (c) => c.repeat()).moveY(
                        begin: -200,
                        end: size.height + 200,
                        duration: duration,
                      ),
                );
              }),
              // Glowing pulse overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [primary.withOpacity(0.05), Colors.transparent],
                    radius: 1.2,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.2, end: 0.5, duration: 4.seconds),
            ],
          ),
        );
      case BackgroundType.particles:
        return RepaintBoundary(
          child: Stack(
            children: List.generate(15, (index) {
              final random = math.Random(index);
              return Positioned(
                top: random.nextDouble() * size.height,
                left: random.nextDouble() * size.width,
                child: Container(
                  width: random.nextDouble() * 3 + 1,
                  height: random.nextDouble() * 3 + 1,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 5)],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .move(duration: (10 + random.nextInt(10)).seconds, end: Offset(random.nextDouble() * 100 - 50, random.nextDouble() * 100 - 50))
                 .fade(begin: 0.1, end: 0.6),
              );
            }),
          ),
        );

      case BackgroundType.grid:
        return RepaintBoundary(
          child: Stack(
            children: [
              CustomPaint(
                size: size,
                painter: GridPainter(color: primary.withOpacity(0.05)),
              ),
              // Subtler pulsing glow
              Center(
                child: Container(
                  width: size.width,
                  height: size.height,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [primary.withOpacity(0.08), Colors.transparent],
                      radius: 0.8,
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.2, end: 0.6, duration: 4.seconds),
              ),
            ],
          ),
        );

      case BackgroundType.waves:
        return RepaintBoundary(
          child: Opacity(
            opacity: 0.08,
            child: Stack(
              children: List.generate(3, (i) => Positioned(
                bottom: -50, left: -size.width * 0.5,
                child: Icon(Icons.waves, size: size.width * 2, color: primary)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .rotate(begin: -0.05 * (i+1), end: 0.05 * (i+1), duration: (10 + i * 5).seconds)
                    .scale(begin: const Offset(1,1), end: Offset(1.1, 1 + i*0.1)),
              )),
            ),
          ),
        );

      case BackgroundType.dna:
        return Center(
          child: RepaintBoundary(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: 0.03,
                  child: Icon(Icons.fingerprint_rounded, size: size.width * 1.2, color: primary)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1,1), end: const Offset(1.3, 1.3), duration: 15.seconds),
                ),
                // Spinning DNA segments simulation
                ...List.generate(8, (i) => Transform.rotate(
                  angle: i * (math.pi / 4),
                  child: Container(
                    width: size.width * 0.8,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.transparent, primary.withOpacity(0.1), Colors.transparent]),
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat()).rotate(duration: (20 + i * 2).seconds)),
              ],
            ),
          ),
        );

      case BackgroundType.scanner:
        return RepaintBoundary(
          child: Stack(
            children: [
              Container(
                width: size.width,
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, primary.withOpacity(0.15), primary.withOpacity(0.02), Colors.transparent],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat()).move(begin: Offset(0, -200), end: Offset(0, size.height + 200), duration: 4.seconds),
              // Side laser lines
              Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 1, color: primary.withOpacity(0.1))),
              Positioned(right: 0, top: 0, bottom: 0, child: Container(width: 1, color: primary.withOpacity(0.1))),
            ],
          ),
        );

      case BackgroundType.cosmos:
        return RepaintBoundary(
          child: Stack(
            children: [
              ...List.generate(20, (i) {
                final r = math.Random(i);
                return Positioned(
                  top: r.nextDouble() * size.height,
                  left: r.nextDouble() * size.width,
                  child: Container(
                    width: 2, height: 2,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(r.nextDouble()), shape: BoxShape.circle),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: (2 + r.nextInt(3)).seconds),
                );
              }),
              Center(
                child: Container(
                  width: size.width * 0.8, height: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [primary.withOpacity(0.05), Colors.transparent]),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 8.seconds),
              ),
            ],
          ),
        );

      case BackgroundType.circuit:
        return CustomPaint(
          size: size,
          painter: CircuitPainter(color: primary.withOpacity(0.03)),
        );

      default:
        return Container();
    }
  }
}

class CircuitPainter extends CustomPainter {
  final Color color;
  CircuitPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1..style = PaintingStyle.stroke;
    final r = math.Random(42);
    for (int i = 0; i < 15; i++) {
      double x = r.nextDouble() * size.width;
      double y = r.nextDouble() * size.height;
      final path = Path()..moveTo(x, y);
      for (int j = 0; j < 4; j++) {
        if (r.nextBool()) x += 40; else y += 40;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
      canvas.drawCircle(Offset(x, y), 2, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 50) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
