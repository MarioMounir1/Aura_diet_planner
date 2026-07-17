// ============================================================
//  lib/main.dart
//  Aura Diet Planner — Flutter app entry point
//  Volcanic-Nutrition-Engine
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AuraColors.bgCard,
    ),
  );

  // Load persisted API base URL from SharedPreferences
  await ApiService.instance.loadBaseUrl();

  runApp(const AuraDietPlannerApp());
}

class AuraDietPlannerApp extends StatelessWidget {
  const AuraDietPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Diet Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
