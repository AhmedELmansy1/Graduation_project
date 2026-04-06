import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ForensicFilters {
  /// Simple Error Level Analysis (ELA) simulation
  static Future<Uint8List?> generateELA(File file) async {
    final bytes = await file.readAsBytes();
    return compute(_processELA, bytes);
  }

  static Uint8List? _processELA(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    final lowQualityBytes = img.encodeJpg(image, quality: 90);
    final lowQualityImage = img.decodeImage(Uint8List.fromList(lowQualityBytes));
    if (lowQualityImage == null) return null;

    final resultImage = img.Image(width: image.width, height: image.height);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final p1 = image.getPixel(x, y);
        final p2 = lowQualityImage.getPixel(x, y);
        final r = (p1.r - p2.r).abs() * 20;
        final g = (p1.g - p2.g).abs() * 20;
        final b = (p1.b - p2.b).abs() * 20;
        resultImage.setPixel(x, y, img.ColorRgb8(r.clamp(0, 255).toInt(), g.clamp(0, 255).toInt(), b.clamp(0, 255).toInt()));
      }
    }
    return Uint8List.fromList(img.encodePng(resultImage));
  }

  /// CSI Enhancement simulation (Sharpen & Contrast boost)
  static Future<Uint8List?> enhanceImage(File file) async {
    final bytes = await file.readAsBytes();
    return compute(_processEnhance, bytes);
  }

  static Uint8List? _processEnhance(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    // Apply sharpening filter
    final sharpened = img.contrast(image, contrast: 120);
    final finalImage = img.convolution(sharpened, filter: [
      0, -1, 0,
      -1, 5, -1,
      0, -1, 0,
    ]);

    return Uint8List.fromList(img.encodePng(finalImage));
  }
}
