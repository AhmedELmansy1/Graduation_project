import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/theme/app_colors.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;
  final AppThemeMode appTheme;
  final bool isLuxury;
  final bool useBiometrics;

  SettingsState({
    required this.themeMode,
    required this.locale,
    this.appTheme = AppThemeMode.emerald,
    this.isLuxury = true,
    this.useBiometrics = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    AppThemeMode? appTheme,
    bool? isLuxury,
    bool? useBiometrics,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      appTheme: appTheme ?? this.appTheme,
      isLuxury: isLuxury ?? this.isLuxury,
      useBiometrics: useBiometrics ?? this.useBiometrics,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final LocalAuthentication auth = LocalAuthentication();

  SettingsNotifier() : super(SettingsState(themeMode: ThemeMode.dark, locale: const Locale('ar'))) {
    _loadSettings();
  }

  static const String _themeKey = 'theme_mode_is_dark';
  static const String _langKey = 'language_code';
  static const String _appThemeIndexKey = 'app_theme_index';
  static const String _luxuryKey = 'is_luxury_mode';
  static const String _biometricKey = 'use_biometric_lock';

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? true;
    final lang = prefs.getString(_langKey) ?? 'ar';
    final themeIndex = prefs.getInt(_appThemeIndexKey) ?? 2;
    final isLuxury = prefs.getBool(_luxuryKey) ?? true;
    final useBio = prefs.getBool(_biometricKey) ?? false;

    state = SettingsState(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(lang),
      appTheme: AppThemeMode.values[themeIndex],
      isLuxury: isLuxury,
      useBiometrics: useBio,
    );
  }

  Future<bool> authenticate() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      
      if (!canAuthenticate) return true;

      return await auth.authenticate(
        localizedReason: 'Please authenticate to access forensic data',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
    } catch (e) {
      return false;
    }
  }

  void toggleBiometrics(bool val) async {
    if (val) {
      final success = await authenticate();
      if (!success) return;
    }
    state = state.copyWith(useBiometrics: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, val);
  }

  void toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = state.copyWith(themeMode: newMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newMode == ThemeMode.dark);
  }

  void toggleLuxury(bool val) async {
    state = state.copyWith(isLuxury: val);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_luxuryKey, val);
  }

  void setLanguage(String langCode) async {
    state = state.copyWith(locale: Locale(langCode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, langCode);
  }

  void setAppTheme(AppThemeMode mode) async {
    state = state.copyWith(appTheme: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_appThemeIndexKey, mode.index);
  }
}
