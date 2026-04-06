import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/translations.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/forensic_backgrounds.dart';
import '../image_analysis/analysis_loading_screen.dart';

class VideoAnalysisScreen extends ConsumerStatefulWidget {
  const VideoAnalysisScreen({super.key});

  @override
  ConsumerState<VideoAnalysisScreen> createState() => _VideoAnalysisScreenState();
}

class _VideoAnalysisScreenState extends ConsumerState<VideoAnalysisScreen> {
  File? _selectedVideo;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
      });
    }
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      setState(() {
        _selectedVideo = File(video.path);
      });
    }
  }

  void _startAnalysis() {
    if (_selectedVideo == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisLoadingScreen(file: _selectedVideo!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lang = settings.locale.languageCode;
    final primaryColor = AppColors.secondary; // Using Cyan for Video
    String t(String key) => Translations.translate(key, lang);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("VIDEO FORENSICS", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ForensicBackground(
        type: BackgroundType.matrix,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  child: _selectedVideo == null
                      ? Center(child: _buildVideoPlaceholder(primaryColor, t))
                      : _buildVideoPreview(primaryColor),
                ),
                const SizedBox(height: 30),
                if (_selectedVideo != null) ...[
                  _buildAnalyzeButton(primaryColor, t),
                  const SizedBox(height: 20),
                ],
                
                Row(
                  children: [
                    Expanded(child: _buildActionButton(
                      icon: Icons.video_library_rounded, 
                      label: "GALLERY", 
                      color: primaryColor, 
                      onTap: _pickVideo
                    )),
                    const SizedBox(width: 15),
                    Expanded(child: _buildActionButton(
                      icon: Icons.videocam_rounded, 
                      label: "RECORD", 
                      color: primaryColor, 
                      onTap: _recordVideo
                    )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder(Color primary, String Function(String) t) {
    return GlassCard(
      height: 350, width: double.infinity,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: primary.withOpacity(0.3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_file_outlined, size: 100, color: primary.withOpacity(0.5))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 3.seconds),
          const SizedBox(height: 25),
          const Text("SELECT VIDEO FOR SCANNING", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          const Text("MP4 / MOV / AVI SUPPORTED", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildVideoPreview(Color primary) {
    return GlassCard(
      height: 350, width: double.infinity,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: primary.withOpacity(0.5)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.play_circle_fill_rounded, size: 80, color: Colors.white24),
          Positioned(
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: Text(
                _selectedVideo!.path.split('/').last,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            top: 15, right: 15,
            child: IconButton(
              icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent),
              onPressed: () => setState(() => _selectedVideo = null),
            ),
          )
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(Color primary, String Function(String) t) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 15)],
      ),
      child: ElevatedButton.icon(
        onPressed: _startAnalysis,
        icon: const Icon(Icons.radar_rounded, color: Colors.black),
        label: const Text("START DEEP SCAN", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 2)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, 
          shadowColor: Colors.transparent, 
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    ).animate().fadeIn().shimmer(duration: 2.seconds);
  }
}
