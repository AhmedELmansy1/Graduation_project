import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/forensic_backgrounds.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('SYSTEM SPECIFICATIONS', style: TextStyle(letterSpacing: 2, fontSize: 14, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
      ),
      body: ForensicBackground(
        type: BackgroundType.cosmos,
        child: Stack(
          children: [
            // Background Tech Elements
            Positioned(
              bottom: -100,
              right: -100,
              child: Icon(Icons.settings_input_component_rounded, size: 400, color: primaryColor.withOpacity(0.02)),
            ),
            
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(primaryColor),
                  const SizedBox(height: 40),
                  
                  _buildSection(
                    title: 'محرك التحليل الجنائي',
                    enTitle: 'FORENSIC ENGINE',
                    icon: Icons.memory_rounded,
                    content: 'يعتمد النظام على محرك هجين يجمع بين خوارزميات معالجة الإشارات الرقمية (DSP) ونماذج التعلم العميق المتطورة للكشف عن التلاعب في بكسلات الصور والترددات الصوتية بدقة متناهية.',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildTechGrid(primaryColor),
                  
                  const SizedBox(height: 32),
                  
                  _buildSection(
                    title: 'معايير النزاهة الرقمية',
                    enTitle: 'INTEGRITY STANDARDS',
                    icon: Icons.gpp_maybe_rounded,
                    content: 'يلتزم النظام بمعايير سلسلة الحيازة (Chain of Custody) عبر تشفير كل فحص ببصمة SHA-256 فريدة، مما يضمن عدم التلاعب بالنتائج بعد استخراجها ويوفر موثوقية عالية للجهات القانونية.',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSpecificationsTable(),
                  
                  const SizedBox(height: 60),
                  Center(
                    child: Opacity(
                      opacity: 0.3,
                      child: Column(
                        children: [
                          Text('CORE VERSION 1.5.0 STABLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor)),
                          const SizedBox(height: 4),
                          const Text('© 2024 FORENSIC INTELLIGENCE UNIT', style: TextStyle(fontSize: 8, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.biotech_rounded, color: primary, size: 40),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Forensic Media System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                Text('نظام الأدلة الجنائية المتطور', style: TextStyle(fontSize: 12, color: primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildSection({required String title, required String enTitle, required IconData icon, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const Spacer(),
            Text(enTitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
          child: Text(content, style: const TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 13)),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildTechGrid(Color primary) {
    final techs = [
      {'name': 'Deep Learning', 'desc': 'CNN/RNN Architecture'},
      {'name': 'Error Level', 'desc': 'ELA Pixel Analysis'},
      {'name': 'Spectral Scan', 'desc': 'FFT Frequency Mapping'},
      {'name': 'Metadata Raw', 'desc': 'EXIF Data Extraction'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.2),
      itemCount: techs.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(techs[index]['name']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: primary)),
              Text(techs[index]['desc']!, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecificationsTable() {
    final specs = {
      'Hash Standard': 'SHA-256 (Military Grade)',
      'Image Support': 'JPG, PNG, TIFF, BMP',
      'Audio Support': 'WAV, MP3, FLAC',
      'AI Accuracy': 'Up to 99.8% on validation',
      'Privacy': '100% Local Processing',
    };

    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
      child: Column(
        children: specs.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              Text(e.value, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
      ),
    );
  }
}
