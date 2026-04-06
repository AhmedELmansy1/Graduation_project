import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/translations.dart';
import '../../providers/settings_provider.dart';
import '../about/about_app_screen.dart';
import '../../widgets/forensic_backgrounds.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final lang = settings.locale.languageCode;
    final primaryColor = Theme.of(context).primaryColor;
    final isLuxury = settings.isLuxury;
    final useBio = settings.useBiometrics;

    String t(String key) => Translations.translate(key, lang);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t('settings')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ForensicBackground(
        type: BackgroundType.circuit,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildSectionHeader(t('lang_system'), primaryColor),
              const SizedBox(height: 16),
              _buildSettingCard(
                child: ListTile(
                  leading: const Icon(Icons.language_rounded, color: Colors.blueAccent),
                  title: Text(t('app_lang')),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'ar', label: Text('AR')),
                      ButtonSegment(value: 'en', label: Text('EN')),
                    ],
                    selected: {lang},
                    onSelectionChanged: (val) => ref.read(settingsProvider.notifier).setLanguage(val.first),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSectionHeader(t('appearance'), primaryColor),
              const SizedBox(height: 16),
              
              _buildSettingCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(Icons.shield_moon_rounded, color: isLuxury ? Colors.white24 : Colors.blueGrey),
                      title: Text(t('dark_mode')),
                      subtitle: Text(t('dark_mode_desc')),
                      value: !isLuxury, 
                      onChanged: (val) => ref.read(settingsProvider.notifier).toggleLuxury(!val),
                    ),
                    const Divider(height: 1, indent: 70, color: Colors.white10),
                    SwitchListTile(
                      secondary: Icon(Icons.fingerprint_rounded, color: useBio ? AppColors.success : Colors.white24),
                      title: Text(t('biometric_lock')),
                      subtitle: Text(t('biometric_desc')),
                      value: useBio,
                      onChanged: (val) => ref.read(settingsProvider.notifier).toggleBiometrics(val),
                    ),
                  ],
                ),
              ),

              if (isLuxury) ...[
                const SizedBox(height: 32),
                _buildSectionHeader(t('luxury_themes'), primaryColor),
                const SizedBox(height: 16),
                _buildThemeSelector(ref, settings.appTheme),
              ],
              
              const SizedBox(height: 32),
              _buildSectionHeader(t('sys_info'), primaryColor),
              const SizedBox(height: 16),
              _buildSettingCard(
                child: ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: AppColors.success),
                  title: Text(t('sys_info')),
                  subtitle: const Text('v2.5.0 Premium Build'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutAppScreen())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSelector(WidgetRef ref, AppThemeMode currentMode) {
    final themes = [
      {'mode': AppThemeMode.oled, 'name': 'Neon Blue', 'color': AppColors.accentOled},
      {'mode': AppThemeMode.midnight, 'name': 'Midnight', 'color': AppColors.accentMidnight},
      {'mode': AppThemeMode.emerald, 'name': 'Emerald', 'color': AppColors.accentEmerald},
      {'mode': AppThemeMode.gold, 'name': 'Royal Gold', 'color': AppColors.accentGold},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: themes.length,
      itemBuilder: (context, index) {
        final theme = themes[index];
        final isSelected = currentMode == theme['mode'];
        final color = theme['color'] as Color;
        
        return InkWell(
          onTap: () => ref.read(settingsProvider.notifier).setAppTheme(theme['mode'] as AppThemeMode),
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? color : Colors.white10,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(
                  theme['name'] as String,
                  style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.5),
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.backgroundOled.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}
