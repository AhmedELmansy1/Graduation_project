import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/translations.dart';
import '../../../domain/entities/analysis_result.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../../core/utils/forensic_filters.dart';
import '../../widgets/result_indicator.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/forensic_backgrounds.dart';
import '../../providers/settings_provider.dart';

class ForensicResultScreen extends ConsumerStatefulWidget {
  final AnalysisResult result;

  const ForensicResultScreen({super.key, required this.result});

  @override
  ConsumerState<ForensicResultScreen> createState() => _ForensicResultScreenState();
}

class _ForensicResultScreenState extends ConsumerState<ForensicResultScreen> {
  Uint8List? _elaImage;
  Uint8List? _enhancedImage;
  bool _showEla = false;
  bool _showEnhanced = false;
  bool _showHeatmap = true; // New Heatmap toggle
  bool _isGeneratingPdf = false;
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];

  @override
  void initState() {
    super.initState();
    _loadForensicData();
    _addAiMessage("تحليل البيانات اكتمل. أنا الخبير الجنائي الرقمي، كيف أساعدك؟");
  }

  void _addAiMessage(String msg) {
    setState(() {
      _chatMessages.add({"role": "ai", "text": msg});
    });
  }

  void _handleSendMessage() {
    if (_chatController.text.isEmpty) return;
    final userMsg = _chatController.text;
    final settings = ref.read(settingsProvider);
    final isAr = settings.locale.languageCode == 'ar';

    setState(() {
      _chatMessages.add({"role": "user", "text": userMsg});
      _chatController.clear();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      String response = "";
      final msg = userMsg.toLowerCase();
      final res = widget.result;

      if (isAr) {
        if (msg.contains("نتيجة") || msg.contains("تقرير")) {
          response = "بناءً على التحليل الرقمي، النتيجة هي ${res.manipulationType}. نسبة اليقين ${(res.manipulationScore * 100).toStringAsFixed(1)}%.";
        } else if (msg.contains("gps") || msg.contains("موقع")) {
          response = res.metadata['hasGps'] == true 
            ? "نعم، تم العثور على إحداثيات GPS في الملف: ${res.metadata['lat']}, ${res.metadata['lng']}." 
            : "لم يتم العثور على أي بيانات جغرافية (GPS) مخفية في هذا الملف.";
        } else if (msg.contains("تعديل") || msg.contains("فوتوشوب")) {
          response = res.manipulationScore > 0.5 
            ? "نعم، هناك علامات قوية على التلاعب الرقمي كما هو موضح في تقرير ELA."
            : "لا توجد أدلة واضحة على استخدام برامج تعديل الصور المشهورة.";
        } else {
          response = "أنا هنا للمساعدة في فهم التقرير الجنائي. هل تريد الاستفسار عن البيانات الوصفية أو مستوى التلاعب؟";
        }
      } else {
        if (msg.contains("result") || msg.contains("report")) {
          response = "Based on digital analysis, the result is ${res.manipulationType}. Confidence level is ${(res.manipulationScore * 100).toStringAsFixed(1)}%.";
        } else if (msg.contains("gps") || msg.contains("location")) {
          response = res.metadata['hasGps'] == true 
            ? "Yes, GPS coordinates were found: ${res.metadata['lat']}, ${res.metadata['lng']}." 
            : "No hidden geolocation (GPS) data was found in this file.";
        } else if (msg.contains("edit") || msg.contains("photoshop")) {
          response = res.manipulationScore > 0.5 
            ? "Yes, there are strong signs of digital manipulation as shown in the ELA report."
            : "No clear evidence of popular image editing software was detected.";
        } else {
          response = "I am here to help you understand the forensic report. Do you want to ask about metadata or manipulation levels?";
        }
      }
      _addAiMessage(response);
    });
  }

  Future<void> _loadForensicData() async {
    try {
      if (widget.result.file.path.toLowerCase().contains(RegExp(r'jpg|jpeg|png'))) {
        final ela = await ForensicFilters.generateELA(widget.result.file);
        final enhanced = await ForensicFilters.enhanceImage(widget.result.file);
        if (mounted) {
          setState(() {
            _elaImage = ela;
            _enhancedImage = enhanced;
          });
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lang = settings.locale.languageCode;
    final primaryColor = Theme.of(context).primaryColor;
    String t(String key) => Translations.translate(key, lang);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t('report').toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white54)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isGeneratingPdf 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.eliteGold))
              : const Icon(Icons.picture_as_pdf_outlined, color: AppColors.eliteGold),
            onPressed: () async {
              setState(() => _isGeneratingPdf = true);
              await PdfGenerator.generateReport(widget.result);
              setState(() => _isGeneratingPdf = false);
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ForensicBackground(
        type: BackgroundType.grid,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                _buildElitePreview(primaryColor, t),
                const SizedBox(height: 30),
                _buildActionPulseRow(primaryColor, t),
                const SizedBox(height: 30),
                _buildDiagnosticOverview(primaryColor, t),
                const SizedBox(height: 30),
                _buildEvidenceNeuralLink(primaryColor, t),
                const SizedBox(height: 30),
                _buildAiExpertChat(primaryColor, t),
                const SizedBox(height: 30),
                _buildTechnicalMetadata(primaryColor, t),
                const SizedBox(height: 40),
                _buildVerificationFooter(primaryColor, t),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElitePreview(Color primary, String Function(String) t) {
    ImageProvider? imageProvider;
    try {
      if (_showEla && _elaImage != null) imageProvider = MemoryImage(_elaImage!);
      else if (_showEnhanced && _enhancedImage != null) imageProvider = MemoryImage(_enhancedImage!);
      else if (widget.result.file.existsSync()) imageProvider = FileImage(widget.result.file);
    } catch (e) {
      debugPrint("IMAGE PROVIDER ERROR: $e");
    }

    return Stack(
      children: [
        Container(
          height: 350, width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: primary.withOpacity(0.3), width: 1.5),
            boxShadow: [BoxShadow(color: primary.withOpacity(0.15), blurRadius: 30, spreadRadius: -5)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: imageProvider != null 
                ? Stack(
                    children: [
                      Image(
                        image: imageProvider, 
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.broken_image_rounded, color: AppColors.danger, size: 40),
                              const SizedBox(height: 10),
                              Text(t('error_loading_image'), style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      if (_showHeatmap && widget.result.isSuspicious && !_showEla)
                        _buildHeatmap(primary),
                      _buildScannerBeam(primary),
                    ],
                  )
                : Center(child: Icon(Icons.broken_image_rounded, color: Colors.white10, size: 50)),
          ),
        ),
        // Overlay Controls
        Positioned(
          top: 15, right: 15,
          child: _buildGlassToggle(
            icon: _showHeatmap ? Icons.radar_rounded : Icons.radar_outlined,
            isActive: _showHeatmap,
            onTap: () => setState(() => _showHeatmap = !_showHeatmap),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassToggle({required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isActive ? AppColors.danger : Colors.white24),
        ),
        child: Icon(icon, color: isActive ? AppColors.danger : Colors.white, size: 18),
      ),
    );
  }

  Widget _buildActionPulseRow(Color primary, String Function(String) t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPulseBtn(
          label: "ELA SCAN", 
          icon: Icons.layers_rounded, 
          isActive: _showEla,
          color: Colors.orange,
          onTap: () => setState(() { _showEla = !_showEla; _showEnhanced = false; }),
        ),
        const SizedBox(width: 15),
        _buildPulseBtn(
          label: "CSI ENHANCE", 
          icon: Icons.auto_fix_high_rounded, 
          isActive: _showEnhanced,
          color: primary,
          onTap: () => setState(() { _showEnhanced = !_showEnhanced; _showEla = false; }),
        ),
      ],
    );
  }

  Widget _buildPulseBtn({required String label, required IconData icon, required bool isActive, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? color : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? color : Colors.white54, size: 16),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosticOverview(Color primary, String Function(String) t) {
    final color = widget.result.isSuspicious ? AppColors.danger : AppColors.success;
    return GlassCard(
      padding: const EdgeInsets.all(25),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: color.withOpacity(0.2)),
      child: Row(
        children: [
          ResultIndicator(score: widget.result.manipulationScore, color: color),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.result.manipulationType.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    widget.result.isSuspicious ? 'COMPROMISED EVIDENCE' : 'INTEGRITY VERIFIED',
                    style: TextStyle(color: color.withOpacity(0.8), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceNeuralLink(Color primary, String Function(String) t) {
    return _buildDnaVisualizer(primary, t);
  }

  Widget _buildAiExpertChat(Color primary, String Function(String) t) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppColors.eliteGold, size: 20),
              const SizedBox(width: 12),
              Text("FORENSIC AI EXPERT", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 180,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final isAi = _chatMessages[index]['role'] == 'ai';
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isAi ? primary.withOpacity(0.08) : Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isAi ? primary.withOpacity(0.2) : Colors.white10),
                    ),
                    child: Text(
                      _chatMessages[index]['text']!, 
                      style: TextStyle(color: isAi ? Colors.white : Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _chatController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: t('ask_ai'),
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 11),
              filled: true,
              fillColor: Colors.black26,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              suffixIcon: IconButton(icon: Icon(Icons.send_rounded, color: primary, size: 20), onPressed: _handleSendMessage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalMetadata(Color primary, String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 15),
          child: Text("TECHNICAL SPECIFICATIONS", style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ),
        GlassCard(
          borderRadius: BorderRadius.circular(25),
          child: Column(
            children: widget.result.metadata.entries.where((e) => e.value is String).map((e) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.white38, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 20),
                  Expanded(child: Text(e.value.toString(), textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70))),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationFooter(Color primary, String Function(String) t) {
    return Column(
      children: [
        Text(t('hash').toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.white24, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(15), border: Border.all(color: primary.withOpacity(0.1))),
          child: SelectableText(
            widget.result.fileHash, 
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: primary.withOpacity(0.7), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildScannerBeam(Color primary) {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: primary.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)],
          gradient: LinearGradient(colors: [Colors.transparent, primary, Colors.transparent]),
        ),
      ).animate(onPlay: (c) => c.repeat()).move(begin: const Offset(0, 0), end: const Offset(0, 300), duration: 2.seconds),
    );
  }

  Widget _buildHeatmap(Color primary) {
    return RepaintBoundary(
      child: Stack(
        children: List.generate(5, (i) {
          final r = math.Random(i + widget.result.id.hashCode);
          return Positioned(
            top: r.nextDouble() * 200 + 20,
            left: r.nextDouble() * 300 + 20,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.red.withOpacity(0.4), Colors.transparent],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.5, 1.5), duration: 2.seconds),
          );
        }),
      ),
    );
  }

  Widget _buildDnaVisualizer(Color primary, String Function(String) t) {
    final hash = widget.result.fileHash;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("EVIDENCE DNA PATTERN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primary, letterSpacing: 2)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(20, (index) {
              int val = hash.codeUnitAt(index % hash.length);
              return Container(
                width: 4,
                height: (val % 40 + 10).toDouble(),
                decoration: BoxDecoration(
                  color: index % 3 == 0 ? primary : (index % 2 == 0 ? AppColors.eliteGold : Colors.white24),
                  borderRadius: BorderRadius.circular(2),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(delay: (index * 50).ms);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhanceControls(Color primary, String Function(String) t) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => setState(() { _showEla = !_showEla; _showEnhanced = false; }),
          icon: const Icon(Icons.layers),
          label: const Text("ELA"),
          style: ElevatedButton.styleFrom(backgroundColor: _showEla ? Colors.orange : Colors.white10),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => setState(() { _showEnhanced = !_showEnhanced; _showEla = false; }),
          icon: const Icon(Icons.auto_fix_high),
          label: Text(t('enhance')),
          style: ElevatedButton.styleFrom(backgroundColor: _showEnhanced ? primary : Colors.white10),
        ),
      ],
    );
  }

  Widget _buildStatusSection(Color primary, String Function(String) t) {
    final color = widget.result.isSuspicious ? Colors.redAccent : Colors.greenAccent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(
        children: [
          ResultIndicator(score: widget.result.manipulationScore, color: color),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.result.manipulationType.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text("INTEGRITY STATUS: ${widget.result.isSuspicious ? 'COMPROMISED' : 'SECURE'}", style: const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAssistantSection(Color primary, String Function(String) t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            height: 120,
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final isAi = _chatMessages[index]['role'] == 'ai';
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: isAi ? primary.withOpacity(0.1) : Colors.white10, borderRadius: BorderRadius.circular(10)),
                    child: Text(_chatMessages[index]['text']!, style: const TextStyle(fontSize: 12)),
                  ),
                );
              },
            ),
          ),
          TextField(
            controller: _chatController,
            decoration: InputDecoration(hintText: t('ask_ai'), suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: _handleSendMessage)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataTable(Color primary, String Function(String) t) {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: widget.result.metadata.entries.where((e) => e.value is String).map((e) => ListTile(
          dense: true,
          title: Text(e.key, style: const TextStyle(fontSize: 11, color: Colors.white54)),
          trailing: Text(e.value.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        )).toList(),
      ),
    );
  }

  Widget _buildIntegrityCard(Color primary, String Function(String) t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t('hash'), style: const TextStyle(fontSize: 10, color: Colors.white38)),
          const SizedBox(height: 5),
          SelectableText(widget.result.fileHash, style: TextStyle(fontFamily: 'monospace', fontSize: 9, color: primary)),
        ],
      ),
    );
  }
}
