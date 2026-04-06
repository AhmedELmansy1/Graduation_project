import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/translations.dart';
import '../home/home_screen.dart';
import '../../providers/settings_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final lang = settings.locale.languageCode;
    final primaryColor = Theme.of(context).primaryColor;

    String t(String key) => Translations.translate(key, lang);

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: lang == 'ar' ? "تحليل جنائي بالذكاء الاصطناعي" : "AI Forensic Analysis",
          body: lang == 'ar' 
              ? "تحليل الصور والملفات الصوتية للكشف عن التلاعب باستخدام تقنيات متقدمة." 
              : "Analyze image and audio files for manipulations using advanced AI techniques.",
          image: Center(child: Icon(Icons.psychology, size: 100, color: primaryColor)),
          decoration: PageDecoration(
            pageColor: AppColors.background,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            bodyTextStyle: const TextStyle(color: Colors.white70),
          ),
        ),
        PageViewModel(
          title: lang == 'ar' ? "تحليل مستوى الخطأ (ELA)" : "Error Level Analysis",
          body: lang == 'ar' 
              ? "تحديد المناطق التي تم التلاعب بها في الصور بدقة عالية." 
              : "Identify manipulated pixel regions by checking compression differences.",
          image: const Center(child: Icon(Icons.layers_outlined, size: 100, color: AppColors.secondary)),
          decoration: PageDecoration(
            pageColor: AppColors.background,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            bodyTextStyle: const TextStyle(color: Colors.white70),
          ),
        ),
        PageViewModel(
          title: lang == 'ar' ? "سلسلة الحيازة الرقمية" : "Chain of Custody",
          body: lang == 'ar' 
              ? "يتم تشفير كل عملية فحص ببصمة SHA-256 لضمان النزاهة الجنائية." 
              : "Every analysis is hashed with SHA-256 to ensure forensic integrity.",
          image: const Center(child: Icon(Icons.security, size: 100, color: AppColors.success)),
          decoration: PageDecoration(
            pageColor: AppColors.background,
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            bodyTextStyle: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
      onDone: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
      showSkipButton: true,
      skip: Text(lang == 'ar' ? "تخطي" : "Skip", style: TextStyle(color: primaryColor)),
      next: Icon(Icons.arrow_forward, color: primaryColor),
      done: Text(lang == 'ar' ? "ابدأ" : "Start", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
      dotsDecorator: DotsDecorator(
        size: const Size(10, 10),
        color: Colors.white24,
        activeColor: primaryColor,
        activeSize: const Size(22, 10),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }
}
