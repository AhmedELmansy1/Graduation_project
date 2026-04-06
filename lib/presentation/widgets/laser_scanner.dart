import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class LaserScanner extends StatelessWidget {
  final bool isScanning;
  final Widget child;
  final Color color;

  const LaserScanner({
    super.key, 
    required this.isScanning, 
    required this.child,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isScanning)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
              ),
            ),
          ),
        if (isScanning)
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: color, blurRadius: 15, spreadRadius: 2),
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 30, spreadRadius: 5),
              ],
              gradient: LinearGradient(
                colors: [Colors.transparent, color, Colors.transparent],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat())
           .moveY(begin: 0, end: 250, duration: 2.seconds, curve: Curves.easeInOut),
      ],
    );
  }
}
