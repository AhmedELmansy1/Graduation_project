import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/forensic_backgrounds.dart';
import '../../widgets/glass_card.dart';

class AboutDeveloperScreen extends StatefulWidget {
  const AboutDeveloperScreen({super.key});

  @override
  State<AboutDeveloperScreen> createState() => _AboutDeveloperScreenState();
}

class _AboutDeveloperScreenState extends State<AboutDeveloperScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playContinuousAmbient();
  }

  Future<void> _playContinuousAmbient() async {
    try {
      // Using a longer, high-tech ambient loop for a deeper vibe
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-15.mp3'));
      await _audioPlayer.setVolume(0.4); // Set to a subtle background volume
    } catch (e) {
      debugPrint("Audio loop error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop(); // Ensure audio stops when leaving
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('ENGINEER PROFILE', style: TextStyle(letterSpacing: 4, fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white54)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ForensicBackground(
        type: BackgroundType.matrix,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
          child: Column(
            children: [
              _buildEliteAvatar(primaryColor),
              const SizedBox(height: 30),
              _buildIdentityHeader(primaryColor),
              const SizedBox(height: 40),
              
              _buildModernSection(
                title: "THE MISSION",
                arTitle: "المهمة",
                icon: Icons.track_changes_rounded,
                child: _buildMissionText(),
              ),
              
              const SizedBox(height: 30),
              _buildModernSection(
                title: "TECHNICAL ARSENAL",
                arTitle: "الترسانة التقنية",
                icon: Icons.memory_rounded,
                child: _buildArsenalGrid(primaryColor),
              ),
              
              const SizedBox(height: 30),
              _buildModernSection(
                title: "SKILL MATRICES",
                arTitle: "مصفوفة المهارات",
                icon: Icons.auto_awesome_motion_rounded,
                child: _buildSkillMatrices(primaryColor),
              ),
              
              const SizedBox(height: 30),
              _buildModernSection(
                title: "CLASSIFIED PROJECTS",
                arTitle: "مشاريع سرية",
                icon: Icons.folder_special_rounded,
                child: _buildClassifiedOps(),
              ),
              
              const SizedBox(height: 30),
              _buildModernSection(
                title: "NEURAL NETWORK",
                arTitle: "الشبكة العصبية",
                icon: Icons.share_rounded,
                child: _buildSocialArsenal(primaryColor),
              ),
              
              const SizedBox(height: 60),
              _buildFooterSignature(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEliteAvatar(Color primary) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing Rings
        ...List.generate(3, (i) => Container(
          width: 140 + (i * 20),
          height: 140 + (i * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primary.withOpacity(0.1 - (i * 0.03)), width: 1),
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: (2 + i).seconds)),
        
        // Rotating Hexagon/Cyber Frame
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.eliteGold.withOpacity(0.2), width: 2, style: BorderStyle.solid),
          ),
          child: Stack(
            children: List.generate(8, (i) => Positioned(
              top: 85 + 75 * (i % 2 == 0 ? 1 : -1) * (i < 4 ? 1 : -1),
              left: 85 + 75 * (i % 4 < 2 ? 1 : -1),
              child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppColors.eliteGold, shape: BoxShape.circle)),
            )),
          ),
        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 20.seconds),

        // Main Avatar
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.black, AppColors.eliteGold.withOpacity(0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(color: AppColors.eliteGold.withOpacity(0.4), blurRadius: 40, spreadRadius: 2),
              BoxShadow(color: primary.withOpacity(0.2), blurRadius: 60, spreadRadius: -5),
            ],
            border: Border.all(color: AppColors.eliteGold.withOpacity(0.3), width: 2),
          ),
          child: ClipOval(
            child: Center(
              child: Icon(Icons.code_rounded, size: 65, color: AppColors.eliteGold)
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2.seconds, color: Colors.white24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityHeader(Color primary) {
    return Column(
      children: [
        const Text(
          "AHMED ELMANSY",
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4, fontFamily: 'Orbitron'),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0).shimmer(delay: 1.seconds, duration: 3.seconds),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 30, height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, AppColors.eliteGold]))),
            const SizedBox(width: 12),
            const Text(
              "LEAD FORENSIC ARCHITECT",
              style: TextStyle(color: AppColors.eliteGold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 4),
            ),
            const SizedBox(width: 12),
            Container(width: 30, height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.eliteGold, Colors.transparent]))),
          ],
        ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 1)),
      ],
    );
  }

  Widget _buildModernSection({required String title, required String arTitle, required IconData icon, required Widget child}) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.eliteGold.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppColors.eliteGold, size: 18),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                  Text(
                    arTitle,
                    style: TextStyle(color: AppColors.eliteGold.withOpacity(0.5), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildMissionText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dedicated to fortifying the digital realm through advanced AI-driven forensics. Bridging the gap between neural intelligence and digital integrity to secure tomorrow's evidence today.",
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.8, fontWeight: FontWeight.w400, letterSpacing: 0.5),
        ),
        const SizedBox(height: 15),
        Text(
          "مكرس لتعزيز العالم الرقمي من خلال تقنيات التحليل الجنائي المتقدمة القائمة على الذكاء الاصطناعي. سد الفجوة بين الذكاء العصبي والنزاهة الرقمية لتأمين أدلة الغد اليوم.",
          textDirection: TextDirection.rtl,
          style: TextStyle(color: AppColors.eliteGold.withOpacity(0.6), fontSize: 13, height: 1.8, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildArsenalGrid(Color primary) {
    final tools = [
      {'name': 'CYBER-SECURITY', 'icon': Icons.shield_rounded, 'color': AppColors.neonCyan, 'desc': 'Digital Defense'},
      {'name': 'NEURAL ENGINES', 'icon': Icons.auto_awesome_rounded, 'color': AppColors.neonGreen, 'desc': 'AI Processing'},
      {'name': 'FLUTTER CORE', 'icon': Icons.flutter_dash_rounded, 'color': Colors.lightBlue, 'desc': 'App Architecture'},
      {'name': 'DATA MINING', 'icon': Icons.query_stats_rounded, 'color': AppColors.neonOrange, 'desc': 'Pattern Intel'},
      {'name': 'ENCRYPTION', 'icon': Icons.enhanced_encryption_rounded, 'color': AppColors.neonPurple, 'desc': 'AES-256 Protocol'},
      {'name': 'FORENSICS', 'icon': Icons.fingerprint_rounded, 'color': Colors.redAccent, 'desc': 'Evidence Logic'},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tools.map((tool) => Container(
        width: 155, // Fixed width for smaller, consistent chips
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: (tool['color'] as Color).withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (tool['color'] as Color).withOpacity(0.15)),
          boxShadow: [
            BoxShadow(color: (tool['color'] as Color).withOpacity(0.05), blurRadius: 10, spreadRadius: -2),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (tool['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(tool['icon'] as IconData, size: 16, color: tool['color'] as Color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tool['name'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  Text(
                    tool['desc'] as String,
                    style: TextStyle(color: (tool['color'] as Color).withOpacity(0.5), fontSize: 7, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 4.seconds, color: (tool['color'] as Color).withOpacity(0.1))).toList(),
    );
  }

  Widget _buildSkillMatrices(Color primary) {
    final skills = [
      {'label': 'AI Forensics', 'value': 0.95},
      {'label': 'App Architecture', 'value': 0.90},
      {'label': 'Cyber Security', 'value': 0.85},
    ];

    return Column(
      children: skills.map((skill) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(skill['label'] as String, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                Text("${((skill['value'] as double) * 100).toInt()}%", style: const TextStyle(color: AppColors.eliteGold, fontSize: 11, fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: skill['value'] as double,
                backgroundColor: Colors.white.withOpacity(0.05),
                color: AppColors.eliteGold,
                minHeight: 4,
              ),
            ).animate().shimmer(duration: 2.seconds),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildClassifiedOps() {
    final ops = [
      {'id': 'OPS-824', 'name': 'FORGERY DETECTION V3.5', 'status': 'ACTIVE', 'desc': 'AI Image Integrity Protocol'},
      {'id': 'SEC-X', 'name': 'ENCRYPTED DATA VAULT', 'status': 'DEPLOYED', 'desc': 'Quantum-Safe Evidence Storage'},
    ];

    return Column(
      children: ops.map((op) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.eliteGold.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.eliteGold.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.layers_rounded, color: AppColors.eliteGold, size: 16),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(op['name']!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                  Text(op['desc']!, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(op['status']!, style: const TextStyle(color: AppColors.success, fontSize: 7, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildSocialArsenal(Color primary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _socialBtn(FontAwesomeIcons.github, "GITHUB", Colors.white),
        _socialBtn(FontAwesomeIcons.linkedin, "LINKEDIN", const Color(0xFF0077B5)),
        _socialBtn(Icons.alternate_email_rounded, "CONTACT", AppColors.eliteGold),
      ],
    );
  }

  Widget _socialBtn(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.08),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, spreadRadius: 2)],
          ),
          child: Icon(icon, color: color, size: 24),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 3.seconds).scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1)),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildFooterSignature() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.eliteGold.withOpacity(0.1))),
          child: const Icon(Icons.fingerprint_rounded, color: AppColors.eliteGold, size: 45),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 4.seconds),
        const SizedBox(height: 20),
        Text(
          "SECURING THE DIGITAL FRONTIER",
          style: TextStyle(color: AppColors.eliteGold.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 5),
        ),
        const SizedBox(height: 8),
        const Text(
          "© 2024 ELITE FORENSIC UNIT | DESIGNED FOR INTELLIGENCE",
          style: TextStyle(color: Colors.white10, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ],
    );
  }
}
