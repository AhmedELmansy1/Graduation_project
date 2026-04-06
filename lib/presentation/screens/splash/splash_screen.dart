import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../onboarding/onboarding_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/translations.dart';
import '../../providers/settings_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _statusText = '';
  double _progress = 0.0;
  final List<String> _bootLogs = [];

  @override
  void initState() {
    super.initState();
    _startBootSequence();
  }

  _startBootSequence() async {
    final settings = ref.read(settingsProvider);
    final lang = settings.locale.languageCode;
    String t(String key) => Translations.translate(key, lang);

    final sequences = [
      {'text': t('system_init'), 'progress': 0.2},
      {'text': '> KERNEL_LOAD_SUCCESS', 'progress': 0.3},
      {'text': t('loading_ai'), 'progress': 0.5},
      {'text': '> NEURAL_V3_READY', 'progress': 0.6},
      {'text': t('securing_env'), 'progress': 0.8},
      {'text': '> AES_256_HANDSHAKE', 'progress': 0.9},
      {'text': 'FORGERY DETECTION ACTIVE', 'progress': 1.0}
    ];

    for (var seq in sequences) {
      if (mounted) {
        setState(() {
          _statusText = seq['text'] as String;
          _progress = seq['progress'] as double;
          _bootLogs.add(seq['text'] as String);
          if (_bootLogs.length > 3) _bootLogs.removeAt(0);
        });
      }
      await Future.delayed(const Duration(milliseconds: 600));
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.1, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          transitionDuration: 1200.ms,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. CYBER GRID BACKGROUND
          CustomPaint(
            size: size,
            painter: _SplashGridPainter(color: AppColors.eliteGold.withOpacity(0.05)),
          ),

          // 2. AMBIENT GLOWS
          Positioned(
            top: -100, left: -100,
            child: _buildAmbientOrb(AppColors.eliteGold.withOpacity(0.1), 300),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).move(begin: const Offset(-20, -20), end: const Offset(20, 20), duration: 5.seconds),
          
          Positioned(
            bottom: -150, right: -150,
            child: _buildAmbientOrb(AppColors.secondary.withOpacity(0.05), 400),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).move(begin: const Offset(30, 30), end: const Offset(-30, -30), duration: 7.seconds),

          // 3. SCANNING LINE EFFECT
          _buildScanningLine(size),

          // 4. CENTRAL CONTENT
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rotating Cyber Hex Frame
              _buildCyberLogo(),
              
              const SizedBox(height: 60),
              
              // APP NAME WITH GLITCH EFFECT
              _buildGlitchTitle(),
              
              const SizedBox(height: 80),
              
              // ADVANCED BOOT CONSOLE
              _buildBootConsole(),
            ],
          ),

          // 5. VERSION TAG
          Positioned(
            bottom: 40,
            child: const Text(
              "PRO EDITION v3.5 // ENCRYPTED NODE",
              style: TextStyle(color: Colors.white10, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 4),
            ).animate().fadeIn(delay: 1.seconds),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientOrb(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }

  Widget _buildScanningLine(Size size) {
    return IgnorePointer(
      child: Container(
        width: size.width,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.eliteGold.withOpacity(0.02),
              AppColors.eliteGold.withOpacity(0.15),
              AppColors.eliteGold.withOpacity(0.02),
              Colors.transparent,
            ],
          ),
        ),
      ).animate(onPlay: (c) => c.repeat()).move(begin: Offset(0, -size.height), end: Offset(0, size.height), duration: 4.seconds),
    );
  }

  Widget _buildCyberLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing Outer Hex (Simulated with rotation)
        ...List.generate(2, (i) => Container(
          width: 180 + (i * 20), height: 180 + (i * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.eliteGold.withOpacity(0.1 - (i * 0.05)), width: 1),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: (2 + i).seconds)),

        // Rotating Data Ring
        Container(
          width: 160, height: 160,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.eliteGold.withOpacity(0.2), width: 2, style: BorderStyle.solid),
          ),
          child: CircularProgressIndicator(
            value: 0.7,
            strokeWidth: 1,
            color: AppColors.eliteGold.withOpacity(0.3),
          ),
        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 8.seconds),

        // Core Logo
        Container(
          width: 110, height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            border: Border.all(color: AppColors.eliteGold.withOpacity(0.4), width: 2),
            boxShadow: [
              BoxShadow(color: AppColors.eliteGold.withOpacity(0.4), blurRadius: 30, spreadRadius: 2),
              BoxShadow(color: AppColors.secondary.withOpacity(0.2), blurRadius: 50, spreadRadius: -5),
            ],
          ),
          child: const Center(
            child: Icon(Icons.security_rounded, size: 55, color: AppColors.eliteGold),
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.elasticOut).shimmer(delay: 1.seconds, duration: 3.seconds),
      ],
    );
  }

  Widget _buildGlitchTitle() {
    return Column(
      children: [
        Stack(
          children: [
            Text(
              'FORGERY',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.eliteGold.withOpacity(0.5), letterSpacing: 12, fontFamily: 'Orbitron'),
            ).animate(onPlay: (c) => c.repeat()).shake(hz: 4, offset: const Offset(2, 2), duration: 2.seconds),
            const Text(
              'FORGERY',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.eliteGold, letterSpacing: 12, fontFamily: 'Orbitron'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'DETECTION SYSTEM',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 10, fontFamily: 'Orbitron'),
        ).animate().fadeIn(delay: 400.ms).shimmer(delay: 1.seconds, duration: 2.seconds),
      ],
    );
  }

  Widget _buildBootConsole() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle))
                  .animate(onPlay: (c) => c.repeat()).fade(duration: 500.ms),
              const SizedBox(width: 10),
              const Text("BOOT_SEQUENCE_ACTIVE", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 20),
          ..._bootLogs.map((log) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              log,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: log == _statusText ? AppColors.eliteGold : Colors.white24,
                fontWeight: log == _statusText ? FontWeight.bold : FontWeight.normal,
              ),
            ).animate(key: ValueKey(log)).fadeIn().slideX(begin: 0.1, end: 0),
          )),
          const SizedBox(height: 20),
          // Dynamic Progress Bar
          Stack(
            children: [
              Container(
                height: 4, width: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
              ),
              AnimatedContainer(
                duration: 400.ms,
                height: 4, width: 260 * _progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.eliteGold, AppColors.secondary]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: AppColors.eliteGold.withOpacity(0.3), blurRadius: 10)],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0);
  }
}

class _SplashGridPainter extends CustomPainter {
  final Color color;
  _SplashGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

