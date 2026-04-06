import 'dart:io';

class AnalysisResult {
  final String id;
  final File file;
  final String fileHash;
  final double manipulationScore;
  final String manipulationType;
  final DateTime timestamp;
  final String? heatmapPath;
  final Map<String, dynamic> metadata;

  AnalysisResult({
    required this.id,
    required this.file,
    required this.fileHash,
    required this.manipulationScore,
    required this.manipulationType,
    required this.timestamp,
    this.heatmapPath,
    required this.metadata,
  });

  factory AnalysisResult.fromMap(Map<dynamic, dynamic> map) {
    return AnalysisResult(
      id: map['id'] as String,
      file: File(map['filePath'] as String),
      fileHash: map['fileHash'] as String,
      manipulationScore: (map['score'] as num).toDouble(),
      manipulationType: map['type'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      metadata: Map<String, dynamic>.from(map['metadata'] as Map),
    );
  }

  bool get isSuspicious => manipulationScore > 0.5;
}
