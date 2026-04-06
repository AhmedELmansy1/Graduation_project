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
import 'analysis_loading_screen.dart';

class ImageAnalysisScreen extends ConsumerStatefulWidget {
  const ImageAnalysisScreen({super.key});

  @override
  ConsumerState<ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends ConsumerState<ImageAnalysisScreen> {
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 3) return;
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        for (var image in images) {
          if (_selectedImages.length < 3) _selectedImages.add(File(image.path));
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    if (_selectedImages.length >= 3) return;
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImages.add(File(photo.path));
      });
    }
  }

  void _startAnalysis() {
    if (_selectedImages.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisLoadingScreen(file: _selectedImages.first),
      ),
    );
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
        title: Text(t('image_scan')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_selectedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent),
              onPressed: () => setState(() => _selectedImages.clear()),
            )
        ],
      ),
      body: ForensicBackground(
        type: BackgroundType.scanner,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  child: _selectedImages.isEmpty
                      ? Center(child: _buildImagePlaceholder(primaryColor, t))
                      : _buildImageGrid(primaryColor),
                ),
                const SizedBox(height: 24),
                if (_selectedImages.isNotEmpty) ...[
                  Text("${t('batch_limit')}: ${_selectedImages.length}/3",
                    style: TextStyle(color: primaryColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildAnalyzeButton(primaryColor, t),
                  const SizedBox(height: 16),
                ],
                
                // ACTION BUTTONS
                Row(
                  children: [
                    Expanded(child: _buildPickButton(primaryColor, t)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCameraButton(primaryColor, t)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(Color primary, String Function(String) t) {
    return GlassCard(
      height: 350, width: double.infinity,
      opacity: 0.05,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: primary.withOpacity(0.3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_enhance_outlined, size: 80, color: primary.withOpacity(0.5)),
          const SizedBox(height: 20),
          Text(t('select_images'), style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildImageGrid(Color primary) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primary.withOpacity(0.3)),
              image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImages.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPickButton(Color primary, String Function(String) t) {
    bool isFull = _selectedImages.length >= 3;
    return OutlinedButton.icon(
      onPressed: isFull ? null : _pickImages,
      icon: const Icon(Icons.photo_library),
      label: Text(t('select_source'), style: const TextStyle(fontSize: 11)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isFull ? Colors.white.withOpacity(0.1) : primary, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildCameraButton(Color primary, String Function(String) t) {
    bool isFull = _selectedImages.length >= 3;
    return OutlinedButton.icon(
      onPressed: isFull ? null : _takePhoto,
      icon: const Icon(Icons.camera_alt_rounded),
      label: Text(t('camera_capture'), style: const TextStyle(fontSize: 11)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isFull ? Colors.white.withOpacity(0.1) : primary, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildAnalyzeButton(Color primary, String Function(String) t) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, primary.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 15)],
      ),
      child: ElevatedButton(
        onPressed: _startAnalysis,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, 
          shadowColor: Colors.transparent, 
          padding: const EdgeInsets.symmetric(vertical: 18),
        ),
        child: Text(t('scan_image'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    ).animate().fadeIn();
  }
}
