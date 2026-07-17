// ============================================================
//  lib/screens/home_screen.dart
//  Main navigation shell — bottom tab bar + engine status
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'generate_screen.dart';
import 'saved_plans_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _engineOnline = false;

  final List<Widget> _screens = const [
    GenerateScreen(),
    SavedPlansScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkEngine();
    // Re-check every 30 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return false;
      await _checkEngine();
      return mounted;
    });
  }

  Future<void> _checkEngine() async {
    final online = await ApiService.instance.checkHealth();
    if (mounted) setState(() => _engineOnline = online);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AuraColors.bgCard,
      ),
      child: Scaffold(
        backgroundColor: AuraColors.bg,
        // ── AppBar ────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: AuraColors.bg,
          toolbarHeight: 64,
          title: Row(
            children: [
              // Brand icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AuraGradients.brand,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AuraColors.pink.withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AuraGradients.brand.createShader(bounds),
                    child: Text(
                      'Aura',
                      style: AuraText.display(
                              size: 18, weight: FontWeight.w900)
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  Text(
                    'Diet Planner',
                    style: AuraText.label(
                        size: 9, color: AuraColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Engine status pill
            GestureDetector(
              onTap: _checkEngine,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AuraColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AuraColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: _engineOnline
                            ? AuraColors.success
                            : AuraColors.error,
                        shape: BoxShape.circle,
                        boxShadow: _engineOnline
                            ? [
                                BoxShadow(
                                  color: AuraColors.success.withAlpha(120),
                                  blurRadius: 6,
                                )
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _engineOnline ? 'Online' : 'Offline',
                      style: AuraText.mono(
                          size: 11,
                          color: _engineOnline
                              ? AuraColors.success
                              : AuraColors.error),
                    ),
                  ],
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AuraColors.border),
          ),
        ),

        // ── Body ──────────────────────────────────────────────────
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),

        // ── Bottom nav ────────────────────────────────────────────
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AuraColors.bgCard,
            border: Border(top: BorderSide(color: AuraColors.border)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AuraColors.pink,
            unselectedItemColor: AuraColors.textMuted,
            selectedLabelStyle:
                AuraText.label(size: 10, color: AuraColors.pink),
            unselectedLabelStyle:
                AuraText.label(size: 10, color: AuraColors.textMuted),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.bolt_rounded),
                activeIcon: Icon(Icons.bolt_rounded),
                label: 'Generate',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border_rounded),
                activeIcon: Icon(Icons.bookmark_rounded),
                label: 'Saved',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
