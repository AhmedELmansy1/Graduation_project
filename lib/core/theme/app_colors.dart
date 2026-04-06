import 'package:flutter/material.dart';

enum AppThemeMode { oled, midnight, emerald, gold, deepsecure }

class AppColors {
  // --- DEEPSECURE ELITE PALETTE (NEW) ---
  static const Color dsPrimary = Color(0xFF00FF9C); // Electric Green
  static const Color dsSecondary = Color(0xFF00D1FF); // Cyber Cyan
  static const Color dsAccent = Color(0xFFBC13FE); // Deep Purple
  static const Color dsGold = Color(0xFFD4AF37); // Forensic Gold
  
  static const Color dsBackground = Color(0xFF020408); // Near Black
  static const Color dsSurface = Color(0xFF0A0E1A); // Dark Slate
  static const Color dsCard = Color(0xFF0D1224); // Deep Navy

  // --- COMPATIBILITY & OLD PALETTE ---
  static const Color eliteGold = dsGold;
  static const Color eliteGoldLight = Color(0xFFF9E498);
  static const Color eliteGoldDark = Color(0xFF8B6B1B);
  static const Color eliteNavy = Color(0xFF050A18);
  static const Color eliteSurface = Color(0xFF0D1224);

  static const Color neonCyan = dsSecondary;
  static const Color neonPurple = dsAccent;
  static const Color neonPink = Color(0xFFFF00E0);
  static const Color neonGreen = dsPrimary;
  static const Color neonOrange = Color(0xFFFFAC1C);

  static const Color primary = neonGreen; 
  static const Color secondary = neonCyan; 
  static const Color success = neonGreen;
  static const Color danger = Color(0xFFFF3344);
  static const Color warning = neonOrange;
  
  static const Color background = dsBackground;
  static const Color surface = dsSurface;
  static const Color border = Color(0xFF1A1F35);
  static const Color cardBg = dsCard;

  static const Color lightBackground = Color(0xFFF0F2F5);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightText = Color(0xFF1A1F35);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94949D);
  static const Color textMuted = Color(0xFF4B4B54);

  // --- NEW DEEPSECURE GRADIENTS ---
  static const LinearGradient dsMainGradient = LinearGradient(
    colors: [dsPrimary, dsSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dsDarkGradient = LinearGradient(
    colors: [Color(0xFF050A18), dsBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cyberGradient = LinearGradient(
    colors: [dsAccent, dsSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [eliteGoldDark, eliteGoldLight, eliteGoldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- RESTORED COMPATIBILITY ALIASES (FIXING ERRORS) ---
  static const Color accentOled = dsSecondary;
  static const Color accentMidnight = dsSecondary;
  static const Color accentEmerald = dsPrimary;
  
  static const Color backgroundMidnight = eliteNavy;
  static const Color surfaceMidnight = eliteSurface;
  static const Color backgroundOled = background;
  static const Color surfaceOled = surface;

  static const Color backgroundEmerald = Color(0xFF061A14);
  static const Color surfaceEmerald = Color(0xFF0A2E24);

  static const Color backgroundGold = Color(0xFF1A1608);
  static const Color surfaceGold = Color(0xFF2D260F);

  static const Color gold = eliteGold;
  static const Color accentGold = eliteGold;
  static const Color goldSecondary = eliteGoldDark;

  static const LinearGradient forensicGradient = dsMainGradient;
  static const LinearGradient premiumGradient = dsMainGradient;
}
