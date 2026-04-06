import 'dart:io';
import 'package:exif/exif.dart';

class MetadataService {
  static Future<Map<String, String>> extractExif(File file) async {
    final bytes = await file.readAsBytes();
    final data = await readExifFromBytes(bytes);

    if (data.isEmpty) {
      return {'Status': 'No EXIF metadata found'};
    }

    Map<String, String> metadata = {};
    
    // Extracting common useful tags
    final tags = {
      'Image Make': 'Manufacturer',
      'Image Model': 'Device Model',
      'Image DateTime': 'Capture Date',
      'Image Software': 'Software Used',
      'EXIF ExifImageWidth': 'Width (px)',
      'EXIF ExifImageLength': 'Height (px)',
      'EXIF ISOSpeedRatings': 'ISO Speed',
      'EXIF ExposureTime': 'Exposure Time',
      'EXIF FNumber': 'Aperture',
    };

    tags.forEach((key, label) {
      if (data.containsKey(key)) {
        metadata[label] = data[key].toString();
      }
    });

    // Check for GPS data (Crucial for forensics)
    if (data.containsKey('GPS GPSLatitude')) {
      metadata['GPS Data'] = 'Location coordinates detected';
    }

    return metadata;
  }
}
