import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/translations.dart';
import '../../widgets/forensic_backgrounds.dart';
import '../image_analysis/image_analysis_screen.dart';
import '../video_analysis/video_analysis_screen.dart';
import '../audio_analysis/audio_analysis_screen.dart';
import '../logs/logs_screen.dart';
import '../settings/settings_screen.dart';
import '../../providers/settings_provider.dart';
import '../../../core/services/security_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _navigateToSecureArea(BuildContext context, Widget screen) async {
    final authenticated = await SecurityService.authenticate();
    if (authenticated && context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final lang = settings.locale.languageCode;
    String t(String key) => Translations.translate(key, lang);
    final primaryColor = AppColors.dsPrimary;
    final textColor = Colors.white;

    return Scaffold(
      backgroundColor: AppColors.dsBackground,
      body: ForensicBackground(
        type: BackgroundType.matrix,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: GridPainter(primaryColor)),
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  _buildCyberHeader(context, t, primaryColor, textColor),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _buildNeuralRadar(primaryColor),
                          const SizedBox(height: 25),
                          _buildDeepDashboard(primaryColor),
                          const SizedBox(height: 30),
                          _buildMissionControl(context, t, primaryColor),
                          const SizedBox(height: 30),
                          _buildLiveKernelTerminal(primaryColor),
                          const SizedBox(height: 30),
                          _buildEvidenceVault(context, primaryColor),
                          const SizedBox(height: 40),
                          _buildForensicSignature(primaryColor),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildScanningLine(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCyberHeader(BuildContext context, String Function(String) t, Color primary, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildHexagonAvatar(primary),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("DEEPSECURE-AI", style: TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3)),
                Text("CORE UNIT ACTIVE // 0xAF42", style: TextStyle(color: primary.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          _buildCyberIconButton(Icons.history_rounded, primary, () => _navigateToSecureArea(context, const LogsScreen())),
          const SizedBox(width: 12),
          _buildCyberIconButton(Icons.settings_suggest_rounded, primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
        ],
      ),
    );
  }

  Widget _buildHexagonAvatar(Color primary) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.black,
        child: Icon(Icons.psychology_rounded, color: primary, size: 28),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds);
  }

  Widget _buildNeuralRadar(Color primary) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primary.withOpacity(0.2), width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...List.generate(3, (i) => Container(
            width: 60.0 * (i + 1),
            height: 60.0 * (i + 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primary.withOpacity(0.1)),
            ),
          )),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.1),
              boxShadow: [BoxShadow(color: primary.withOpacity(0.5), blurRadius: 20)],
            ),
            child: Icon(Icons.radar_rounded, color: primary, size: 20),
          ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 1.seconds, curve: Curves.easeInOut),
          
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 2 * math.pi),
            duration: const Duration(seconds: 10),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value,
                child: Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [Colors.transparent, primary.withOpacity(0.3), Colors.transparent],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ).animate(onPlay: (c) => c.repeat()),
        ],
      ),
    );
  }

  Widget _buildDeepDashboard(Color primary) {
    return GlassCard(
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: primary.withOpacity(0.3)),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMetric("99.9%", "NEURAL ACCURACY", primary),
                _buildMetric("12ms", "LATENCY", AppColors.dsSecondary),
                _buildMetric("ACTIVE", "SHIELD", Colors.greenAccent),
              ],
            ),
            const SizedBox(height: 25),
            _buildVisualizer(primary),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 7, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildVisualizer(Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(20, (i) => Container(
        width: 4, height: 30 + math.Random().nextInt(30).toDouble(),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleY(begin: 0.2, end: 1.0, duration: (400 + i * 50).ms)),
    );
  }

  Widget _buildMissionControl(BuildContext context, String Function(String) t, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("MISSION CONTROL", style: TextStyle(color: primary.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(context, "IMAGE SCAN", Icons.filter_center_focus_rounded, primary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ImageAnalysisScreen()))),
            _buildActionCard(context, "VIDEO SCAN", Icons.video_camera_back_rounded, AppColors.dsSecondary, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoAnalysisScreen()))),
            _buildActionCard(context, "AUDIO SCAN", Icons.settings_voice_rounded, AppColors.dsAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AudioAnalysisScreen()))),
            _buildActionCard(context, "LIVE SHIELD", Icons.radar_rounded, Colors.redAccent, () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveKernelTerminal(Color primary) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("> DEEPSECURE-AI KERNEL BOOT...", style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontFamily: 'monospace')),
          const Text("> LOADING EFFICIENTNET.ONNX...", style: TextStyle(color: Colors.white38, fontSize: 9, fontFamily: 'monospace')),
          Text("> NEURAL LINK ESTABLISHED: OK", style: TextStyle(color: primary, fontSize: 9, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 5.seconds);
  }

  Widget _buildEvidenceVault(BuildContext context, Color primary) {
    return GestureDetector(
      onTap: () => _navigateToSecureArea(context, const LogsScreen()),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dsGold.withOpacity(0.3)),
        child: Row(
          children: [
            Icon(Icons.lock_person_rounded, color: AppColors.dsGold, size: 28),
            const SizedBox(width: 20),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SECURE VAULT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
                Text("ENCRYPTED FORENSIC LOGS", style: TextStyle(color: Colors.white24, fontSize: 8)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildForensicSignature(Color primary) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.fingerprint_rounded, color: primary.withOpacity(0.2), size: 40),
          const SizedBox(height: 10),
          Text("DS-AI // UNIT-824", style: TextStyle(color: primary.withOpacity(0.2), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 5)),
        ],
      ),
    );
  }

  Widget _buildCyberIconButton(IconData icon, Color primary, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primary.withOpacity(0.2))),
        child: Icon(icon, color: primary, size: 18),
      ),
    );
  }

  Widget _buildScanningLine(Color primary) {
    return IgnorePointer(
      child: Container(
        width: double.infinity, height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.transparent, primary.withOpacity(0.5), Colors.transparent]),
        ),
      ).animate(onPlay: (c) => c.repeat()).move(begin: const Offset(0, 0), end: const Offset(0, 800), duration: 4.seconds),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color.withOpacity(0.1)..strokeWidth = 0.5;
    for (var i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    for (var i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
