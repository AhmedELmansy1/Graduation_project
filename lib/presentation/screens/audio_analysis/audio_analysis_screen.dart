import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_card.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/translations.dart';
import '../../../data/datasources/ai_service.dart';
import '../../../data/repositories/log_repository_impl.dart';
import '../../providers/settings_provider.dart';
import '../results/forensic_result_screen.dart';
import '../../widgets/scanning_overlay.dart';
import '../../widgets/forensic_backgrounds.dart';

class AudioAnalysisScreen extends ConsumerStatefulWidget {
  const AudioAnalysisScreen({super.key});

  @override
  ConsumerState<AudioAnalysisScreen> createState() => _AudioAnalysisScreenState();
}

class _AudioAnalysisScreenState extends ConsumerState<AudioAnalysisScreen> {
  File? _selectedAudio;
  bool _isAnalyzing = false;
  late PlayerController _playerController;
  final LogRepository _logRepository = LogRepository();

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _selectedAudio = File(result.files.single.path!);
      });
      await _playerController.preparePlayer(path: _selectedAudio!.path);
      setState(() {});
    }
  }

  Future<void> _analyze() async {
    if (_selectedAudio == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await AIService.analyzeAudio(_selectedAudio!);
      await _logRepository.saveResult(result);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForensicResultScreen(result: result),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lang = settings.locale.languageCode;
    final primaryColor = Theme.of(context).primaryColor;

    String t(String key) => Translations.translate(key, lang);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t('audio_analysis')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ForensicBackground(
            type: BackgroundType.waves, // Unique animation for audio page
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: _selectedAudio == null
                            ? _buildAudioPlaceholder(primaryColor, t)
                            : _buildAudioWaveform(primaryColor),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_selectedAudio != null) ...[
                      _buildAnalyzeButton(primaryColor, t).animate().fadeIn().slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 16),
                    ],
                    _buildPickButton(primaryColor, t),
                  ],
                ),
              ),
            ),
          ),
          if (_isAnalyzing) ScanningOverlay(message: t('analyzing')),
        ],
      ),
    );
  }

  Widget _buildAudioPlaceholder(Color primary, String Function(String) t) {
    return GlassCard(
      height: 350,
      width: double.infinity,
      blur: 20,
      opacity: 0.05,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: primary.withOpacity(0.3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.audiotrack_rounded, size: 80, color: primary.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text(t('select_source'), style: const TextStyle(color: Colors.white54, letterSpacing: 1, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildAudioWaveform(Color primary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: 'forensic_media',
          child: GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            borderRadius: BorderRadius.circular(32),
            opacity: 0.05,
            child: AudioFileWaveforms(
              size: Size(MediaQuery.of(context).size.width - 80, 150),
              playerController: _playerController,
              enableSeekGesture: true,
              waveformType: WaveformType.long,
              playerWaveStyle: PlayerWaveStyle(
                fixedWaveColor: Colors.white12,
                liveWaveColor: primary,
                spacing: 6,
                waveThickness: 3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: primary.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)
            ],
          ),
          child: IconButton(
            onPressed: () async {
              if (_playerController.playerState.isPlaying) {
                await _playerController.pausePlayer();
              } else {
                await _playerController.startPlayer();
              }
              setState(() {});
            },
            icon: Icon(
              _playerController.playerState.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildPickButton(Color primary, String Function(String) t) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isAnalyzing ? null : _pickAudio,
        icon: const Icon(Icons.upload_file_rounded),
        label: Text(t('select_source')),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton(Color primary, String Function(String) t) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: primary.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: ElevatedButton(
        onPressed: _isAnalyzing ? null : _analyze,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          t('audio_analysis').toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.black),
        ),
      ),
    );
  }
}
