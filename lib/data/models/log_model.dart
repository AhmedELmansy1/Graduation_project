// تم تحويل الكلاس إلى كلاس عادي لأننا نستخدم نظام الـ Maps في التخزين حالياً لتجنب مشاكل التوليد التلقائي
class LogModel {
  final String id;
  final String fileName;
  final String filePath;
  final String fileHash;
  final double manipulationScore;
  final String manipulationType;
  final DateTime timestamp;

  LogModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileHash,
    required this.manipulationScore,
    required this.manipulationType,
    required this.timestamp,
  });

  // محول لتحويل البيانات من Map (القادمة من Hive) إلى كائن LogModel
  factory LogModel.fromMap(Map<dynamic, dynamic> map) {
    return LogModel(
      id: map['id'] ?? '',
      fileName: map['fileName'] ?? '',
      filePath: map['filePath'] ?? '',
      fileHash: map['fileHash'] ?? '',
      manipulationScore: (map['score'] as num?)?.toDouble() ?? 0.0,
      manipulationType: map['type'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
