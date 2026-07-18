// ============================================================
//  lib/screens/plan_detail_screen.dart
//  Full diet plan detail view — opened from Saved Plans
// ============================================================

import 'package:flutter/material.dart';
import '../models/diet_plan.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/macro_chip.dart';
import '../widgets/meal_card.dart';

class PlanDetailScreen extends StatelessWidget {
  final DietPlan plan;

  const PlanDetailScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Sliver app bar with gradient header ───────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AuraColors.bg,
            leading: IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: glassCard(radius: 10),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AuraColors.textPrimary, size: 18),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // Delete button
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AuraColors.error.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AuraColors.error.withAlpha(60)),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AuraColors.error, size: 18),
                  ),
                  onPressed: () => _confirmDelete(context),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AuraColors.orange.withAlpha(30),
                      AuraColors.orange.withAlpha(20),
                      AuraColors.bg,
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Plan type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AuraColors.orange.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AuraColors.orange.withAlpha(60)),
                      ),
                      child: Text(
                        plan.type.label,
                        style: AuraText.mono(
                                size: 10, color: AuraColors.orange)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Plan name
                    Text(
                      plan.name,
                      style:
                          AuraText.display(size: 22, weight: FontWeight.w800),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (plan.createdAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(plan.createdAt!),
                        style: AuraText.mono(
                            size: 11, color: AuraColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Macro overview ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Targets',
                      style:
                          AuraText.label(color: AuraColors.textSecondary)),
                  const SizedBox(height: 12),
                  MacroRow(
                    calories: plan.targetCalories,
                    protein:  plan.targetProtein,
                    carbs:    plan.targetCarbs,
                    fats:     plan.targetFats,
                    large: true,
                  ),
                ],
              ),
            ),
          ),

          // ── Stats row ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _StatBadge(
                    icon: Icons.restaurant_menu_rounded,
                    label: '${plan.meals.length} Meals',
                    color: AuraColors.proColor,
                  ),
                  const SizedBox(width: 10),
                  _StatBadge(
                    icon: Icons.egg_alt_rounded,
                    label: '${plan.meals.fold(0, (s, m) => s + m.ingredients.length)} Ingredients',
                    color: AuraColors.carbColor,
                  ),
                  const SizedBox(width: 10),
                  _StatBadge(
                    icon: Icons.local_fire_department_rounded,
                    label: plan.type.label,
                    color: AuraColors.orange,
                  ),
                ],
              ),
            ),
          ),

          // ── Meal breakdown label ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Row(
                children: [
                  Text(
                    'Meal Breakdown',
                    style: AuraText.label(color: AuraColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AuraColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${plan.meals.length}',
                      style: AuraText.mono(
                          size: 11, color: AuraColors.textMuted),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Meal cards ────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  i == 0 ? 0 : 10,
                  20,
                  i == plan.meals.length - 1 ? 40 : 0,
                ),
                child: MealCard(meal: plan.meals[i]),
              ),
              childCount: plan.meals.length,
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete confirmation ────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuraColors.bgCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Plan',
            style: AuraText.display(size: 18, weight: FontWeight.w700)),
        content: Text(
          'Delete "${plan.name}"? This cannot be undone.',
          style: AuraText.body(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Cancel', style: AuraText.body(color: AuraColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: AuraText.body(color: AuraColors.error)
                    .copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && plan.id != null && context.mounted) {
      try {
        await ApiService.instance.deletePlan(plan.id!);
        if (context.mounted) Navigator.of(context).pop(true); // signals refresh
      } on ApiException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${e.message}'),
              backgroundColor: AuraColors.error.withAlpha(220),
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Stat badge pill ─────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 6),
            Text(label,
                style: AuraText.label(size: 11, color: color)
                    .copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
