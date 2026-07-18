// ============================================================
//  lib/widgets/meal_card.dart
//  Expandable meal card — shows macro summary + ingredient table
// ============================================================

import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../theme/app_theme.dart';
import 'macro_chip.dart';
import 'ingredient_row.dart';

class MealCard extends StatefulWidget {
  final Meal meal;
  final VoidCallback? onTap;

  const MealCard({super.key, required this.meal, this.onTap});

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Container(
      decoration: glassCard(radius: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order badge + time
                  Row(
                    children: [
                      _OrderBadge(meal.order),
                      const SizedBox(width: 8),
                      Text(
                        meal.scheduledTime,
                        style: AuraText.mono(
                            size: 11, color: AuraColors.textMuted),
                      ),
                      const Spacer(),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AuraColors.textMuted,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Meal name
                  Text(
                    meal.name,
                    style: AuraText.display(size: 15, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),

                  // Tactical intent
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AuraColors.orange, width: 2),
                      ),
                    ),
                    child: Text(
                      meal.tacticalIntent,
                      style: AuraText.body(size: 12)
                          .copyWith(fontStyle: FontStyle.italic),
                      maxLines: _expanded ? 10 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Macro row
                  MacroRow(
                    calories: meal.totalCalories,
                    protein: meal.totalProtein,
                    carbs: meal.totalCarbs,
                    fats: meal.totalFats,
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable ingredients ───────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                const Divider(height: 1),
                const IngredientTableHeader(),
                ...meal.ingredients.asMap().entries.map(
                      (e) => IngredientRow(
                        ingredient: e.value,
                        isLast: e.key == meal.ingredients.length - 1,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order badge ────────────────────────────────────────────────────
class _OrderBadge extends StatelessWidget {
  final int order;
  const _OrderBadge(this.order);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: AuraColors.orange.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AuraColors.orange.withAlpha(60)),
        ),
        child: Text(
          'MEAL $order',
          style: AuraText.mono(size: 10, color: AuraColors.orange)
              .copyWith(fontWeight: FontWeight.w700),
        ),
      );
}
