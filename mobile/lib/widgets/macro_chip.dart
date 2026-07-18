// ============================================================
//  lib/widgets/macro_chip.dart
//  Colored macro stat pill — calories, protein, carbs, fats
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum MacroType { calories, protein, carbs, fats }

extension _MacroStyle on MacroType {
  Color get color => switch (this) {
        MacroType.calories => const Color(0xFFFF7B00),
        MacroType.protein  => AuraColors.proColor,
        MacroType.carbs    => AuraColors.carbColor,
        MacroType.fats     => AuraColors.fatColor,
      };

  String get label => switch (this) {
        MacroType.calories => 'kcal',
        MacroType.protein  => 'protein',
        MacroType.carbs    => 'carbs',
        MacroType.fats     => 'fats',
      };

  String get unit => switch (this) {
        MacroType.calories => '',
        MacroType.protein  => 'g',
        MacroType.carbs    => 'g',
        MacroType.fats     => 'g',
      };
}

class MacroChip extends StatelessWidget {
  final MacroType type;
  final int value;
  final bool large;

  const MacroChip({
    super.key,
    required this.type,
    required this.value,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final fontSize = large ? 22.0 : 16.0;
    final labelSize = large ? 11.0 : 9.0;
    final padding = large
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 10);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(large ? 14 : 10),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${value.toString()}${type.unit}',
            style: AuraText.mono(size: fontSize, color: color)
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            type.label.toUpperCase(),
            style: AuraText.label(size: labelSize, color: color.withAlpha(180)),
          ),
        ],
      ),
    );
  }
}

// ── Macro row — 4 chips side by side ──────────────────────────────
class MacroRow extends StatelessWidget {
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final bool large;

  const MacroRow({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: MacroChip(type: MacroType.calories, value: calories, large: large)),
        const SizedBox(width: 8),
        Expanded(child: MacroChip(type: MacroType.protein,  value: protein,  large: large)),
        const SizedBox(width: 8),
        Expanded(child: MacroChip(type: MacroType.carbs,    value: carbs,    large: large)),
        const SizedBox(width: 8),
        Expanded(child: MacroChip(type: MacroType.fats,     value: fats,     large: large)),
      ],
    );
  }
}
