import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class HashUtil {
  static Future<String> calculateSHA256(File file) async {
    final bytes = await file.readAsBytes();
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
