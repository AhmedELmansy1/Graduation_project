import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../widgets/glass_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/translations.dart';
import '../../widgets/forensic_backgrounds.dart';
import '../../../data/repositories/log_repository_impl.dart';
import '../../../domain/entities/analysis_result.dart'; // Import
import '../results/forensic_result_screen.dart'; // Import
import '../../providers/settings_provider.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  final LogRepository _repository = LogRepository();
  List<dynamic> _logs = [];
  List<dynamic> _filteredLogs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isAuthenticated = false; // Track biometric authentication status
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadLogs();
  }

  Future<void> _checkAuthentication() async {
    final settings = ref.read(settingsProvider);
    if (settings.useBiometrics) {
      setState(() => _isAuthenticating = true);
      final success = await ref.read(settingsProvider.notifier).authenticate();
      if (mounted) {
        setState(() {
          _isAuthenticated = success;
          _isAuthenticating = false;
        });
        if (!success) {
          // If auth fails, show a message or pop
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Authentication Failed"), backgroundColor: Colors.redAccent),
          );
          Navigator.pop(context);
        }
      }
    } else {
      setState(() => _isAuthenticated = true);
    }
  }

  void _loadLogs() {
    final allLogs = _repository.getAllLogs();
    setState(() {
      _logs = allLogs;
      _filteredLogs = allLogs;
    });
  }

  void _filterLogs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredLogs = _logs;
      });
      return;
    }
    
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredLogs = _logs.where((log) {
        final id = log['id']?.toString().toLowerCase() ?? '';
        final hash = log['fileHash']?.toString().toLowerCase() ?? '';
        final type = log['type']?.toString().toLowerCase() ?? '';
        return id.contains(lowerQuery) || hash.contains(lowerQuery) || type.contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final lang = settings.locale.languageCode;
    final primaryColor = Theme.of(context).primaryColor;
    String t(String key) => Translations.translate(key, lang);

    if (_isAuthenticating) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint_rounded, size: 80, color: AppColors.eliteGold).animate(onPlay: (c) => c.repeat()).shimmer(),
              const SizedBox(height: 20),
              const Text("AUTHENTICATING...", style: TextStyle(color: Colors.white54, letterSpacing: 2, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated && settings.useBiometrics) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_rounded, size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text("ACCESS DENIED", style: TextStyle(color: Colors.redAccent, letterSpacing: 2, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _checkAuthentication,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text("RETRY AUTHENTICATION", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: "Search ID, Hash, or Type...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: InputBorder.none,
              ),
              onChanged: _filterLogs,
            )
          : Text(t('archive')),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredLogs = _logs;
                }
              });
            },
          ),
          if (settings.useBiometrics)
            IconButton(
              icon: const Icon(Icons.lock_outline_rounded, color: AppColors.eliteGold),
              onPressed: () => setState(() => _isAuthenticated = false),
              tooltip: "Lock Archive",
            ),
          if (_logs.isNotEmpty && !_isSearching)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.danger),
              tooltip: t('clear_logs'),
              onPressed: () async {
                await _repository.clearLogs();
                _loadLogs();
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: ForensicBackground(
        type: BackgroundType.dna,
        child: SafeArea(
          child: _filteredLogs.isEmpty 
            ? _buildEmptyState(t)
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: _filteredLogs.length,
                itemBuilder: (context, index) {
                  final log = _filteredLogs[index] as Map;
                  final score = (log['score'] as num?)?.toDouble() ?? 0.0;
                  final isSuspicious = score > 0.5;
                  final color = isSuspicious ? AppColors.danger : AppColors.success;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GlassCard(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: color.withOpacity(0.1)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSuspicious ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                            color: color,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          'CASE #${log['id'].toString().substring(log['id'].toString().length - 4)}',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1, color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'SHA-256: ${log['fileHash'].toString().substring(0, 16)}...',
                              style: TextStyle(fontSize: 10, color: primaryColor.withOpacity(0.7), fontFamily: 'monospace'),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(log['timestamp'])),
                              style: const TextStyle(fontSize: 10, color: Colors.white38),
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primaryColor.withOpacity(0.3)),
                        onTap: () {
                          final result = AnalysisResult.fromMap(log);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForensicResultScreen(result: result),
                            ),
                          );
                        },
                      ),
                    ),
                  ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
                },
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String Function(String) t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open_rounded, size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 24),
          Text(
            t('no_logs'),
            style: const TextStyle(color: Colors.white24, fontWeight: FontWeight.bold),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
