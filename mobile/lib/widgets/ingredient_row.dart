// ============================================================
//  lib/widgets/ingredient_row.dart
//  Single ingredient row inside the meal detail table
// ============================================================

import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../theme/app_theme.dart';

class IngredientRow extends StatelessWidget {
  final Ingredient ingredient;
  final bool isLast;

  const IngredientRow({
    super.key,
    required this.ingredient,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AuraColors.border, width: 1),
              ),
      ),
      child: Row(
        children: [
          // Ingredient name
          Expanded(
            flex: 4,
            child: Text(
              ingredient.name,
              style: AuraText.body(size: 13, color: AuraColors.textPrimary)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          // Weight
          _Cell('${ingredient.weightGrams}g', color: AuraColors.textMuted),
          // Calories
          _Cell('${ingredient.calories}', color: AuraColors.calColor),
          // Protein
          _Cell('${ingredient.protein}g', color: AuraColors.proColor),
          // Carbs
          _Cell('${ingredient.carbs}g', color: AuraColors.carbColor),
          // Fats
          _Cell('${ingredient.fats}g', color: AuraColors.fatColor),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  final Color color;
  const _Cell(this.text, {required this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 38,
        child: Text(
          text,
          style: AuraText.mono(size: 11, color: color),
          textAlign: TextAlign.right,
        ),
      );
}

// ── Table header ───────────────────────────────────────────────────
class IngredientTableHeader extends StatelessWidget {
  const IngredientTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AuraColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text('Ingredient',
                style: AuraText.label(size: 10, color: AuraColors.textMuted)),
          ),
          _HeaderCell('wt'),
          _HeaderCell('kcal'),
          _HeaderCell('P'),
          _HeaderCell('C'),
          _HeaderCell('F'),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 38,
        child: Text(
          text,
          style: AuraText.label(size: 10, color: AuraColors.textMuted),
          textAlign: TextAlign.right,
        ),
      );
}
