import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/analysis_result.dart';
import '../models/log_model.dart';

class LogRepository {
  static const String boxName = 'forensic_logs';

  Future<void> saveResult(AnalysisResult result) async {
    final box = Hive.box(boxName);
    final log = {
      'id': result.id,
      'fileHash': result.fileHash,
      'filePath': result.file.path,
      'score': result.manipulationScore,
      'type': result.manipulationType,
      'timestamp': result.timestamp.toIso8601String(),
      'metadata': result.metadata,
    };
    await box.add(log);
  }

  List<dynamic> getAllLogs() {
    final box = Hive.box(boxName);
    return box.values.toList().reversed.toList();
  }

  Future<void> clearLogs() async {
    final box = Hive.box(boxName);
    await box.clear();
  }
}
