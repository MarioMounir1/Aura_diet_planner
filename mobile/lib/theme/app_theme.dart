// ============================================================
//  lib/theme/app_theme.dart
//  Aura Diet Planner — Dark premium design system
//  Volcanic-Nutrition-Engine
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand colors ───────────────────────────────────────────────────
class AuraColors {
  AuraColors._();

  static const bg         = Color(0xFF080B12);
  static const bgCard     = Color(0xFF0D1117);
  static const surface    = Color(0x0AFFFFFF); // ~4% white
  static const border     = Color(0x14FFFFFF); // ~8% white

  // Brand gradient stops
  static const orange     = Color(0xFFFF6B35);
  static const pink       = Color(0xFFFF3CAC);
  static const purple     = Color(0xFF784BA0);

  // Macro colors
  static const calColor   = Color(0xFFFB923C);
  static const proColor   = Color(0xFF60A5FA);
  static const carbColor  = Color(0xFF34D399);
  static const fatColor   = Color(0xFFA78BFA);

  // Status
  static const success    = Color(0xFF10B981);
  static const error      = Color(0xFFEF4444);
  static const warning    = Color(0xFFF59E0B);

  // Text
  static const textPrimary   = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFF8892A4);
  static const textMuted     = Color(0xFF4B5563);
}

// ── Gradients ──────────────────────────────────────────────────────
class AuraGradients {
  AuraGradients._();

  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AuraColors.orange, AuraColors.pink, AuraColors.purple],
  );

  static const card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x12FF6B35), Color(0x0CFF3CAC)],
  );

  static const proGrad = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
  );
}

// ── Text styles ────────────────────────────────────────────────────
class AuraText {
  AuraText._();

  static TextStyle display({double size = 32, FontWeight weight = FontWeight.w900}) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: weight,
        color: AuraColors.textPrimary,
        letterSpacing: -0.03 * size,
        height: 1.1,
      );

  static TextStyle body({double size = 14, Color? color}) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? AuraColors.textSecondary,
        height: 1.6,
      );

  static TextStyle label({double size = 12, Color? color}) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? AuraColors.textMuted,
        letterSpacing: 0.07 * size,
      );

  static TextStyle mono({double size = 13, Color? color}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? AuraColors.textPrimary,
      );
}

// ── Theme ──────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AuraColors.bg,
    colorScheme: ColorScheme.dark(
      primary: AuraColors.pink,
      secondary: AuraColors.orange,
      surface: AuraColors.bgCard,
      error: AuraColors.error,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: AuraColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AuraText.display(size: 20, weight: FontWeight.w700),
      iconTheme: const IconThemeData(color: AuraColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AuraColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AuraColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AuraColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AuraColors.pink, width: 1.5),
      ),
      labelStyle: AuraText.label(),
      hintStyle: AuraText.body(color: AuraColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AuraColors.pink,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AuraText.body(size: 16, color: Colors.white)
            .copyWith(fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    cardTheme: CardThemeData(
      color: AuraColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AuraColors.border),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AuraColors.border,
      thickness: 1,
      space: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AuraColors.bgCard,
      selectedItemColor: AuraColors.pink,
      unselectedItemColor: AuraColors.textMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AuraColors.bgCard,
      contentTextStyle: AuraText.body(color: AuraColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ── Reusable decoration helpers ────────────────────────────────────
BoxDecoration glassCard({
  double radius = 16,
  Gradient? gradient,
  Color? borderColor,
}) =>
    BoxDecoration(
      color: AuraColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AuraColors.border),
      gradient: gradient,
    );

BoxDecoration gradientBrand({double radius = 12}) => BoxDecoration(
      gradient: AuraGradients.brand,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AuraColors.pink.withAlpha(70),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
