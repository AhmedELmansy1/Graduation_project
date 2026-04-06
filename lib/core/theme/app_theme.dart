import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData getTheme(AppThemeMode mode, bool isDark) {
    Color primary;
    Color background;
    Color surface;
    Color secondary = const Color(0xFF7000FF);
    double borderRadius = 28.0;

    switch (mode) {
      case AppThemeMode.oled:
        primary = AppColors.accentOled;
        background = AppColors.backgroundOled;
        surface = AppColors.surfaceOled;
        break;
      case AppThemeMode.midnight:
        primary = AppColors.accentMidnight;
        background = AppColors.backgroundMidnight;
        surface = AppColors.surfaceMidnight;
        break;
      case AppThemeMode.emerald:
        primary = AppColors.accentEmerald;
        background = AppColors.backgroundEmerald;
        surface = AppColors.surfaceEmerald;
        break;
      case AppThemeMode.gold:
        primary = AppColors.accentGold;
        background = AppColors.backgroundGold;
        surface = AppColors.surfaceGold;
        secondary = AppColors.goldSecondary;
        break;
      case AppThemeMode.deepsecure:
        primary = AppColors.dsPrimary;
        background = AppColors.dsBackground;
        surface = AppColors.dsSurface;
        secondary = AppColors.dsSecondary;
        break;
      default:
        primary = AppColors.dsPrimary;
        background = AppColors.dsBackground;
        surface = AppColors.dsSurface;
    }

    final textColor = Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        surface: surface,
        primary: primary,
        secondary: secondary,
        onSurface: textColor,
      ),
      textTheme: GoogleFonts.almaraiTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(
          textStyle: TextStyle(fontWeight: FontWeight.w900, color: textColor, letterSpacing: 2),
        ),
        headlineMedium: GoogleFonts.orbitron(
          textStyle: TextStyle(fontWeight: FontWeight.bold, color: primary),
        ),
        titleLarge: GoogleFonts.almarai(
          textStyle: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        bodyLarge: GoogleFonts.almarai(
          textStyle: TextStyle(color: textColor, fontSize: 16),
        ),
        bodyMedium: GoogleFonts.almarai(
          textStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: primary.withOpacity(0.15), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: primary.withOpacity(0.4),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // --- RESTORED standardDark (FIXING MAIN.DART ERROR) ---
  static ThemeData get standardDark => getTheme(AppThemeMode.deepsecure, true);

  static ThemeData get darkTheme => getTheme(AppThemeMode.deepsecure, true);
  static ThemeData get lightTheme => getTheme(AppThemeMode.deepsecure, true);
}
