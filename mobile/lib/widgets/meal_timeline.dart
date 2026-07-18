// ============================================================
//  lib/widgets/meal_timeline.dart
//  Strategic Meal Timeline — chronological feed layout
//  Volcanic Cyberpunk spec — left Volt Orange accent border
// ============================================================

import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../theme/app_theme.dart';

class MealTimeline extends StatelessWidget {
  final List<Meal> meals;

  const MealTimeline({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return Center(
        child: Text(
          'No meals in this plan.',
          style: AuraText.body(color: AuraColors.textMuted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AuraColors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'STRATEGIC MEAL TIMELINE',
                style: AuraText.label(
                    size: 10,
                    color: AuraColors.orange,
                    letterSpacing: 2.0),
              ),
              const Spacer(),
              Text(
                '${meals.length} MEALS',
                style: AuraText.label(
                    size: 9,
                    color: AuraColors.textMuted,
                    letterSpacing: 1.5),
              ),
            ],
          ),
        ),

        // ── Timeline feed ───────────────────────────────────────
        ...meals.asMap().entries.map((e) {
          final isLast = e.key == meals.length - 1;
          return _TimelineBlock(
            meal: e.value,
            isLast: isLast,
          );
        }),
      ],
    );
  }
}

// ── Single timeline block ──────────────────────────────────────────
class _TimelineBlock extends StatelessWidget {
  final Meal meal;
  final bool isLast;

  const _TimelineBlock({required this.meal, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline track (order indicator + line) ──────────
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Order circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AuraColors.orange.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AuraColors.orange.withAlpha(80),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${meal.order}',
                      style: AuraText.mono(
                              size: 11, color: AuraColors.orange)
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                // Connector line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AuraColors.orange.withAlpha(80),
                            AuraColors.border,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Meal content card ─────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: _MealTimelineCard(meal: meal),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meal content card with orange left border ──────────────────────
class _MealTimelineCard extends StatelessWidget {
  final Meal meal;
  const _MealTimelineCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        border: const Border(
          left: BorderSide(color: Color(0xFFFF7B00), width: 3),
          top: BorderSide(color: AuraColors.border),
          right: BorderSide(color: AuraColors.border),
          bottom: BorderSide(color: AuraColors.border),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal name + time
          Row(
            children: [
              Expanded(
                child: Text(
                  meal.name,
                  style: AuraText.display(
                      size: 14, weight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AuraColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  meal.scheduledTime,
                  style: AuraText.mono(
                      size: 10, color: AuraColors.textMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tactical intent — italic slate muted
          Text(
            meal.tacticalIntent,
            style: AuraText.body(size: 12, color: AuraColors.textSecondary)
                .copyWith(fontStyle: FontStyle.italic),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Macro readout — bold Volt Orange
          _MacroReadout(meal: meal),
        ],
      ),
    );
  }
}

// ── Bold Volt Orange macro absolute readout ────────────────────────
class _MacroReadout extends StatelessWidget {
  final Meal meal;
  const _MacroReadout({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AuraColors.orange.withAlpha(12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AuraColors.orange.withAlpha(40)),
      ),
      child: Text(
        '${meal.totalCalories} kcal  |  '
        '${meal.totalProtein}g P  |  '
        '${meal.totalCarbs}g C  |  '
        '${meal.totalFats}g F',
        style: AuraText.mono(size: 11, color: AuraColors.orange)
            .copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
