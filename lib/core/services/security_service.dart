import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class SecurityService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) return true; // Fallback if no biometrics available

      return await _auth.authenticate(
        localizedReason: 'AUTHENTICATION REQUIRED TO ACCESS SECURE VAULT',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      print("Auth error: $e");
      return false;
    }
  }
}
