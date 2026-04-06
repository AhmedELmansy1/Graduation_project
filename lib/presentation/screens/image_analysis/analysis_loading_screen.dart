import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/ai_service.dart';
import '../../../data/repositories/log_repository_impl.dart';
import '../results/forensic_result_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnalysisLoadingScreen extends StatefulWidget {
  final File file;
  const AnalysisLoadingScreen({super.key, required this.file});

  @override
  State<AnalysisLoadingScreen> createState() => _AnalysisLoadingScreenState();
}

class _AnalysisLoadingScreenState extends State<AnalysisLoadingScreen> {
  final List<String> _terminalLogs = [];
  int _logIndex = 0;
  Timer? _timer;

  final List<String> _dsSteps = [
    "> INITIALIZING DEEPSECURE-AI KERNEL...",
    "> MOUNTING NEURAL ACCELERATOR [GPU/NNAPI]...",
    "> DECODING IMAGE DATA STREAM...",
    "> EXTRACTING SPATIAL FEATURES...",
    "> RUNNING EFFICIENTNET-B7 BACKBONE...",
    "> ANALYZING NOISE ENTROPY...",
    "> CALCULATING TENSOR PROBABILITIES...",
    "> SCANNING FOR AI-SYNTHESIS MARKERS...",
    "> FINALIZING FORENSIC SIGNATURE...",
    "> GENERATING CRYPTOGRAPHIC REPORT..."
  ];

  @override
  void initState() {
    super.initState();
    _startLogStream();
    _performAnalysis();
  }

  void _startLogStream() {
    _timer = Timer.periodic(const Duration(milliseconds: 400), (t) {
      if (_logIndex < _dsSteps.length) {
        setState(() {
          _terminalLogs.add(_dsSteps[_logIndex]);
          _logIndex++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _performAnalysis() async {
    try {
      // التحليل الحقيقي باستخدام الموديل اللي حملناه
      final result = await AIService.analyzeImage(widget.file);
      await LogRepository().saveResult(result);

      if (mounted) {
        // ننتظر ثانية إضافية عشان المستخدم يلحق يشوف الـ Logs
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ForensicResultScreen(result: result)),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dsBackground,
      body: Stack(
        children: [
          // Background Glow
          Center(
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.dsPrimary.withOpacity(0.05),
              ),
            ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 2.seconds),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Scanning Icon
                  const Icon(Icons.qr_code_scanner_rounded, color: AppColors.dsPrimary, size: 80)
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 2.seconds)
                      .scale(duration: 1.seconds),
                  
                  const SizedBox(height: 40),
                  
                  Text("ANALYZING ARTIFACTS", style: TextStyle(color: AppColors.dsPrimary, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 4)),
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation(AppColors.dsPrimary),
                  ).animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: 40),

                  // TERMINAL BOX
                  Container(
                    width: double.infinity,
                    height: 250,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.dsPrimary.withOpacity(0.2)),
                    ),
                    child: ListView.builder(
                      itemCount: _terminalLogs.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          _terminalLogs[index],
                          style: const TextStyle(color: AppColors.dsPrimary, fontFamily: 'monospace', fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ).animate().slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
