import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ResultIndicator extends StatelessWidget {
  final double score;
  final Color color;

  const ResultIndicator({super.key, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                )
              ],
            ),
          ),
          
          // The Progress Ring
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: score),
            duration: 2.seconds,
            curve: Curves.easeOutQuart,
            builder: (context, value, _) => SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                color: color,
                backgroundColor: Colors.white.withOpacity(0.05),
                strokeCap: StrokeCap.round,
              ),
            ),
          ),

          // Percentage Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(score * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                  shadows: [
                    Shadow(color: color, blurRadius: 10),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds),
              
              Text(
                'ACCURACY',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: color.withOpacity(0.7),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
