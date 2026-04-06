import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/providers/settings_provider.dart';
import 'data/datasources/ai_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('forensic_logs');
  
  // تهيئة محرك DeepSecure-AI عند بدء التشغيل
  await AIService.init();
  
  runApp(
    const ProviderScope(
      child: ForensicApp(),
    ),
  );
}

class ForensicApp extends ConsumerWidget {
  const ForensicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final theme = settings.isLuxury 
        ? AppTheme.getTheme(settings.appTheme, true)
        : AppTheme.standardDark;

    return MaterialApp(
      title: 'DEEPSECURE AI',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      locale: settings.locale,
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: settings.locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
