// ============================================================
//  lib/screens/home_screen.dart
//  Aura Diet Planner — Navigation Shell
//  Volcanic Cyberpunk shell spec
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'generate_screen.dart';
import 'saved_plans_screen.dart';
import 'accounts_screen.dart';

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
    AccountsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkEngine();
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
          toolbarHeight: 60,
          title: Row(
            children: [
              // Brand mark
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AuraGradients.brand,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AuraColors.orange.withAlpha(100),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.black,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              // App name — tracking 1.5, fw900
              Text(
                'AURA DIET PLANNER',
                style: AuraText.display(size: 13, weight: FontWeight.w900)
                    .copyWith(
                  letterSpacing: 1.5,
                  color: AuraColors.textPrimary,
                ),
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AuraColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AuraColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _engineOnline
                            ? AuraColors.success
                            : AuraColors.error,
                        shape: BoxShape.circle,
                        boxShadow: _engineOnline
                            ? [
                                BoxShadow(
                                  color: AuraColors.success.withAlpha(140),
                                  blurRadius: 5,
                                )
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _engineOnline ? 'Online' : 'Offline',
                      style: AuraText.mono(
                        size: 10,
                        color: _engineOnline
                            ? AuraColors.success
                            : AuraColors.error,
                      ),
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
            selectedItemColor: AuraColors.orange,
            unselectedItemColor: AuraColors.textMuted,
            selectedLabelStyle: AuraText.label(
              size: 10,
              color: AuraColors.orange,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: AuraText.label(
              size: 10,
              color: AuraColors.textMuted,
              letterSpacing: 0.5,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.bolt),
                activeIcon: Icon(Icons.bolt),
                label: 'Generate',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_border),
                activeIcon: Icon(Icons.bookmark),
                label: 'Saved',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
