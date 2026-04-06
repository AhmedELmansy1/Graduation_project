import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:forensic_system/core/utils/forensic_utils.dart';
import 'package:crypto/crypto.dart';

void main() {
  group('ForensicUtils Tests', () {
    late File testFile;
    
    setUp(() async {
      testFile = File('test_file.txt');
      await testFile.writeAsString('Hello Forensic World');
    });

    tearDown(() async {
      if (await testFile.exists()) {
        await testFile.delete();
      }
    });

    test('getFileHash returns correct SHA-256 hash', () async {
      final hash = await ForensicUtils.getFileHash(testFile);
      final expectedHash = sha256.convert(await testFile.readAsBytes()).toString();
      expect(hash, expectedHash);
    });

    test('getForensicData returns basic file info', () async {
      final data = await ForensicUtils.getForensicData(testFile);
      expect(data['file_size'], await testFile.length());
      expect(data['ai_marker_found'], false);
      expect(data['hasGps'], false);
    });

    test('Entropy calculation for simple text', () async {
      final data = await ForensicUtils.getForensicData(testFile);
      final entropy = data['raw_entropy'] as double;
      // Entropy of "Hello Forensic World" should be relatively low compared to 8.0
      expect(entropy, lessThan(8.0));
      expect(data['is_stego_likely'], false);
    });
  });
}
