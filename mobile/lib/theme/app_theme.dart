// ============================================================
//  lib/theme/app_theme.dart
//  Aura Diet Planner — Volcanic Cyberpunk Design System
//  No external font assets — Material system fonts only
// ============================================================

import 'package:flutter/material.dart';

// ── Brand color tokens ─────────────────────────────────────────────
class AuraColors {
  AuraColors._();

  // Surfaces
  static const bg       = Color(0xFF0D1117); // Obsidian Dark
  static const bgCard   = Color(0xFF161B22); // Deep Carbon
  static const surface  = Color(0x0AFFFFFF); // 4% white overlay
  static const border   = Color(0xFF21262D); // Structural border

  // Accents
  static const orange   = Color(0xFFFF7B00); // Volt Orange (primary)
  static const amber    = Color(0xFFFF9D42); // Cyber Amber (secondary)

  // Macro colors
  static const calColor  = Color(0xFFFF7B00); // Volt Orange
  static const proColor  = Color(0xFF58A6FF); // Electric Blue
  static const carbColor = Color(0xFF3FB950); // Neon Green
  static const fatColor  = Color(0xFFA78BFA); // Cyber Violet

  // Status
  static const success   = Color(0xFF3FB950);
  static const error     = Color(0xFFF85149);
  static const warning   = Color(0xFFD29922);

  // Text
  static const textPrimary   = Color(0xFFE6EDF3); // Bright white
  static const textSecondary = Color(0xFF8B949E); // Slate Muted
  static const textMuted     = Color(0xFF484F58); // Deep muted
}

// ── Gradient tokens ────────────────────────────────────────────────
class AuraGradients {
  AuraGradients._();

  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AuraColors.orange, AuraColors.amber],
  );

  static const card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x18FF7B00), Color(0x0CFF9D42)],
  );

  static const heroBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x22FF7B00), Color(0xFF0D1117)],
  );
}

// ── Typography helpers — system fonts only ─────────────────────────
class AuraText {
  AuraText._();

  static TextStyle display({
    double size = 32,
    FontWeight weight = FontWeight.w900,
    Color? color,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AuraColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.1,
        fontFamily: null, // uses system default (Roboto on Android)
      );

  static TextStyle body({double size = 14, Color? color}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color ?? AuraColors.textSecondary,
        height: 1.6,
      );

  static TextStyle label({
    double size = 11,
    Color? color,
    double letterSpacing = 0.8,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? AuraColors.textMuted,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono({double size = 13, Color? color}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? AuraColors.textPrimary,
        fontFamily: 'monospace',
      );
}

// ── Theme ──────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AuraColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AuraColors.orange,
          secondary: AuraColors.amber,
          surface: AuraColors.bgCard,
          error: AuraColors.error,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AuraColors.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AuraText.display(size: 14, weight: FontWeight.w900)
              .copyWith(
            letterSpacing: 1.5,
            color: AuraColors.textPrimary,
          ),
          iconTheme: const IconThemeData(color: AuraColors.textPrimary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AuraColors.bgCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AuraColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AuraColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: AuraColors.orange, width: 1.5),
          ),
          labelStyle: AuraText.label(color: AuraColors.textSecondary),
          hintStyle: AuraText.body(color: AuraColors.textMuted),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AuraColors.orange,
            foregroundColor: Colors.black,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            textStyle: AuraText.body(size: 15, color: Colors.black)
                .copyWith(fontWeight: FontWeight.w800),
            elevation: 0,
          ),
        ),
        cardTheme: CardThemeData(
          color: AuraColors.bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
          selectedItemColor: AuraColors.orange,
          unselectedItemColor: AuraColors.textMuted,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AuraColors.bgCard,
          contentTextStyle: AuraText.body(color: AuraColors.textPrimary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}

// ── Decoration helpers ─────────────────────────────────────────────
BoxDecoration glassCard({
  double radius = 12,
  Gradient? gradient,
  Color? borderColor,
  Color? color,
}) =>
    BoxDecoration(
      color: color ?? AuraColors.bgCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AuraColors.border),
      gradient: gradient,
    );

BoxDecoration voltButton({double radius = 10}) => BoxDecoration(
      gradient: AuraGradients.brand,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: AuraColors.orange.withAlpha(80),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
